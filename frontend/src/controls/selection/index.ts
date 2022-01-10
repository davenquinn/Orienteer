import SelectionList from "./list";
import ViewerControl from "./viewer";
import styles from "./style.module.styl";
import { NonIdealState, Button } from "@blueprintjs/core";
import { hyperStyled } from "@macrostrat/hyper";
import { useAppDispatch, useAppState } from "app/hooks";
import { ErrorBoundary } from "@macrostrat/ui-components";

const h = hyperStyled(styles);

function SelectionControl(props) {
  const dispatch = useAppDispatch();
  const a = props.actions;
  if (a == null) return null;
  return h("div.sidebar-inner", [
    h(SelectionList, {
      records: props.records,
      hovered: props.hovered,
      removeItem: a.removeItem,
      focusItem: a.focusItem,
      allowRemoval: true,
    }),
    h("p", null, [
      h(
        Button,
        {
          className: "group",
          intent: "primary",
          disabled: props.records.length < 2,
          onClick() {
            dispatch({
              type: "group-selected",
            });
          },
        },
        "Group measurements"
      ),
    ]),
  ]);
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

function SelectionCore({ records, focused }) {
  const hovered = useAppState((d) => d.hovered);
  const dispatch = useAppDispatch();
  const focusItem = (item) => dispatch({ type: "focus-item", data: item });
  const actions = {
    removeItem: (item) => dispatch({ type: "group-remove-item", data: item }),
    focusItem,
    createGroup: () => dispatch({ type: "group-selected" }),
  };

  const focusedRecord = records.length == 1 ? records[0] : focused;
  if (focusedRecord != null) {
    return h(ErrorBoundary, [
      h(ViewerControl, {
        data: focusedRecord,
        hovered,
        focusItem,
      }),
    ]);
  }
  return h(SelectionControl, {
    records,
    hovered,
    actions,
  });
}

function Sidebar({ records }) {
  const focused = useAppState((d) => d.focused);

  if (records.length === 0) {
    return h(NonIdealState, {
      title: "No items selected",
      description: "Select some items on the map",
      visual: "send-to-map",
    });
  }

  return h("div.selection-panel.flex.flex-container", [
    h(SelectionCore, { records, focused }),
    h(SelectionControl, { records, focused }),
    h("div.modal-controls", [
      //h(Button, { onClick: openGroupViewer }, "View group"),
      h(CloseButton, { focused }),
    ]),
  ]);
}

export default Sidebar;
