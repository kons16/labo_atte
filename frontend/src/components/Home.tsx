import React, { Component } from 'react';
import firebase from 'firebase';
import { Button } from 'reactstrap';

interface HomeState {
    name?: string | null | undefined,
    groupName?: string,
    groupID?: string
    isLoaded: boolean,
}

// Home
class Home extends Component<{}, HomeState> {
    state: HomeState = {
        name: "",
        groupName: "",
        groupID: "",
        isLoaded: false
    };

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
        });;
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
    }

    render() {
        return (
            <div className="container">
                <p>Home</p>
                {(() => {
                    if (this.state.isLoaded) {
                        return (
                            <div id="display-name">こんにちは、{this.state.name}さん</div>
                        )
                    }
                })()}

                <br/>
                <Button color="primary" onClick={this.handleAttend}>出席</Button>
                <Button onClick={this.handleLogout}>ログアウト</Button>
                <br/>
                <br/>

            </div>
        );

    }
}

export default Home;
