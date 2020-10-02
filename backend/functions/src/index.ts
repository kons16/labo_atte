import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

import * as Moment from 'moment';

admin.initializeApp(functions.config().firebase);
const firestore = admin.firestore();
// const firebase_tools = require('firebase-tools');


async function ChangeIsAttendNumberSilentPushNotification(currentNumOfAttendees: string, fcmToken: string) {
    const message = {
        notification: {
            content_available: 'true'
        },
        data: {
            "currentNumOfAttendees": currentNumOfAttendees
        }
    };



    return admin.messaging().sendToDevice(fcmToken, message)
}

//@ts-ignore TS6133: 'req' is declared but its value is never read.
async function ChangeIsAttendNumberPushNotification(currentNumOfAttendees: string, fcmToken: string) {
    const Message = {
        token: fcmToken,
        apns: {
            payload: {
                aps: {
                    badge: 0,

                    headers: {
                        "apns-priority": "10",
                    },

                    sound: {
                        name: "message_send_009.wav",
                    },
                    alert: {
                        locKey: "ATTENDING_NOTIFICATION_BODY",
                        locArgs: [currentNumOfAttendees],
                    }
                }
            },
        }
    };

    return admin.messaging().send(Message);
}


export const onUpdateIsAttend = functions.firestore.document('/todo/v1/groups/{groupID}/todo/{todoID}').onUpdate(async (change, context) => {
    const afterData = change.after.data();

    console.log('onUpdated!');
    
    if (afterData) {
        const groupID = afterData.groupID as string;
        //@ts-ignore TS6133: 'req' is declared but its value is never read.
        const updateUserID  = afterData.userID as string;

        const collectionRef = '/todo/v1/groups/' + groupID + '/todo';
        const todayStr: string = Moment(new Date()).format("YYYY-MM-DD");        
        const todayDate: Date = new Date(todayStr);
        const todayTimestamp = admin.firestore.Timestamp.fromDate(todayDate);

        let atttendingUserID: string[] = [];

        console.log('attendingのユーザの取得開始');

        await firestore.collection(collectionRef).where('createdAt', '>=' , todayTimestamp).where('isAttended', '==', true).get()
            .then(snapshot => {
                if (snapshot.empty) {
                    console.log('空っぽ a');
					return null;
                }

                snapshot.forEach(doc => {
                    atttendingUserID.push(doc.data().userID as string);
                })

                return null;

            })
            .catch(error => {
                console.log(error);
            })

        atttendingUserID = [...new Set(atttendingUserID)];
        
        console.log('attendingのユーザの取得完了');
        console.log('attendingのユーザ数: ', atttendingUserID.length);
        console.log('attendingのユーザ: ', atttendingUserID);

        const documentRef = '/todo/v1/groups/' + groupID
        var groupMembersID: string[] = [];


        console.log('groupのユーザidの取得開始');

        await firestore.doc(documentRef).get()
            .then(doc => {
                if (!doc.exists) {
                    console.log('group無し');
                    console.log('documentRef: ', documentRef)
					return null;
                }
                const docData = doc.data();
                if (docData) { groupMembersID = docData.members as Array<string>; }
                return null;

            })
            .catch(error => {
                console.log(error);
            })
        
        console.log('groupのユーザidの取得完了');
        console.log('gropuのユーザIDs: ', groupMembersID);


        const membersFcmTokens: string[] = [];

        console.log('fcmTokenの取得開始');

        for (const userID of groupMembersID) {
            var userRef = 'todo/v1/users/' + userID
            await firestore.doc(userRef).get()
            .then(doc => {
                if (!doc.exists) {
                    console.log('user無し');
                    console.log('userRef: ', userRef)
					return null;
                }
                const docData = doc.data();
                if (docData) {
                    const usersFcmToken = docData.fcmToken
                    if (usersFcmToken != null) {
                        membersFcmTokens.push(usersFcmToken as string)
                    }
                }
                return null;

            })
            .catch(error => {
                console.log(error);
            })
        }

        console.log('fcmTokenの取得完了');
        console.log('fcmToken: ', membersFcmTokens);
        

        for (var fcmToken of membersFcmTokens) {
            ChangeIsAttendNumberPushNotification(atttendingUserID.length.toString(), fcmToken)
            .catch(() => 'catch')

            ChangeIsAttendNumberSilentPushNotification(atttendingUserID.length.toString(), fcmToken)
            .catch(() => 'catch')
        }
        
    }

    
});
