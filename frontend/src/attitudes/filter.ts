import { Component } from "react";
import {
  EditableText,
  Menu,
  MenuItem,
  Popover,
  Button,
  Position,
} from "@blueprintjs/core";
import h from "@macrostrat/hyper";
//import { db, storedProcedure } from "../database";

const udtmap = {
  varchar: "text",
  int4: "integer",
  float8: "double precision",
  bool: "boolean",
};

const formatType = function (row) {
  let { column_name, data_type, udt } = row;
  if (udt[0] === "_") {
    udt = udt.substring(1);
  }
  const um = udtmap[udt];
  if (um != null) {
    udt = um;
  }

  if (data_type === "ARRAY") {
    data_type = `{${udt}}`;
  }
  if (data_type === "USER-DEFINED") {
    data_type = udt;
  }
  return [column_name, data_type];
};

class FilterPanel extends Component {
  constructor(props) {
    super(props);

    this.setupTypes = this.setupTypes.bind(this);
    this.onChange = this.onChange.bind(this);
    this.onConfirm = this.onConfirm.bind(this);
    this.state = {
      dataTypes: [],
      value: this.props.query,
    };

    // db.query(storedProcedure("column-types"))
    //   .map(formatType)
    //   .then(this.setupTypes);
  }

  setupTypes(dataTypes) {
    console.log(dataTypes);
    return this.setState({ dataTypes });
  }

  componentWillReceiveProps(nextProps) {
    const { query } = nextProps;
    if (query !== this.state.value) {
      return this.setState({ value: query.trim() });
    }
  }

  render() {
    return h("div.data-filter", [
      h("h4", "Filter data"),
      h(EditableText, {
        multiline: true,
        value: this.state.value,
        className: "code-window filter-window",
        onConfirm: this.onConfirm,
        onChange: this.onChange,
      }),
      h(Popover, { content: this.menu(), position: Position.RIGHT }, [
        h(Button, { text: "Stored query", iconName: "database" }),
      ]),
      this.columnDefs(),
    ]);
  }

  menu() {
    return h(
      Menu,
      app.subqueryIndex.map((d) =>
        h(MenuItem, {
          text: d.name,
          onClick() {
            return app.runQuery(d.sql);
          },
        })
      )
    );
  }

  columnDefs() {
    const createRow = function (args, el) {
      if (el == null) {
        el = "td";
      }
      const [column, type] = args;
      return h("tr", [h(el, column), h(el, type)]);
    };

    const head = { column: "Column", type: "Type" };
    return h("div.data-types", [
      h("table.pt-table.pt-striped", [
        h("thead", {}, createRow(["Column", "Type"], "th")),
        h(
          "tbody",
          this.state.dataTypes.map((d) => createRow(d, "td"))
        ),
      ]),
    ]);
  }

  onChange(value) {
    return this.setState({ value });
  }

  onConfirm(value) {
    if (value === this.props.value) {
      return;
    }
    return app.runQuery(value);
  }

  reset() {
    return app.runQuery(app.defaultSubquery);
  }
}

module.exports = FilterPanel;
