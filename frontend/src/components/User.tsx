import React, { Component } from 'react';

interface UserProps {
    id: number
    name: string
    image: string
}

interface UserState {
    user: {
        id: number
        name: string
        image: string
    }
}

// User自体のコンポーネント
class User extends Component<UserProps, UserState> {
    constructor(props: any) {
        super(props);
        this.state = {
            user: {
                id: props.id,
                name: props.name,
                image: props.image,
            }
        };
    }

    render() {
        return (
            <div id="user-component">
                <div id="user-name">{this.state.user.name}</div>
                <div id="user-image">{this.state.user.image}</div>
            </div>
        );
    }
}

export default User;
