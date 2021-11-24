/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const $ = require("jquery");

window.server_url = "http://0.0.0.0:8000";

const h = require("react-hyperscript");
const React = require("react");
const ReactDOM = require("react-dom");
const { HashRouter, Route, Link } = require("react-router-dom");
let { remote } = require("electron");
const { FocusStyleManager } = require("@blueprintjs/core");
const setupMenu = require("./menu");
const Map = require("./controls/map");
const Frontpage = require("./frontpage");
const Data = require("./data-manager");
const AttitudePage = require("./attitudes");
const Stereonet = require("./endpoints/stereonet");
const LogHandler = require("./log-handler");
const update = require("immutability-helper");
const yaml = require("js-yaml");
const { readFileSync } = require("fs");
const styles = require("./styles/layout.styl");
({ remote } = require("electron"));

FocusStyleManager.onlyShowFocusOnTabs();

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

    const { state } = remote.app;
    this.state = {
      query,
      featureTypes: [],
      showSidebar: false,
      records: [],
      ...state,
    };

    setupMenu(this);

    this.log = new LogHandler();

    // Share config from main process
    // Config can't be edited at runtime
    const c = remote.app.config;
    this.config = JSON.parse(JSON.stringify(c));
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

    return h("div#root", [
      h(Route, { path: "/", component: Frontpage, exact: true }),
      h(Route, { path: "/map", render: attitude }),
      h(Route, { path: "/stereonet", component: DataStereonet }),
    ]);
  }
}

const Router = () => h(HashRouter, [h(App)]);

ReactDOM.render(
  React.createElement(Router),
  document.getElementById("wrapper")
);
