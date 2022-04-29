import React from "react";
import { createRoot } from 'react-dom/client';
import RoutingApp from "./routers/RoutingApp";
import enableDebug from "./lib/enableDebug";
import store from './redux/store'
import DataProvider from "./components/DataProvider";
import { Provider } from 'react-redux'
import url from "./constants/url"

enableDebug();

/**
 * Main app for config tool
 *
 * @returns {*}
 * @constructor
 */
const App = () => {

    return <DataProvider endpoint={url.APP_STATE} render={()=><RoutingApp/>}/>
};

// const wrapper = document.getElementById("app");
// wrapper ? ReactDOM.render(<App/>, wrapper) : null;

const container = document.getElementById('app');
if(container){
  const root = createRoot(container!); // createRoot(container!) if you use TypeScript
    root.render(
        <Provider store={store}>
            <App/>
        </Provider>
    );

}



// import { createRoot } from 'react-dom/client';
// const container = document.getElementById('app');
// const root = createRoot(container); // createRoot(container!) if you use TypeScript
// root.render(<App tab="home" />);