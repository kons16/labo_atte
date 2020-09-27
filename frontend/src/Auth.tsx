import React, { Component } from 'react';
import { Redirect } from 'react-router-dom';
import firebase from 'firebase';
//@ts-ignore
import LoadingOverlay from 'react-loading-overlay';

interface AuthState {
    signinCheck: boolean,
    signedIn: boolean
}

// 認証
class Auth extends Component<{}, AuthState> {
    state: AuthState = {
        signinCheck: false, //ログインチェックが完了してるか
        signedIn: false,    //ログインしてるか
    };

    // componentDidMountのタイミングを制御する用
    _isMounted: boolean = false;

    componentDidMount() {
        this._isMounted = true;

        // ログインしてるかどうかチェック
        firebase.auth().onAuthStateChanged(user => {
            if (user) {
                // ログインしている
                if (this._isMounted) {
                    this.setState({
                        signinCheck: true,
                        signedIn: true,
                    });
                }
            } else {
                // ログインしていない
                if (this._isMounted) {
                    this.setState({
                        signinCheck: true,
                        signedIn: false,
                    });
                }
            }
        })
    }

    componentWillUnmount () {
        this._isMounted = false;
    }

    render() {
        // チェックが終わってないならローディング表示
        if (!this.state.signinCheck) {
            return (
                <LoadingOverlay
                    active={true}
                    spinner
                    text='Loading...'
                >
                    <div style={{ height: '100vh', width: '100vw' }}></div>
                </ LoadingOverlay>
            );
        }
        
        // チェックが終わりかつ
        if (this.state.signedIn) {
            // サインインしてるとき（そのまま表示）
            return this.props.children;
        } else {
            // サインインしてないとき（ログイン画面にリダイレクト）
            return <Redirect to="/signin" />
        }
    }
}

export default Auth;
