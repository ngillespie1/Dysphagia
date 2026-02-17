import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Firestore trigger that updates streak data when a session is completed
 */
export const onSessionComplete = functions.firestore
  .document('users/{userId}/sessions/{sessionId}')
  .onCreate(async (snap, context) => {
    const { userId } = context.params;
    const sessionData = snap.data();
    
    console.log(`Processing session completion for user ${userId}`);
    
    try {
      // Get user document reference
      const userRef = admin.firestore().collection('users').doc(userId);
      
      // Run transaction to update streak atomically
      await admin.firestore().runTransaction(async (transaction) => {
        const userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          console.log('User document not found');
          return;
        }
        
        const userData = userDoc.data()!;
        const streakData = userData.streakData || {
          currentStreak: 0,
          longestStreak: 0,
          totalSessions: 0,
          lastCompletedAt: null,
        };
        
        const now = new Date();
        const sessionDate = sessionData.completedAt.toDate();
        const lastCompletedAt = streakData.lastCompletedAt?.toDate();
        
        // Calculate new streak
        let newStreak = 1;
        
        if (lastCompletedAt) {
          // Check if already completed today
          if (isSameDay(sessionDate, lastCompletedAt)) {
            console.log('Already completed today, no streak change');
            return;
          }
          
          // Check if completed yesterday (streak continues)
          if (isYesterday(sessionDate, lastCompletedAt)) {
            newStreak = streakData.currentStreak + 1;
          }
          // Otherwise, streak resets to 1
        }
        
        const newStreakData = {
          currentStreak: newStreak,
          longestStreak: Math.max(newStreak, streakData.longestStreak),
          totalSessions: streakData.totalSessions + 1,
          lastCompletedAt: admin.firestore.Timestamp.fromDate(sessionDate),
        };
        
        transaction.update(userRef, {
          streakData: newStreakData,
        });
        
        console.log(`Updated streak for user ${userId}:`, newStreakData);
      });
      
      return null;
    } catch (error) {
      console.error('Error updating streak:', error);
      throw error;
    }
  });

/**
 * Check if two dates are the same day
 */
function isSameDay(date1: Date, date2: Date): boolean {
  return (
    date1.getFullYear() === date2.getFullYear() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getDate() === date2.getDate()
  );
}

/**
 * Check if date1 is the day after date2
 */
function isYesterday(date1: Date, date2: Date): boolean {
  const yesterday = new Date(date1);
  yesterday.setDate(yesterday.getDate() - 1);
  return isSameDay(yesterday, date2);
}

/**
 * Scheduled function to reset broken streaks
 * Runs daily at midnight to check for users who missed yesterday
 */
export const resetBrokenStreaks = functions.pubsub
  .schedule('0 0 * * *')  // Daily at midnight
  .timeZone('America/New_York')
  .onRun(async (context) => {
    const now = new Date();
    const yesterday = new Date(now);
    yesterday.setDate(yesterday.getDate() - 1);
    
    console.log('Checking for broken streaks...');
    
    try {
      // Query users with active streaks who didn't complete yesterday
      const usersSnapshot = await admin.firestore()
        .collection('users')
        .where('streakData.currentStreak', '>', 0)
        .get();
      
      const batch = admin.firestore().batch();
      let updateCount = 0;
      
      usersSnapshot.forEach((doc) => {
        const userData = doc.data();
        const lastCompleted = userData.streakData?.lastCompletedAt?.toDate();
        
        if (lastCompleted) {
          // If last completion was before yesterday, reset streak
          const daysSinceCompletion = Math.floor(
            (now.getTime() - lastCompleted.getTime()) / (1000 * 60 * 60 * 24)
          );
          
          if (daysSinceCompletion > 1) {
            batch.update(doc.ref, {
              'streakData.currentStreak': 0,
            });
            updateCount++;
          }
        }
      });
      
      if (updateCount > 0) {
        await batch.commit();
        console.log(`Reset ${updateCount} broken streaks`);
      } else {
        console.log('No broken streaks to reset');
      }
      
      return null;
    } catch (error) {
      console.error('Error resetting streaks:', error);
      throw error;
    }
  });
