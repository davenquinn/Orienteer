import tags from "../shared/data/tags";
import { LatLng } from "leaflet";
import _ from "underscore";
import update, { Spec } from "immutability-helper";
import pg from "./database";
import axios from "axios";
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
import { Attitude, AttitudeData, AppState } from "./types";
import { TagAction, tagReducer, tagAsyncHandler } from "./tags";
import { refreshSelected, prepareData } from "./util";
import { GroupAction, groupActionHandler } from "./groups";

class DataManager {
  static initClass() {
    this.prototype.hoveredItem = null;
    this.prototype.fetched = false;
    this.prototype.records = [];
    this.prototype.subquery = null;
  }
  _filter(d) {
    return d;
  }
  constructor(opts) {
    this.log = opts.logger || console;
    this.onUpdated = opts.onUpdated;

    //@selection = Selection
    //@selection.bind "tags-updated", @filter
    //
    Object.defineProperty(this, "selection", {
      get() {
        return this.records.filter((d) => d.selected);
      },
    });
  }

  get(...ids) {
    let rec;
    if (ids.length === 1) {
      rec = this.records.find((d) => d.id === ids[0]);
    } else {
      rec = this.records.filter((d) => ids.indexOf(d.id) !== -1);
    }
    return rec;
  }

  asGeoJSON() {
    let out;
    return (out = {
      type: "FeatureCollection",
      features: this.records,
    });
  }

  getTags() {
    return tags.getUnique(this.records);
  }

  reset() {
    return (this.records = []);
  }

  hovered(d) {
    let ix;
    const hoveredItem = this.records.find((rec) => rec.hovered);
    if (d === hoveredItem) {
      return;
    }

    const changeset = {};
    if (hoveredItem != null) {
      ix = this.getRecordIndex(hoveredItem.id);
      changeset[ix] = { hovered: { $set: false } };
    }
    if (d != null) {
      ix = this.getRecordIndex(d.id);
      changeset[ix] = { hovered: { $set: true } };
    }
    return this.updateUsing(changeset);
  }

  within(bounds) {
    return this.records.filter(function (d) {
      const a = d.center.coordinates;
      const l = new LatLng(a[1], a[0]);
      return bounds.contains(l);
    });
  }

  selectByBox(bounds) {
    const f = this.within(bounds).filter((d) => !d.in_group);
    return this.addToSelection(...f);
  }

  createGroupFromSelection() {}

  getRecordIndex(id) {
    // Get index of a certain primary key
    return this.records.findIndex((rec) => id === rec.id);
  }

  getRecordById(id) {
    return this.records.find((rec) => id === rec.id);
  }

  updateUsing(changeset) {
    console.log("Updating using", changeset);
    this.records = update(this.records, changeset).filter((d) => d != null);
    return this.onUpdated({ records: this.records });
  }

  refreshAllData() {
    return this.getData(this.subquery);
  }

  // Change data class
  async changeClass(type, records) {
    const sql = storedProcedure("update-types");
    const ids = records.map((d) => d.id);
    console.log(`Changing type to ${type} for ${ids}`);

    const results = await db.query(sql, [type, ids]);

    const changeset = {};
    for (var rec of Array.from(results)) {
      const ix = this.records.findIndex((a) => rec.id === a.id);
      if (ix === -1) {
        continue;
      }
      changeset[ix] = { class: { $set: type } };
    }

    this.updateUsing(changeset);
    this.log.success(`Changed class to ${type} for ${results.length} records`);
    if (this.subquery == null) {
      return;
    }
    if (this.subquery.includes("class")) {
      return this.refreshAllData();
    }
  }
}
DataManager.initClass();

const noOpDispatch = () => {};

type AppDispatch = React.Dispatch<AppAction | AppPrivateAction>;

const AppDataContext = createContext(null);
const AppDispatchContext = createContext<AppDispatch>(noOpDispatch);

type AppReducer = (
  state: AppState,
  action: AppSyncAction | AppPrivateAction
) => AppState;

type AppSyncAction =
  | { type: "set-data"; data: AttitudeData; filter: Function | null }
  | { type: "toggle-selection"; data: AttitudeData }
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
  | { type: "set-filter"; filter: Function | null };

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
      return { ...state, data: action.data, filter: action.filter };
    case "toggle-selection":
      const _action = state.selected.has(action.data) ? "$remove" : "$add";
      return update(state, { selected: { [_action]: [action.data] } });
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
    case "set-filter":
      const newState = { ...state, filter: action.filter };
      return actionCreator(newState, { type: "get-initial-data" }, dispatch);
    case "get-initial-data":
      const filter = state.filter ?? ((d) => d);
      const res = await filter(pg.from("attitude").select("*"));
      return {
        type: "set-data",
        data: res.data.map(prepareData),
        filter: state.filter,
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

const initialState: AppState = {
  data: [],
  hovered: null,
  focused: null,
  selected: new Set(),
  filter: null,
};

type StateAccessor = (state: AppState) => any;

export function useAppDispatch() {
  return useContext(AppDispatchContext);
}

export function useAppState(accessor: StateAccessor | null = null) {
  const state = useContext(AppDataContext);
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

export { DataManager, AppDataContext };
