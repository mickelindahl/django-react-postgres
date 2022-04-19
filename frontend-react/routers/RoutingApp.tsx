/**
 *Created by Mikael Lindahl on 2019-10-08
 */

"use strict";

import React from "react";
import {BrowserRouter as Router, Route} from "react-router-dom";
import url from "../constants/url.jsx";
const debug = require('debug')('bk-manager:frontend-react:routers:RoutingApp');

function Home() {

    return (
        <div className={'container'}>
            <h1>Home</h1>
            <p>Hello World</p>
        </div>
    )
}

/**
 * Main routing for the app
 *
 */
export default function RoutingApp() {


    return (
        <Router>
            <div>
                <Route path={`${url.APP_BASE}/home`} element={Home()}/>
            </div>
        </Router>
    );
}