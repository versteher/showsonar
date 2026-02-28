const {
    assertFails,
    assertSucceeds,
    initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const fs = require('fs');

let testEnv;

before(async () => {
    testEnv = await initializeTestEnvironment({
        projectId: 'streamscout-dev',
        firestore: {
            rules: fs.readFileSync('../terraform/modules/firestore/firestore.rules', 'utf8'),
        },
    });
});

after(async () => {
    await testEnv.cleanup();
});

beforeEach(async () => {
    await testEnv.clearFirestore();
});

describe('Firestore security rules', () => {
    describe('User data access', () => {
        it('allows a user to read and write their own data', async () => {
            const db = testEnv.authenticatedContext('user123').firestore();

            const collections = ['watchHistory', 'watchlist', 'preferences'];
            for (const col of collections) {
                const docRef = db.doc(`users/user123/${col}/doc1`);
                await assertSucceeds(docRef.set({ test: true }));
                await assertSucceeds(docRef.get());
            }
        });

        it('denies a user from reading/writing another user data', async () => {
            const db = testEnv.authenticatedContext('user123').firestore();

            const docRef = db.doc(`users/otherUser/watchlist/doc1`);
            await assertFails(docRef.set({ test: true }));
            await assertFails(docRef.get());
        });

        it('denies unauthenticated read/write access', async () => {
            const db = testEnv.unauthenticatedContext().firestore();

            const docRef = db.doc(`users/user123/watchlist/doc1`);
            // Writing should fail
            await assertFails(docRef.set({ test: true }));
            // Reading should fail
            await assertFails(docRef.get());
        });
    });
});
