import React from "react";
import { createRoot } from 'react-dom/client';
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

// const wrapper = document.getElementById("app");
// wrapper ? ReactDOM.render(<App/>, wrapper) : null;

const container = document.getElementById('app');
if(container){
  const root = createRoot(container!); // createRoot(container!) if you use TypeScript
root.render(<App/>);

}



// import { createRoot } from 'react-dom/client';
// const container = document.getElementById('app');
// const root = createRoot(container); // createRoot(container!) if you use TypeScript
// root.render(<App tab="home" />);