import * as d3 from "d3";
import React from "react";
import style from "./style.styl";
import { Tag, Table } from "@blueprintjs/core";
import h from "@macrostrat/hyper";
const f = d3.format(">.1f");

class ListItem extends React.Component {
  constructor(...args) {
    super(...args);
    this.createRemoveButton = this.createRemoveButton.bind(this);
    this.isHovered = this.isHovered.bind(this);
    this.mousein = this.mousein.bind(this);
    this.mouseout = this.mouseout.bind(this);
  }

  static initClass() {
    this.prototype.defaultProps = {
      allowRemoval: false,
    };
  }

  render() {
    const {
      strike,
      dip,
      grouped,
      max_angular_error,
      min_angular_error,
      hovered,
      measurements,
    } = this.props.data;
    let cls = "list-item";

    if (hovered) {
      cls += ` ${style.hovered}`;
    } // This is crazy-inefficient

    return h(
      "tr",
      {
        className: cls,
        onClick: this.props.focusItem,
        onMouseEnter: this.mousein,
      },
      [
        h("td", null, f(strike)),
        h("td", null, f(dip)),
        h("td", null, f(max_angular_error)),
        h("td", null, f(min_angular_error)),
        h(
          "td",
          null,
          grouped
            ? h(Tag, null, [measurements.length, " attitudes"])
            : undefined
        ),
        this.props.allowRemoval ? this.createRemoveButton() : undefined,
      ]
    );
  }

  createRemoveButton() {
    return h(
      "td",
      {
        className: "remove",
        onClick: this.props.removeItem,
      },
      h("i", {
        className: "fa fa-remove",
      })
    );
  }

  isHovered() {
    return app.data.isHovered(this.props.data);
  } // These handlers need some reworking
  // but can probably stand for now

  mousein() {
    return app.data.hovered(this.props.data, true);
  }

  mouseout() {
    return app.data.hovered(this.props.data, false);
  }
}

ListItem.initClass();

class SelectionList extends React.Component {
  constructor(...args) {
    super(...args);
    this.renderItem = this.renderItem.bind(this);
  }

  static initClass() {
    this.prototype.defaultProps = {
      focusItem() {},

      removeItem() {},

      allowRemoval: false,
    };
  }

  renderItem(d) {
    const onRemove = (event) => {
      this.props.removeItem(d);
      return event.stopPropagation();
    };

    const onFocus = () => {
      return this.props.focusItem(d);
    };

    h = false;

    if (this.props.hovered != null) {
      h = d.id === this.props.hovered.id;
    }

    return h(ListItem, {
      data: d,
      key: d.id,
      focusItem: onFocus,
      removeItem: onRemove,
      allowRemoval: this.props.allowRemoval,
    });
  }

  render() {
    return h(
      "table.bp3-html-table-condensed.bp3-html-table.bp3-html-table-striped",
      [
        h("thead", null, [
          h("tr", null, [
            h("td", null, "Str"),
            h("td", null, "Dip"),
            h(
              "td",
              {
                colSpan: "2",
              },
              "Errors (\xBA)"
            ),
            h("td", null, "Info"),
            this.props.allowRemoval ? h("td", null) : undefined,
          ]),
        ]),
        h("tbody", null, this.props.records.map(this.renderItem)),
      ]
    );
  }
}

SelectionList.initClass();
module.exports = SelectionList;
