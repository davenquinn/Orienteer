import * as d3 from "d3";
import React from "react";
import style from "./style.styl";
import h from "@macrostrat/hyper";
import { Tag } from "@blueprintjs/core";

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
    this.prototype.defaultProps = { allowRemoval: false };
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
    }

    // This is crazy-inefficient
    return (
      <tr
        className={cls}
        onClick={this.props.focusItem}
        onMouseEnter={this.mousein}
      >
        <td>{f(strike)}</td>
        <td>{f(dip)}</td>
        <td>{f(max_angular_error)}</td>
        <td>{f(min_angular_error)}</td>
        <td>
          {grouped ? <Tag>{measurements.length} attitudes</Tag> : undefined}
        </td>
        {this.props.allowRemoval ? this.createRemoveButton() : undefined}
      </tr>
    );
  }

  createRemoveButton() {
    return (
      <td className="remove" onClick={this.props.removeItem}>
        <i className="fa fa-remove"></i>
      </td>
    );
  }

  isHovered() {
    return app.data.isHovered(this.props.data);
  }
  // These handlers need some reworking
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
    return (
      <ListItem
        data={d}
        key={d.id}
        focusItem={onFocus}
        removeItem={onRemove}
        allowRemoval={this.props.allowRemoval}
      />
    );
  }

  render() {
    return (
      <table
        className={"pt-table pt-striped pt-condensed selection-list-table"}
      >
        <thead>
          <tr>
            <td>Str</td>
            <td>Dip</td>
            <td colSpan="2">Errors (º)</td>
            <td>Info</td>
            {this.props.allowRemoval ? <td></td> : undefined}
          </tr>
        </thead>
        <tbody>{this.props.records.map(this.renderItem)}</tbody>
      </table>
    );
  }
}
SelectionList.initClass();

module.exports = SelectionList;
