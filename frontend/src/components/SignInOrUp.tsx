import React, { Component } from 'react';
import { Button, Form, FormGroup, Label, Input, FormFeedback, Spinner } from 'reactstrap';
import { Link, RouteComponentProps } from 'react-router-dom'
import * as H from 'history';
import { Formik } from 'formik';
import * as Yup from 'yup';
import firebase from 'firebase';

interface SignInOrUpState {
    loading: boolean,
}

interface SignInOrUpProps extends RouteComponentProps<{}> {
    history: H.History;
}
    

// ログイン
class SignInOrUp extends Component<SignInOrUpProps, SignInOrUpState> {
    state: SignInOrUpState = {
        loading: false, //処理中にボタンにspinner表示する制御用
    };

    _isMounted: boolean = false;

    // Submitしたとき
    handleOnSubmit = (values: any) => {
        // spinner表示開始
        if (this._isMounted) this.setState({ loading: true });
        // ログイン処理
        firebase.auth().signInWithEmailAndPassword(values.email, values.password)
            .then(res => {
                if (this._isMounted) this.setState({ loading: false });
                this.props.history.push("/");
            })
            .catch(error => {
                if (this._isMounted) this.setState({ loading: false });
                alert(error);
            });
    }

    componentDidMount = () => {
        this._isMounted = true;
    }

    componentWillUnmount = () => {
        this._isMounted = false;
    }

    render() {
        return (
            <div className="container">
                <div className="mx-auto" style={{ width: 400, background: '#eee', padding: 20, marginTop: 60 }}>
                    <p style={{ textAlign: 'center' }}>サインイン</p>
                    <Formik
                        initialValues={{ email: '', password: '' }}
                        onSubmit={(values) => this.handleOnSubmit(values)}
                        validationSchema={Yup.object().shape({
                            email: Yup.string().email().required(),
                            password: Yup.string().required(),
                        })}
                    >
                        {
                            ({ handleSubmit, handleChange, handleBlur, values, errors, touched }) => (
                                <Form onSubmit={handleSubmit}>
                                    <FormGroup>
                                        <Label for="email">Email</Label>
                                        <Input
                                            type="email"
                                            name="email"
                                            id="email"
                                            value={values.email}
                                            onChange={handleChange}
                                            onBlur={handleBlur}
                                            invalid={touched.email && errors.email ? true : false}
                                        />
                                        <FormFeedback>
                                            {errors.email}
                                        </FormFeedback>
                                    </FormGroup>
                                    <FormGroup>
                                        <Label for="password">Password</Label>
                                        <Input
                                            type="password"
                                            name="password"
                                            id="password"
                                            value={values.password}
                                            onChange={handleChange}
                                            onBlur={handleBlur}
                                            invalid={touched.password && errors.password ? true : false}
                                        />
                                        <FormFeedback>
                                            {errors.password}
                                        </FormFeedback>
                                    </FormGroup>
                                    <div style={{ textAlign: 'center' }}>
                                        <Button color="primary" type="submit" disabled={this.state.loading}>
                                            <Spinner size="sm" color="light" style={{ marginRight: 5 }} hidden={!this.state.loading} />
                                            ログイン
                                        </Button>
                                    </div>
                                </Form>
                            )
                        }
                    </Formik>
                </div>
                <div className="mx-auto" style={{ width: 400, background: '#fff', padding: 20 }}>
                    <Link to="/signup">新規登録はこちら</Link>
                </div>
            </div>
        );
    }
}

export default SignInOrUp;
