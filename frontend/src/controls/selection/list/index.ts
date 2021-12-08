import * as d3 from "d3";
import React from "react";
import styles from "./style.module.styl";
import { Tag, Table } from "@blueprintjs/core";
import { hyperStyled } from "@macrostrat/hyper";
const f = d3.format(">.1f");
import { useAppDispatch } from "app/hooks";

const h = hyperStyled(styles);

function ListItem(props) {
  const dispatch = useAppDispatch();
  const { data } = props;
  const {
    strike,
    dip,
    grouped,
    max_angular_error,
    min_angular_error,
    hovered,
    measurements,
  } = data;
  let cls = "list-item";

  if (hovered) {
    cls += ` ${styles.hovered}`;
  } // This is crazy-inefficient

  return h(
    "tr",
    {
      className: cls,
      onClick: props.focusItem,
      onMouseEnter: () => dispatch({ type: "hover", data }),
    },
    [
      h("td", null, f(strike)),
      h("td", null, f(dip)),
      h("td", null, f(max_angular_error)),
      h("td", null, f(min_angular_error)),
      h(
        "td",
        null,
        grouped ? h(Tag, null, [measurements.length, " attitudes"]) : undefined
      ),
      props.allowRemoval ? h(RemoveButton, props) : undefined,
    ]
  );
}

function RemoveButton(props) {
  const { removeItem } = props;
  return h(
    "td",
    {
      className: "remove",
      onClick: removeItem,
    },
    h("i", {
      className: "fa fa-remove",
    })
  );
}

class SelectionList extends React.Component {
  constructor(...args) {
    super(...args);
    this.renderItem = this.renderItem.bind(this);
  }

  static defaultProps = {
    focusItem() {},

    removeItem() {},

    allowRemoval: false,
  };

  renderItem(d) {
    const onRemove = (event) => {
      this.props.removeItem(d);
      return event.stopPropagation();
    };

    const onFocus = () => {
      return this.props.focusItem(d);
    };

    let hovered = false;

    if (this.props.hovered != null) {
      hovered = d.id === this.props.hovered.id;
    }

    return h(ListItem, {
      data: d,
      key: d.id,
      focusItem: onFocus,
      removeItem: onRemove,
      allowRemoval: this.props.allowRemoval,
      hovered,
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

export default SelectionList;
