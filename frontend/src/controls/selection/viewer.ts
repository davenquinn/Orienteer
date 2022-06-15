import React from "react";
import $ from "jquery";
import * as d3 from "d3";
import SelectionList from "./list";
import { Button, Intent } from "@blueprintjs/core";
import h from "@macrostrat/hyper";
import { useAppDispatch, useAppState } from "app/data-manager";
import { GroupedAttitude } from "app/data-manager/types";
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

function GroupedAttitudeControl(props: {
  data: GroupedAttitude;
  hovered: boolean;
}) {
  const dispatch = useAppDispatch();
  const { data, hovered } = props;
  const records = useAppState((d) =>
    d.data.filter((d) => data.measurements.includes(d.id))
  );
  // Group type selector should go here...

  return h("div", null, [
    h("h5", null, "Component planes"),
    h(SelectionList, {
      records,
      hovered,
    }),
    h(
      "p",
      null,
      h(
        Button,
        {
          intent: Intent.DANGER,
          iconName: "ungroup",
          onClick() {
            dispatch({ type: "destroy-group", attitude: props.data });
          },
        },
        "Ungroup"
      )
    ),
  ]);
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

  render() {
    const grouped = this.props.data.is_group;
    const method = grouped ? this.props.focusItem : function () {};
    return h("div", null, [
      h("h4", null, [grouped ? "Group" : "Attitude", " ", this.props.data.id]),
      h(SelectionList, {
        records: [this.props.data],
        focusItem: method,
      }),
      h.if(grouped)(GroupedAttitudeControl, {
        data: this.props.data,
        hovered: this.props.hovered,
      }),
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
