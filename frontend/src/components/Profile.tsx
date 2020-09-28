import React, { Component } from 'react';
import { Link } from 'react-router-dom'

// プロフィール画面
class Profile extends Component<{}, {}> {

    componentDidMount() {
    }

    render() {
        return (
            <div>
                Profile
                <Link to="/">Homeへ</Link>
            </div>
        );
    }
}

export default Profile;
