/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Spine = require("spine");
const $ = require("jquery");
const GIS = require("gis-core");
const L = GIS.Leaflet;

const React = require("react");
const ReactDOM = require("react-dom");

const styles = require("./styles");
const Sidebar = require("./sidebar");
const DataLayer = require("./data-layer");

let oldLoc = null;

class EditorPage extends Spine.Controller {
  constructor() {
    this.setupEditor = this.setupEditor.bind(this);
    this.setSelected = this.setSelected.bind(this);
    super();
    this.el.addClass(styles.page);

    this.state = {
      selected: null,
      editing: false,
    };

    const cfg = app.config.map;
    if (cfg.basedir == null) {
      cfg.basedir = path.dirname(app.config.configFile);
    }

    const toolbarHandlers = {
      edit: this.setupEditor,
      cancel: () => this.setSelected(null),
    };

    const editHandlers = {
      onChangeType: (t) => {
        console.log("Changing target type");
        return this.lyr.editor.setState({ type: t });
      },
      onFinish: () => this.lyr.editor.finalize(),
    };

    console.log(editHandlers);

    const sidebar = React.createElement(Sidebar, {
      toolbarHandlers,
      newHandler: this.setupEditor,
      editHandlers,
    });

    this.sidebar = ReactDOM.render(sidebar, this.el[0]);

    const mapContainer = $("<div />").addClass("flex").appendTo(this.el);

    cfg.boxZoom = false;
    this.map = new GIS.Map(mapContainer[0], cfg);
    window.map = this.map;
    this.map.addLayerControl();
    this.map.addScalebar();
    this.map.invalidateSize();

    window.onresize = () => {
      return this.map.invalidateSize();
    };

    this.lyr = new DataLayer();
    this.lyr.addTo(this.map);
    this.lyr.events.on("selected", this.setSelected);
  }

  setupEditor() {
    this.lyr.setupEditor(this.state.selected);

    this.state.editing = {
      enabled: true,
      complete: this.state.selected != null,
      targetType: "Polygon",
    };

    this.state.item = { type: "Feature", geometry: null };

    return this.sidebar.setState(this.state);
  }

  setSelected(d) {
    this.state.selected = d;
    if (d != null) {
      oldLoc = [this.map.getCenter(), this.map.getZoom()];
      this.map.fitBounds(L.geoJson(d));
    } else if (oldLoc != null) {
      this.map.setView(oldLoc[0], oldLoc[1], { animation: false });
    }
    this.lyr.setSelected(d);
    return this.sidebar.setState({ item: d });
  }
}

module.exports = EditorPage;
