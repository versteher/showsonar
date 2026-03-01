import * as admin from 'firebase-admin';
import { onSchedule } from 'firebase-functions/v2/scheduler';

// Ensure Firebase is initialized
if (!admin.apps.length) {
    admin.initializeApp();
}

/**
 * Runs every weekend at 18:00.
 * Proactively reminds users to watch items they've explicitly saved but haven't watched yet.
 */
export const watchlistReminders = onSchedule('every saturday 18:00', async (event) => {
    const firestore = admin.firestore();
    const messaging = admin.messaging();

    console.log('Starting watchlistReminders job...');

    try {
        const usersSnapshot = await firestore.collection('users').get();
        if (usersSnapshot.empty) {
            console.log('No users found.');
            return;
        }

        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        for (const userDoc of usersSnapshot.docs) {
            const userId = userDoc.id;
            const userData = userDoc.data();

            // Skip users without push tokens
            if (!userData.fcmTokens || userData.fcmTokens.length === 0) {
                continue;
            }

            try {
                // Query user's watchlist for items added long ago
                const watchlistRef = firestore.collection('users').doc(userId).collection('watchlist');
                const oldItemsSnapshot = await watchlistRef
                    .where('timestamp', '<', admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
                    .limit(5)
                    .get();

                if (!oldItemsSnapshot.empty) {
                    // Pick a random item from the results
                    const randomDoc = oldItemsSnapshot.docs[Math.floor(Math.random() * oldItemsSnapshot.docs.length)];
                    const mediaTitle = randomDoc.data().title;
                    const mediaId = randomDoc.id;
                    const mediaType = randomDoc.data().type || 'movie';

                    const title = `Movie Night? 🍿`;
                    const body = `You added ${mediaTitle} to your watchlist a while ago. It's the perfect time to watch it!`;

                    const message = {
                        notification: { title, body },
                        data: {
                            mediaId: mediaId,
                            mediaType: mediaType,
                            click_action: 'FLUTTER_NOTIFICATION_CLICK'
                        },
                        tokens: userData.fcmTokens
                    };

                    const response = await messaging.sendEachForMulticast(message);
                    console.log(`Sent Watchlist Reminder to User ${userId}: ${response.successCount} successes`);
                }
            } catch (err) {
                console.error(`Error processing watchlist for user ${userId}:`, err);
            }
        }
    } catch (error) {
        console.error('Failed to run watchlistReminders job:', error);
    }
});
