/**
 *Created by Mikael Lindahl on 2019-10-08
 */

"use strict";

import React from "react";
import {BrowserRouter as Router, Routes, Route} from "react-router-dom";
import url from "../constants/url";
import Home from "../pages/Home"

const debug = require('debug')('bk-manager:frontend-react:routers:RoutingApp');

/**
 * Main routing for the app
 *
 */
export default function RoutingApp() {


    return (
        <Router>
            <Routes>
                <Route path={`${url.APP_BASE}/`} element={Home()}/>
            </Routes>
        </Router>
    );
}