import React from "react";
import $ from "jquery";
import * as d3 from "d3";
import SelectionList from "./list";
import { Button, Intent } from "@blueprintjs/core";
import h from "@macrostrat/hyper";
const sf = d3.format(">8.1f");
const df = d3.format(">6.1f");

const strikeDip = function (d) {
  const strike = sf(d.strike);
  const dip = df(d.dip);
  return h("span", null, [
    h(
      "span",
      {
        className: "strike",
      },
      strike,
      "\xBA"
    ),
    " ",
    h(
      "span",
      {
        className: "dip",
      },
      dip,
      "\xBA"
    ),
  ]);
};

class GroupedAttitudeControl extends React.Component {
  constructor(...args) {
    super(...args);
    this.shouldDestroyGroup = this.shouldDestroyGroup.bind(this);
  }

  render() {
    // Group type selector should go here...
    const rec = app.data.get(...this.props.data.measurements);
    return h("div", null, [
      h("h6", null, "Component planes"),
      h(SelectionList, {
        records: rec,
        hovered: this.props.hovered,
      }),
      h(
        "p",
        null,
        h(
          Button,
          {
            intent: Intent.DANGER,
            iconName: "ungroup",
            onClick: this.shouldDestroyGroup,
          },
          "Ungroup"
        )
      ),
    ]);
  }

  shouldDestroyGroup() {
    return app.data.destroyGroup(this.props.data.id);
  }
}

class DataViewer extends React.Component {
  static initClass() {
    this.defaultProps = {
      hovered: false,

      focusItem() {},

      data: null,
    };
  }

  constructor(props) {
    super(props);
    this.onNetworkData = this.onNetworkData.bind(this);
    this.state = {
      content: h("span.loading", null, "Loading..."),
    };
  }

  componentDidMount() {
    if (this.props.data == null) {
      return this.setState({
        content: h("p", null, "Hover over data to display fit statistics."),
      });
    } else {
      const url = `${process.env.ORIENTEER_API_BASE}/elevation/attitude/${this.props.data.id}/data.html`;
      return $.get(url, this.onNetworkData);
    }
  }

  onNetworkData(data) {
    const c = h("div", {
      dangerouslySetInnerHTML: {
        __html: data,
      },
    });
    return this.setState({
      content: c,
    });
  }

  renderGroupData() {
    return h(GroupedAttitudeControl, {
      data: this.props.data,
      hovered: this.props.hovered,
    });
  }

  render() {
    const grouped = this.props.data.is_group;
    const method = grouped ? this.props.focusItem : function () {};
    return h("div", null, [
      h("h4", null, [grouped ? "Group" : "Attitude", " ", this.props.data.id]),
      h(SelectionList, {
        records: [this.props.data],
        focusItem: method,
      }),
      grouped ? this.renderGroupData() : undefined,
      h("div.data-container", [
        h("h6", null, "Axis-aligned residuals"),
        h("img", {
          src: `${process.env.ORIENTEER_API_BASE}/elevation/attitude/${this.props.data.id}/axis-aligned.png`,
        }),
      ]),
    ]);
  }
}

export default DataViewer;
