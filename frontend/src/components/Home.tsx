import React, { Component } from 'react';
import firebase from 'firebase';
import { Button } from 'reactstrap';
import User from './User';

var moment = require("moment");

interface HomeState {
    name?: string | null | undefined,
    groupName?: string,
    groupID?: string,
    isLoaded: boolean,
    isAttend: boolean   // 出席しているかどうか
    users: any,
}

// Home
class Home extends Component<{}, HomeState> {
    state: HomeState = {
        name: "",
        groupName: "",
        groupID: "",
        isLoaded: false,
        isAttend: false,
        users: [],
    };

    // 出席ユーザーを再取得する
    resetUserData = () => {
        const db = firebase.firestore();
        const attendUserID: (string|undefined)[] = [];  // 出席しているユーザーID
        const attendUserData: any = [];                 // 出席しているユーザー情報
        const user = firebase.auth().currentUser;

        // 出席者情報を取得
        const path = "todo/v1/groups/" + this.state.groupID + "/todo"
        let m1 = moment();
        let m2 = moment();
        m1.startOf('day');
        m2.endOf('day');

        const todos = db.collection(path).orderBy('createdAt')
                            .where("createdAt", ">", m1.toDate())
                            .where("createdAt", "<=", m2.toDate())
                            .where("isAttended", "==", true)
        todos.get().then(docs => {
            docs.forEach(async(doc) => {
                const userID = await doc.data()["userID"];
                attendUserID.push(userID);
            });
        })
        .then(v => {
            // isAttendがtrueのユーザー情報を取得
            const userPath = "todo/v1/users/"
            attendUserID.forEach(userID => {
                const users = db.collection(userPath).doc(userID)
                users.get().then(v => {
                    attendUserData.push(v.data())
                })
            })
            //console.log(attendUserData);
            const userData: any[] = attendUserData;
            this.setState({
                users: userData
            })
        })
    }

    componentDidMount() {
        // 自分が所属しているグループを取得する
        const db = firebase.firestore();
        const user = firebase.auth().currentUser;
        const groupRef = db.collection("todo/v1/groups");

        const myGroups = groupRef.where("members", "array-contains", user?.uid);
        let groupName = "";
        let groupID = "";

        myGroups.get().then(function(docs) {
            docs.forEach(function(doc) {
                groupName = doc.data()["name"]
                groupID = doc.id
            });
        })
        .then(v => {
            this.setState({
                name: user?.displayName,
                groupName: groupName,
                groupID: groupID,
                isLoaded: true
            });
        })
        .then(v => { 
            this.resetUserData();
        });
    }

    handleLogout = () => {
        firebase.auth().signOut();
    }

    handleAttend = () => {
        const db = firebase.firestore();
        const path = "todo/v1/groups/" + this.state.groupID + "/todo"
        const groupRef = db.collection(path)
        const user = firebase.auth().currentUser;

        const today = new Date();
        const year = today.getFullYear();
        const month =  ("0"+(today.getMonth() + 1)).slice(-2)
        const day = ("0"+today.getDate()).slice(-2)

        const id = user?.uid + "_" + year.toString() + "_" + month.toString() + "_" + day.toString()

        groupRef.doc(id).set({
            createdAt: today,
            groupID: this.state.groupID,
            isAttended: true,
            isTodayAttended: true,
            userID: user?.uid
        }, { merge: true } )

        this.resetUserData();
        this.setState({
            isAttend: true
        })
    }

    handleDisAttend = () => {
        const db = firebase.firestore();
        const path = "todo/v1/groups/" + this.state.groupID + "/todo"
        const groupRef = db.collection(path)
        const user = firebase.auth().currentUser;

        const today = new Date();
        const year = today.getFullYear();
        const month =  ("0"+(today.getMonth() + 1)).slice(-2)
        const day = ("0"+today.getDate()).slice(-2)

        const id = user?.uid + "_" + year.toString() + "_" + month.toString() + "_" + day.toString()

        groupRef.doc(id).set({
            createdAt: today,
            groupID: this.state.groupID,
            isAttended: false,
            isTodayAttended: true,
            userID: user?.uid
        }, { merge: true } )

        this.resetUserData();
        this.setState({
            isAttend: false
        })
    }

    // 出席ユーザーを更新する
    checkUsers = () => {
        console.log(this.state.users);
        this.setState({
            users: this.state.users
        })
    }

    render() {
        return (
            <div className="container">
                {(() => {
                    if (this.state.isLoaded) {
                        return (
                            <h3>こんにちは、{this.state.name}さん</h3>
                        )
                    }
                })()}

                {(() => {
                    if (this.state.isAttend) {
                        return (
                            <div>
                                <Button color="warning" onClick={this.handleDisAttend}>帰宅</Button>
                            </div>
                        )
                    } else {
                        return (
                            <div>
                                <Button color="primary" onClick={this.handleAttend}>出席</Button>
                            </div>
                        )
                    }
                })()}

                {(() => {
                    const userItems: any[] = [];
                    this.state.users.forEach((key: any, index: number) => {
                        userItems.push(
                            <User
                                key={index}
                                id={this.state.users[index].id}
                                name={this.state.users[index].name}
                                image={this.state.users[index].Image}
                            />
                        )
                    });

                    return (
                        <div>
                            {userItems}
                        </div>
                    )
                })()}

                <br/>
                <Button onClick={this.handleLogout}>ログアウト</Button>
                <Button onClick={this.checkUsers}>リロード</Button>
                <br/>
                <br/>

            </div>
        );

    }
}

export default Home;
