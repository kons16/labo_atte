import React from 'react';
import './App.css';
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom';

import Home from './components/Home';
import Profile from './components/Profile';
import SignInOrUp from './components/SignInOrUp';
import SignUp from './components/SignUp';
import Auth from './Auth';

import firebase from 'firebase';
import {firebaseConfig} from './firebase/config';

firebase.initializeApp(firebaseConfig);

function App() {
  return (
    <div className="App">
      <Router>
        <Switch>
          <Route exact path="/signin" component={SignInOrUp} />
          <Route exact path="/signup" component={SignUp} />

          <Auth>
            <Switch>
                <Route exact path="/" component={Home} />
                <Route exact path="/profile" component={Profile} />
                <Route render={() => <p>not found.</p>} />
            </Switch>
          </Auth>
        </Switch>
      </Router>
    </div>
  );
}

export default App;
