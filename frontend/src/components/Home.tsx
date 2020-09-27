import React, { Component } from 'react';
import firebase from 'firebase';
import { Link } from 'react-router-dom';
import { Button } from 'reactstrap';

interface HomeState {
    name?: string | null | undefined,
    groupName?: string,
    isLoaded: boolean
}

// Home
class Home extends Component<{}, HomeState> {
    state: HomeState = {
        name: "",
        groupName: "",
        isLoaded: false
    };

    componentDidMount() {
        // 自分が所属しているグループを取得する
        const db = firebase.firestore();
        const user = firebase.auth().currentUser;
        const groupRef = db.collection("todo/v1/groups");

        const myGroups = groupRef.where("members", "array-contains", user?.uid);
        let groupName = "";
        let myName: string = "";

        myGroups.get().then(function(docs) {
            docs.forEach(function(doc) {
                groupName = doc.data()["name"]
            });
        })
        .then(v => {
            console.log(user);
            this.setState({
                name: user?.displayName,
                groupName: groupName,
                isLoaded: true
            });
        });;
    }

    handleLogout = () => {
        firebase.auth().signOut();
    }

    render() {
        return (
            <div className="container">
                <p>Home</p>
                <Link to="/profile">Profileへ</Link>
                <br/>

                {(() => {
                    if (this.state.isLoaded) {
                        return (
                            <div id="display-name">こんにちは、{this.state.name}さん</div>
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
