/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Spine = require("spine");
const React = require("react");
const ReactDOM = require("react-dom");
const MapControl = require("../controls/map");
const SelectionControl = require("../controls/selection");
const DataPane = require("./data-pane");
const h = require("react-hyperscript");
const SplitPane = require("react-split-pane");
const {
  Tab2,
  Tabs2,
  Hotkey,
  Hotkeys,
  HotkeysTarget,
  Button,
  Toolbar,
} = require("@blueprintjs/core");
const FilterPanel = require("./filter");
const MapDataLayer = require("../controls/map-data-layer");

const d3 = require("d3");
const $ = require("jquery");

const style = require("./style.styl");

const f = d3.format("> 6.1f");

const paneStyle = {
  display: "flex",
  flexDirection: "column",
};

class AttitudePage extends React.Component {
  constructor(props) {
    this.onChangeTab = this.onChangeTab.bind(this);
    this.onResizePane = this.onResizePane.bind(this);
    super(props);
    this.state = { splitPosition: 350, selectedTabId: 1, showGroupInfo: false };
  }

  render() {
    let pane1, panels;
    const { records, featureTypes, query, showSidebar, toggleSidebar } =
      this.props;
    const selection = records.filter((d) => d.selected);
    const hovered = records.find((d) => d.hovered);
    const openGroupViewer = () => this.setState({ showGroupInfo: true });

    const selectionPanel = h(
      SelectionControl,
      {
        records: selection,
        openGroupViewer,
      },
      hovered
    );

    const dataManagementPanel = h(DataPane, {
      records: selection,
      hovered,
      featureTypes,
    });

    let { selectedTabId, showGroupInfo } = this.state;

    if (this.state.splitPosition < 600) {
      panels = [
        h(Tab2, { id: 1, title: "Selection", panel: selectionPanel }),
        h(Tab2, { id: 2, title: "Data", panel: dataManagementPanel }),
      ];
    } else {
      if (selectedTabId === 2) {
        selectedTabId = 1;
      }
      panels = [
        h(Tab2, {
          id: 1,
          title: "Selection / Data",
          panel: h("div.combined-panel", [selectionPanel, dataManagementPanel]),
        }),
      ];
    }

    if (!showGroupInfo) {
      pane1 = h(MapControl, { settings: this.props.settings.map }, [
        h(MapDataLayer, { records }),
      ]);
    } else {
      pane1 = h("div", [h(Toolbar, [h(Button, {}, "Close pane")])]);
    }

    return h(
      SplitPane,
      {
        split: "vertical",
        minSize: 350,
        defaultSize: this.state.splitPosition,
        primary: "second",
        paneStyle,
        pane2Style: showSidebar ? {} : { display: "none" },
        onChange: this.onResizePane,
      },
      [
        pane1,
        h(
          Tabs2,
          {
            className: "sidebar-outer",
            selectedTabId,
            onChange: this.onChangeTab,
          },
          [
            ...panels,
            h(Tab2, {
              id: 3,
              title: "Filter",
              panel: h(FilterPanel, { query }),
            }),
            h(Tab2, { id: 4, title: "Options", panel: h("div") }),
          ]
        ),
      ]
    );
  }

  onChangeTab(selectedTabId) {
    return this.setState({ selectedTabId });
  }

  onResizePane(size) {
    this.setState({ splitPosition: size });
    return console.log(size);
  }

  renderHotkeys() {
    return h(Hotkeys, [
      h(Hotkey, {
        label: "Clear selection",
        combo: "backspace",
        global: true,
        onKeyDown: app.data.clearSelection,
      }),
    ]);
  }
}

HotkeysTarget(AttitudePage);

module.exports = AttitudePage;