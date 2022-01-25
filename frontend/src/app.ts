import h from "@macrostrat/hyper";
import { BrowserRouter as Router, Route, Link } from "react-router-dom";
import { FocusStyleManager } from "@blueprintjs/core";
//import setupMenu from "./menu";
//import Map from "./controls/map";
//import Frontpage from "./frontpage";
import { DataManager, AppDataProvider, useAppState } from "./data-manager";
import AttitudePage from "./attitudes";
// import Stereonet from "./endpoints/stereonet";
// import LogHandler from "./log-handler";
// import update from "immutability-helper";
// import yaml from "js-yaml";
// import { readFileSync } from "fs";
//import styles from "./styles/layout.styl";

FocusStyleManager.onlyShowFocusOnTabs();

/*
class App extends React.Component {
  constructor() {
    super();
    window.app = this;
    this.API = require("./api");
    this.opts = require("./options");

    this.config = remote.getGlobal("config");

    const _ = readFileSync(`${__dirname}/sql/stored-filters.yaml`, "utf8");
    this.subqueryIndex = yaml.load(_);

    const query = this.subqueryIndex[0].sql;

    //const { state } = remote.app;
    this.state = {
      query,
      featureTypes: [],
      showSidebar: false,
      records: [],
    };

    //setupMenu(this);

    this.log = new LogHandler();

    // Share config from main process
    // Config can't be edited at runtime
    //const c = remote.app.config;
    this.config = {}; ///JSON.parse(JSON.stringify(c));
    this.data = new Data({
      logger: this.log,
      onUpdated: this.updateData.bind(this),
    });
    this.data.getData();

    if (this.state.settings == null) {
      this.state.settings = {};
    }

    if (this.state.settings.map == null) {
      this.state.settings.map = { bounds: null };
    }
  }

  runQuery(query) {
    if (query === this.state.query) {
      return;
    }
    this.setState({ query });
    return this.data.getData(query);
  }

  require(m) {
    //# App-scoped require to preclude nesting
    return require(`./${m}`);
  }

  updateData(changes) {
    return this.setState(changes);
  }

  updateSettings(spec) {
    const newState = update(this.state.settings, spec);
    return this.setState({ settings: newState });
  }

  toggleSidebar() {
    return this.setState({ showSidebar: !this.state.showSidebar });
  }

  render() {
    const { settings, records, query, featureTypes, showSidebar } = this.state;
    const { toggleSidebar } = this;
    console.log("Re-rendering app with state", this.state);

    class DataStereonet extends React.Component {
      render() {
        return h(Stereonet, { settings, records });
      }
    }

    const attitude = () =>
      h(AttitudePage, {
        settings,
        records,
        query,
        featureTypes,
        showSidebar,
        toggleSidebar,
      });
    // The other pages of the app don't work right now
    return attitude();

    // return h("div#root", [
    //   h(Route, { path: "/", component: Frontpage, exact: true }),
    //   h(Route, { path: "/map", render: attitude }),
    //   h(Route, { path: "/stereonet", component: DataStereonet }),
    // ]);
  }
}
*/

export const canaryText =
  "This element is used to test whether the app has successfully rendered.";

export default function AppRouter() {
  return h(AppDataProvider, null, h(Router, [h(App)]));
}

const App = () => {
  const data = useAppState((state) => state.data);
  if (data == null) {
    return null;
  }

  return h("div.root", [
    h("div.canary", { style: { display: "none" } }, canaryText),
    h(AttitudePage, {
      settings: {},
      records: data,
      query: "",
      featureTypes: [],
      showSidebar: true,
      //toggleSidebar,
    }),
  ]);
};
