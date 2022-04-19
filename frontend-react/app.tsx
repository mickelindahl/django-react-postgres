import "@babel/polyfill";

import React from "react";
import ReactDOM from "react-dom";
import RoutingApp from "./routers/RoutingApp.jsx";
import enableDebug from "./lib/enableDebug.jsx";

enableDebug();

/**
 * Main app for config tool
 *
 * @returns {*}
 * @constructor
 */
const App = () => {

    return <RoutingApp/>
};

const wrapper = document.getElementById("app");
wrapper ? ReactDOM.render(<App/>, wrapper) : null;