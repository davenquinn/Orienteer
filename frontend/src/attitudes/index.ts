import { useState, Component } from "react";
import MapControl from "../controls/map";
import SelectionControl from "../controls/selection";
import DataPane from "./data-pane";
import { hyperStyled } from "@macrostrat/hyper";
import SplitPane from "react-split-pane";
import {
  Tab,
  Tabs,
  Hotkey,
  Hotkeys,
  HotkeysTarget,
  Button,
  Navbar,
} from "@blueprintjs/core";
import FilterPanel from "./filter-pane";
import MapDataLayer from "../controls/map-data-layer";
import { useAppState, useAppDispatch } from "app/hooks";
import * as d3 from "d3";
import styles from "./style.module.styl";
const h = hyperStyled(styles);

const f = d3.format("> 6.1f");

const paneStyle = {
  display: "flex",
  flexDirection: "column",
};

function ClearSelectionButton() {
  const dispatch = useAppDispatch();
  const hasSelection = useAppState((d) => d.selected.size > 0);
  if (!hasSelection) return null;
  return h(
    Button,
    {
      className: "clear-selection",
      minimal: true,
      icon: "cross",
      intent: "danger",
      onClick: () => {
        dispatch({ type: "clear-selection" });
      },
      style: {
        backgroundColor: "white",
        border: "2px solid rgba(0,0,0,0.2)",
      },
    },
    "Clear selection"
  );
}

function SidebarTab(props) {
  const { panel, ...rest } = props;
  return h(Tab, rest, h("div.sidebar-tab", null, panel));
}

function AttitudesPageSidebar(props) {
  const { featureTypes, query } = props;
  const { data, selected, hovered } = useAppState();
  const [selectedTabId, onChangeTab] = useState(1);
  const selection = Array.from(selected);
  //const openGroupViewer = () => this.setState({ showGroupInfo: true });

  ///let { showGroupInfo } = this.state;

  return h(
    Tabs,
    {
      className: "sidebar-outer",
      selectedTabId,
      onChange: onChangeTab,
      renderActiveTabPanelOnly: true,
    },
    [
      h(Tab, {
        id: 1,
        title: "Data",
        panel: h(DataPane, {
          records: selection,
          hovered,
          featureTypes,
        }),
      }),
      h(Tab, {
        id: 2,
        title: "Details",
        panel: h(
          SelectionControl,
          {
            records: selection,
            //openGroupViewer,
          },
          hovered
        ),
      }),
      h(Tab, {
        id: 3,
        title: "Filter",
        panel: h(FilterPanel, { query }),
      }),
      h(Tab, { id: 4, title: "Options", panel: h("div") }),
    ]
  );
}

class AttitudePage extends Component {
  constructor(props) {
    super(props);
    this.onChangeTab = this.onChangeTab.bind(this);
    this.onResizePane = this.onResizePane.bind(this);
    this.state = { splitPosition: 350, selectedTabId: 1, showGroupInfo: false };
  }

  render() {
    let pane1;
    const { records, featureTypes, query, showSidebar, toggleSidebar } =
      this.props;

    let { showGroupInfo } = this.state;

    if (!showGroupInfo) {
      pane1 = h(
        MapControl,
        { settings: this.props.settings.map, toggleSidebar },
        [h(MapDataLayer, { records }), h(ClearSelectionButton)]
      );
    } else {
      pane1 = h("div", [h(Navbar, [h(Button, {}, "Close pane")])]);
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
      [pane1, h(AttitudesPageSidebar, { featureTypes, query })]
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
        onKeyDown: null,
      }),
    ]);
  }
}

HotkeysTarget(AttitudePage);

export default AttitudePage;
