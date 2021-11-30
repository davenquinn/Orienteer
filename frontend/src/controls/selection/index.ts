/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
//GroupedDataControl = require "./grouped-data"
import SelectionList from "./list";
import ViewerControl from "./viewer";
import React from "react";
import style from "./style.styl";
import { NonIdealState, Button } from "@blueprintjs/core";
import h from "@macrostrat/hyper";
import { useAppDispatch, useAppState } from "~/hooks";

function SelectionControl(props) {
  const dispatch = useAppDispatch();
  const a = props.actions;
  return h(
    "div",
    {
      className: `${style.sidebar}`,
    },
    [
      h("h3", null, "Selection"),
      h(SelectionList, {
        records: props.records,
        hovered: props.hovered,
        removeItem: a.removeItem,
        focusItem: a.focusItem,
        allowRemoval: true,
      }),
      h("p", null, [
        h(
          "button",
          {
            className:
              "group pt-button pt-intent-primary pt-icon-group-objects",
            onClick: () =>
              dispatch({
                type: "group-selected",
              }),
          },
          "Group measurements"
        ),
      ]),
    ]
  );
}

function CloseButton(props) {
  const { focused } = props;
  const inFocus = focused != null;
  const name = inFocus ? "focus" : "selection";
  const dispatch = useAppDispatch();

  return h(
    Button,
    {
      intent: "danger",
      icon: inFocus ? "chevron-left" : "cross",
      onClick() {
        dispatch({ type: `clear-${name}` });
      },
    },
    `Clear ${name}`
  );
}

function Sidebar(props) {
  const dispatch = useAppDispatch();
  const focused = useAppState((d) => d.focused);
  const hovered = useAppState((d) => d.hovered);

  let core;
  const rec = props.records; // Render nothing for empty selection

  if (rec.length === 0) {
    return h(NonIdealState, {
      title: "No items selected",
      description: "Select some items on the map",
      visual: "send-to-map",
    });
  }

  const focusItem = (item) => dispatch({ type: "focus-item", data: item });

  if (focused != null) {
    core = h(ViewerControl, {
      data: focused,
      hovered,
      focusItem,
    });
  } else if (rec.length === 1) {
    core = h(ViewerControl, {
      data: rec[0],
      hovered,
      focusItem,
    });
  } else {
    const actions = {
      removeItem: (item) => dispatch({ type: "group-remove-item", data: item }),
      focusItem,
      createGroup: () => dispatch({ type: "group-selected" }),
    };
    core = h(SelectionControl, {
      records: rec,
      hovered,
      actions: actions,
    });
  }

  return h(
    "div",
    {
      className: `${style.sidebar} flex flex-container`,
    },
    [
      core,
      h("div.modal-controls", [
        h(
          Button,
          {
            onClick: () => openGroupViewer(),
          },
          "View group"
        ),
        h(CloseButton, { focused }),
      ]),
    ]
  );
}

export default Sidebar;
