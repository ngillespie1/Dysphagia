import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Scheduled function to send daily exercise reminders
 * Runs every hour and sends notifications to users based on their preferences
 */
export const dailyNotificationScheduler = functions.pubsub
  .schedule('0 * * * *')  // Every hour
  .timeZone('America/New_York')
  .onRun(async (context) => {
    const now = new Date();
    const currentHour = now.getHours();
    
    console.log(`Running notification scheduler for hour ${currentHour}`);
    
    try {
      // Query users who have reminders set for this hour
      const usersSnapshot = await admin.firestore()
        .collection('users')
        .where('notificationSettings.enabled', '==', true)
        .where('notificationSettings.reminderHours', 'array-contains', currentHour)
        .get();
      
      if (usersSnapshot.empty) {
        console.log('No users to notify at this hour');
        return null;
      }
      
      const notifications: Promise<string>[] = [];
      
      usersSnapshot.forEach((doc) => {
        const userData = doc.data();
        const fcmToken = userData.fcmToken;
        
        if (fcmToken) {
          notifications.push(sendExerciseReminder(fcmToken, userData.name));
        }
      });
      
      await Promise.all(notifications);
      console.log(`Sent ${notifications.length} notifications`);
      
      return null;
    } catch (error) {
      console.error('Error in notification scheduler:', error);
      throw error;
    }
  });

/**
 * Sends an exercise reminder notification to a specific user
 */
async function sendExerciseReminder(
  fcmToken: string,
  userName?: string
): Promise<string> {
  const message: admin.messaging.Message = {
    notification: {
      title: 'Time for your exercises!',
      body: userName
        ? `${userName}, your daily swallowing exercises are ready.`
        : 'Your daily swallowing exercises are ready.',
    },
    data: {
      type: 'exercise_reminder',
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'swallow_safe_exercises',
        priority: 'high',
        defaultSound: true,
        defaultVibrateTimings: true,
      },
    },
    apns: {
      payload: {
        aps: {
          badge: 1,
          sound: 'default',
          category: 'exerciseReminder',
        },
      },
    },
    token: fcmToken,
  };
  
  try {
    const response = await admin.messaging().send(message);
    return response;
  } catch (error) {
    console.error('Error sending FCM message:', error);
    throw error;
  }
}

/**
 * HTTP function to send a test notification
 */
export const sendTestNotification = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated.'
      );
    }
    
    const userId = context.auth.uid;
    
    // Get user's FCM token
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(userId)
      .get();
    
    const userData = userDoc.data();
    const fcmToken = userData?.fcmToken;
    
    if (!fcmToken) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'No FCM token registered for user.'
      );
    }
    
    await sendExerciseReminder(fcmToken, userData?.name);
    
    return { success: true };
  }
);
