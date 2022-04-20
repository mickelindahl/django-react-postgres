import React from "react";
import ReactDOM from "react-dom";
import RoutingApp from "./routers/RoutingApp";
import enableDebug from "./lib/enableDebug";

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