import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

admin.initializeApp();

export const onReleaseWritten = onDocumentWritten("releases/{releaseId}", async (event: any) => {
    const snapshot = event.data;
    if (!snapshot) {
        console.log("No data associated with the event");
        return;
    }

    const releaseData = snapshot.after.data();

    if (!releaseData) {
        console.log("Document was deleted or empty");
        return;
    }

    const mediaId = releaseData.mediaId;
    const title = releaseData.title;

    if (!mediaId || !title) {
        console.log("Missing mediaId or title in release document.");
        return;
    }

    const db = admin.firestore();

    // We query the collectionGroup 'watchlist' for users who have added this mediaId.
    // Assumes users hold their watchlist at users/{uid}/watchlist/{docId} and doc has mediaId.
    const usersWithWatchlist = await db.collectionGroup("watchlist")
        .where("mediaId", "==", mediaId)
        .get();

    if (usersWithWatchlist.empty) {
        console.log(`No users found with mediaId ${mediaId} in watchlist.`);
        return;
    }

    console.log(`Found ${usersWithWatchlist.size} users with mediaId ${mediaId} in watchlist.`);

    const messagePayload = {
        notification: {
            title: "New Release!",
            body: `${title} is now available!`,
        },
        data: {
            mediaId: String(mediaId),
            click_action: "FLUTTER_NOTIFICATION_CLICK"
        }
    };

    const tokens: string[] = [];

    for (const doc of usersWithWatchlist.docs) {
        // The doc is in users/{uid}/watchlist/{docId}
        const userRef = doc.ref.parent.parent;
        if (userRef) {
            const userDoc = await userRef.get();
            const userData = userDoc.data();
            if (userData && Array.isArray(userData.fcmTokens)) {
                tokens.push(...userData.fcmTokens);
            }
        }
    }

    if (tokens.length === 0) {
        console.log("No FCM tokens found for target users.");
        return;
    }

    try {
        const response = await admin.messaging().sendEachForMulticast({
            tokens: tokens,
            ...messagePayload
        });
        console.log(`${response.successCount} messages were sent successfully.`);
        if (response.failureCount > 0) {
            const failedTokens: string[] = [];
            response.responses.forEach((resp: any, idx: any) => {
                if (!resp.success) {
                    failedTokens.push(tokens[idx]);
                }
            });
            console.log('Failed tokens: ' + failedTokens);
        }
    } catch (error) {
        console.error("Error sending notifications", error);
    }
});

export const generateWeeklyRecap = onRequest(async (request, response) => {
    // Basic verification - this could be expanded to verify the OIDC token
    // However, Cloud Run / Cloud Functions can restrict unauthenticated access directly via IAM,
    // which is the recommended way to secure this.

    console.log("Starting weekly watch recap generation...");

    const db = admin.firestore();

    try {
        // Here we would typically query for all users, or query in batches.
        // For demonstration purposes, we'll log that the process has started
        // and fetch users who have opted into notifications or simply all users.

        const usersSnapshot = await db.collection("users").limit(10).get();

        if (usersSnapshot.empty) {
            console.log("No users found to send recaps to.");
            response.status(200).send("No users found.");
            return;
        }

        console.log(`Generating recaps for ${usersSnapshot.size} users (batched).`);

        // Placeholder for specific recap generation logic for each user
        // e.g., querying their watchHistory for the last 7 days,
        // assembling an email/notification, and sending it out.
        usersSnapshot.forEach((doc) => {
            const userData = doc.data();
            console.log(`Would generate recap for user: ${doc.id}`);
        });

        console.log("Weekly recap generation complete.");
        response.status(200).send("Weekly recap generation complete.");
    } catch (error) {
        console.error("Error generating weekly recaps", error);
        response.status(500).send("Error generating weekly recaps.");
    }
});

export * from './episode_alerts';
export * from './watchlist_reminders';
