/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from "react";
import Infinite from "react-infinite";
import { Link } from "react-router";
import * as d3 from "d3";
require("d3-selection-multi");

import style from "./main.styl";

//import StereonetView from "../../controls/stereonet";

class ListItem extends React.Component {
  constructor(...args) {
    super(...args);
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    console.log(this.props.data);
    return app.data.selection.update(this.props.data);
  }

  render() {
    const clsname = this.props.selected ? "selected" : "";
    return h(
      "div",
      {
        onClick: this.handleClick,
        className: clsname,
      },
      this.props.selected ? "selected" : this.props.data.id
    );
  }
}

class AttitudeList extends React.Component {
  constructor(...args) {
    super(...args);
    this.__renderChild = this.__renderChild.bind(this);
  }

  __renderChild(d, i) {
    const sel = app.data.selection.records;
    return h(ListItem, {
      data: d,
      key: d.id,
      selected: this.props.selection.indexOf(d) !== -1,
    });
  }

  render() {
    return h(
      "div",
      null,
      h("h1", null, "Attitudes"),
      h(
        Infinite,
        {
          className: style.list,
          containerHeight: 500,
          elementHeight: 20,
        },
        this.props.data.map(this.__renderChild)
      )
    );
  }
}

class StereonetPage extends React.Component {
  constructor(props) {
    this.updateSelection = this.updateSelection.bind(this);
    super(props);
    const recs = this.props.data.records().filter((d) => d.group == null);
    this.state = {
      records: recs,
      selection: app.data.selection.records,
    };
  }

  updateSelection() {
    return this.setState({
      selection: app.data.selection.records,
    });
  }

  componentDidMount() {
    return this.props.data.selection.bind(
      "selection:updated",
      this.updateSelection
    );
  }

  componentWillUnmount() {
    return this.props.data.selection.unbind(
      "selection:updated",
      this.updateSelection
    );
  }

  render() {
    // Filter data so that attitudes that are
    // part of a group are not included in
    // selection
    const recs = this.props.data.records().filter((d) => d.group == null);
    return h(
      "div",
      {
        className: style.wrap,
      },
      h(
        "div",
        {
          className: style.sidebar,
        },
        [
          h(
            Link,
            {
              className: style.homeLink,
              to: "/",
            },
            h("i", {
              className: "fa fa-home",
            }),
            " Home"
          ),
          h(AttitudeList, {
            data: this.state.records,
            selection: this.state.selection,
          }),
        ]
      ),
      h(
        "div",
        {
          className: style.main,
        }
        // h(StereonetView, {
        //   data: this.state.selection,
        // })
      )
    );
  }
}

module.exports = StereonetPage;
