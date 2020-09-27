import React, { Component } from 'react';
import firebase from 'firebase';
import { Button } from 'reactstrap';

interface HomeState {
    name?: string | null | undefined,
    groupName?: string,
    groupID?: string
    isLoaded: boolean,
    isAttend: boolean   // 出席しているかどうか
}

// Home
class Home extends Component<{}, HomeState> {
    state: HomeState = {
        name: "",
        groupName: "",
        groupID: "",
        isLoaded: false,
        isAttend: false
    };

    componentDidMount() {
        // 自分が所属しているグループを取得する
        const db = firebase.firestore();
        const user = firebase.auth().currentUser;
        const groupRef = db.collection("todo/v1/groups");

        const myGroups = groupRef.where("members", "array-contains", user?.uid);
        let groupName = "";
        let groupID = "";
        const attendUserID: (string|undefined)[] = [];  // 出席しているユーザーID
        const attendUserData: any[] = [];   // 出席しているユーザー情報

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
            // 出席者情報を取得
            const path = "todo/v1/groups/" + this.state.groupID + "/todo"
            const todos = db.collection(path).where("isAttended", "==", true)
            todos.get().then(function(docs) {
                docs.forEach(function(doc) {
                    attendUserID.push(doc.data()["userID"])
                });
            })
            .then(v => {
                // isAttendがTrueのユーザー情報を取得
                const userPath = "todo/v1/users/"
                attendUserID.forEach(userID => {
                    const users = db.collection(userPath).doc(userID)
                    users.get().then(v => {
                        attendUserData.push(v.data())
                    })
                })
                console.log(attendUserData);
            })
            .then(v => {
                // 自分のisAttendを確認し変更する 
                if (attendUserID.includes(user?.uid)) {
                    this.setState({
                        isAttend: true
                    })
                }
            })
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

        this.setState({
            isAttend: false
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

                <br/>
                <Button onClick={this.handleLogout}>ログアウト</Button>
                <br/>
                <br/>

            </div>
        );

    }
}

export default Home;
