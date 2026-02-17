import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import OpenAI from 'openai';
import Anthropic from '@anthropic-ai/sdk';
import * as cors from 'cors';

const corsHandler = cors({ origin: true });

// Safety disclaimer to append to all AI responses
const SAFETY_DISCLAIMER = '\n\n⚠️ I am an AI, not a doctor. If you are choking or cannot breathe, call emergency services immediately.';

// PHI patterns to strip from messages
const PHI_PATTERNS = [
  /\b\d{3}-\d{2}-\d{4}\b/g,  // SSN
  /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/g,  // Email
  /\b\d{3}[-.]?\d{3}[-.]?\d{4}\b/g,  // Phone
  /\b\d{1,2}\/\d{1,2}\/\d{2,4}\b/g,  // Date of birth
];

/**
 * Strips potentially identifying information from messages
 */
function stripPHI(text: string): string {
  let sanitized = text;
  for (const pattern of PHI_PATTERNS) {
    sanitized = sanitized.replace(pattern, '[REDACTED]');
  }
  return sanitized;
}

/**
 * Verifies that the user has an active Pro subscription via RevenueCat
 */
async function verifySubscription(userId: string): Promise<boolean> {
  // In production, verify with RevenueCat API
  // For now, check a flag in Firestore
  try {
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(userId)
      .get();
    
    const data = userDoc.data();
    return data?.isPro === true;
  } catch (error) {
    console.error('Error verifying subscription:', error);
    return false;
  }
}

/**
 * AI Proxy Cloud Function
 * Securely forwards requests to OpenAI or Anthropic APIs
 * Strips PHI and appends safety disclaimers
 */
export const aiProxy = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to use AI features.'
    );
  }
  
  const userId = context.auth.uid;
  
  // Verify Pro subscription
  const isPro = await verifySubscription(userId);
  if (!isPro) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Pro subscription required for AI features.'
    );
  }
  
  // Validate request data
  const { provider, messages, model, system } = data;
  
  if (!provider || !messages || !Array.isArray(messages)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Invalid request format.'
    );
  }
  
  // Sanitize messages
  const sanitizedMessages = messages.map((msg: { role: string; content: string }) => ({
    role: msg.role,
    content: stripPHI(msg.content),
  }));
  
  try {
    let response: string;
    
    if (provider === 'openai') {
      response = await callOpenAI(sanitizedMessages, model, system);
    } else if (provider === 'anthropic') {
      response = await callAnthropic(sanitizedMessages, model, system);
    } else {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Invalid AI provider specified.'
      );
    }
    
    // Append safety disclaimer
    return { response: response + SAFETY_DISCLAIMER };
    
  } catch (error) {
    console.error('AI API error:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to process AI request.'
    );
  }
});

async function callOpenAI(
  messages: Array<{ role: string; content: string }>,
  model: string = 'gpt-4o',
  systemPrompt?: string
): Promise<string> {
  const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
  });
  
  const fullMessages = systemPrompt
    ? [{ role: 'system' as const, content: systemPrompt }, ...messages]
    : messages;
  
  const completion = await openai.chat.completions.create({
    model: model,
    messages: fullMessages.map(m => ({
      role: m.role as 'system' | 'user' | 'assistant',
      content: m.content,
    })),
    max_tokens: 1024,
    temperature: 0.7,
  });
  
  return completion.choices[0]?.message?.content || 'No response generated.';
}

async function callAnthropic(
  messages: Array<{ role: string; content: string }>,
  model: string = 'claude-3-5-sonnet-20241022',
  systemPrompt?: string
): Promise<string> {
  const anthropic = new Anthropic({
    apiKey: process.env.ANTHROPIC_API_KEY,
  });
  
  const response = await anthropic.messages.create({
    model: model,
    max_tokens: 1024,
    system: systemPrompt,
    messages: messages.map(m => ({
      role: m.role as 'user' | 'assistant',
      content: m.content,
    })),
  });
  
  const textContent = response.content.find(c => c.type === 'text');
  return textContent?.type === 'text' ? textContent.text : 'No response generated.';
}
