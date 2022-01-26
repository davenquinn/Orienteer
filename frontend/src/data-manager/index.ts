import { LatLng } from "leaflet";
import _ from "underscore";
import update, { Spec } from "immutability-helper";
import pg from "./database";
import {
  createContext,
  useContext,
  useCallback,
  useReducer,
  useEffect,
} from "react";
//const { storedProcedure, db } = require("./database");
import h from "@macrostrat/hyper";
import { APIProvider } from "@macrostrat/ui-components";
import { LatLngBounds } from "leaflet";
import { Attitude, AttitudeData, AppState, initialState } from "./types";
import { TagAction, tagReducer, tagAsyncHandler } from "./tags";
import { refreshSelected, prepareData } from "./util";
import { GroupAction, groupActionHandler } from "./groups";
import { constructFilter, AttitudeFilterData } from "./filter";

const noOpDispatch = () => {};

type AppDispatch = React.Dispatch<AppAction | AppPrivateAction>;

const AppDataContext = createContext(null);
const AppDispatchContext = createContext<AppDispatch>(noOpDispatch);

type AppReducer = (
  state: AppState,
  action: AppSyncAction | AppPrivateAction
) => AppState;

type AppSyncAction =
  | {
      type: "set-data";
      data: AttitudeData;
    }
  | { type: "toggle-selection"; data: AttitudeData }
  | { type: "toggle-sidebar" }
  | { type: "hover"; data: Attitude | null }
  | { type: "select-box"; data: LatLngBounds }
  | { type: "clear-selection" }
  | { type: "clear-focus" }
  | { type: "focus-item"; data: Attitude }
  | { type: "refresh-data" }
  | { type: "apply-spec"; spec: Spec<AppState> }
  | { type: "run-async-action"; action: AppAction; dispatch: AppDispatch }
  | TagAction
  | GroupAction;

type AppPrivateAction = { type: "set-state"; data: AttitudeData };
type AppAsyncAction =
  | { type: "get-initial-data" }
  | { type: "set-filter-data"; data: AttitudeFilterData | null };

type AppAction = AppAsyncAction | AppSyncAction;

const baseReducer: AppReducer = (
  state: AppState = initialState,
  action: AppSyncAction | AppPrivateAction
) => {
  switch (action.type) {
    case "run-async-action":
      actionCreator(state, action.action, action.dispatch).then((d) => {
        if (d == null) return;
        action.dispatch(d);
      });
      return state;
    case "set-state":
      return action.data;
    case "set-data":
      return { ...state, data: action.data };
    case "toggle-selection":
      const _action = state.selected.has(action.data) ? "$remove" : "$add";
      return update(state, { selected: { [_action]: [action.data] } });
    case "toggle-sidebar":
      return update(state, { showSidebar: { $set: !state.showSidebar } });
    case "select-box":
      const bounds = action.data;
      let data = state.data
        .filter(function (d) {
          const a = d.center.coordinates;
          const l = new LatLng(a[1], a[0]);
          return bounds.contains(l);
        })
        .filter((d) => !d.in_group);
      return update(state, { selected: { $add: data } });
    case "clear-selection":
      return update(state, { selected: { $set: new Set() } });
    case "hover":
      return { ...state, hovered: action.data };
    case "focus-item":
      return { ...state, focused: action.data };
    case "clear-focus":
      return { ...state, focused: null };
    case "apply-spec":
      return refreshSelected(update(state, action.spec));
    default:
      return tagReducer(state, action);
  }
};

async function actionCreator(
  state: AppState,
  action: AppAction,
  dispatch
): Promise<AppSyncAction> {
  switch (action.type) {
    case "group-selected":
      const { samePlane } = action;
      return actionCreator(
        state,
        {
          type: "create-group",
          attitudes: Array.from(state.selected),
          samePlane,
        },
        dispatch
      );
    case "set-filter-data":
      const newState = { ...state, filterData: action.data };
      dispatch({ type: "set-state", data: newState });
      return actionCreator(newState, { type: "get-initial-data" }, dispatch);
    case "get-initial-data":
      const filter = constructFilter(state.filterData);
      const res = await filter(pg.from("attitude").select("*"));
      return {
        type: "set-data",
        data: res.data.map(prepareData),
      };
    default:
      // Try other action handlers in sequence
      for (const k of [tagAsyncHandler, groupActionHandler]) {
        const res = await k(state, action, dispatch);
        if (res != action) {
          return res;
        }
      }
      return action;
  }
}

type StateAccessor = (state: AppState) => any;

export function useAppDispatch() {
  return useContext(AppDispatchContext);
}

export function useAppState(accessor: StateAccessor | null = null) {
  const state: AppState = useContext(AppDataContext);
  if (accessor == null) return state;
  return accessor(state);
}

export function AppDataProvider(props) {
  const [state, dispatch] = useReducer<AppReducer, AppState>(
    baseReducer,
    initialState,
    undefined
  );

  const runAction = useCallback(
    (action: AppAction) => {
      // We run this in the reducer because the reducer always has access
      // to the current state.
      dispatch({ type: "run-async-action", action, dispatch });
    },
    [dispatch]
  );

  useEffect(() => {
    runAction({ type: "get-initial-data" });
  }, []);

  return h(
    APIProvider,
    {},
    h(
      AppDataContext.Provider,
      { value: state },
      h(AppDispatchContext.Provider, { value: runAction }, props.children)
    )
  );
}

export { AppDataContext };
