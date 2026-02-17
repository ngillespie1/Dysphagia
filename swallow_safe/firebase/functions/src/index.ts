import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { aiProxy } from './aiProxy';
import { dailyNotificationScheduler } from './notifications';
import { onSessionComplete } from './streakCalculator';

// Initialize Firebase Admin
admin.initializeApp();

// Export Cloud Functions
export { aiProxy, dailyNotificationScheduler, onSessionComplete };
