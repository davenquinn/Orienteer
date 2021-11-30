import { useState, Component } from "react";
import MapControl from "../controls/map";
import SelectionControl from "../controls/selection";
import DataPane from "./data-pane";
import h from "@macrostrat/hyper";
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
import FilterPanel from "./filter";
import MapDataLayer from "../controls/map-data-layer";
import { useAppState, useAppDispatch } from "app/hooks";
import * as d3 from "d3";

import style from "./style.styl";

const f = d3.format("> 6.1f");

const paneStyle = {
  display: "flex",
  flexDirection: "column",
};

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
    },
    [
      h(Tab, {
        id: 1,
        title: "Selection",
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
        id: 2,
        title: "Data",
        panel: h(DataPane, {
          records: selection,
          hovered,
          featureTypes,
        }),
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
      pane1 = h(MapControl, { settings: this.props.settings.map }, [
        h(MapDataLayer, { records }),
      ]);
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
