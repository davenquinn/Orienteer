import tags from "../shared/data/tags";
import { LatLng } from "leaflet";
import _ from "underscore";
import update from "immutability-helper";
import pg from "./database";
import { readFileSync } from "fs";
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

const prepareData = function (d) {
  // Transform raw data
  d = _.clone(d);
  d.grouped = d.type === "group";
  d.selected = false;
  d.hovered = false;
  d.type = "Feature";
  if (d.tags == null) {
    d.tags = [];
  }
  return d;
};

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

  async destroyGroup(id) {
    const call = Promise.promisify(app.API(`/group/${id}`).send);
    console.log(`Destroying group ${id}`);
    const response = await call("DELETE");

    // Currently, we know that all groups that are deleted were selected
    const groupWasSelected = true;

    if (response.status !== "success") {
      this.log.error(`Could not destroy group ${id}`);
      return;
    }

    const ix = this.records.findIndex((d) => id === d.id);
    const changeset = { $splice: [[ix, 1]] };
    this.refreshRecords(response.measurements, { changeset, selected: true });
    return app.log.success(`Destroyed group ${id}`);
  }

  async createGroup(records) {
    const call = Promise.promisify(app.API("/group").send);
    const data = {
      measurements: records.map((d) => d.id),
      same_plane: false,
    };

    console.log("Creating group");
    const response = await call("POST", JSON.stringify(data));
    console.log("Got response from server");
    if (response.status !== "success") {
      this.log.error("Could not create group");
      return;
    }
    const obj = response.data;
    const ids = obj.measurements.concat([obj.id]);
    this.log.success(`Successfully created group ${obj.id}`);
    // Splice empty groups
    const changeset = {};
    for (let record of Array.from(records)) {
      if (!record.is_group) {
        continue;
      }
      const ix = this.getRecordIndex(record.id);
      changeset[ix] = { $set: null };
    }
    return this.refreshRecords(ids, { selected: true, changeset });
  }

  async refreshRecords(ids, opts = {}) {
    // Options:
    //   selected: boolean (should set data to be selected)
    //   changeset: an input changeset to use
    const changeset = opts.changeset || {};

    const sql = storedProcedure("get-records-by-ids");
    console.log("Refreshing records", ids);
    const records = await db.query(sql, [ids]).map(prepareData);
    for (var rec of Array.from(records)) {
      const ix = this.records.findIndex((a) => rec.id === a.id);
      if (opts.selected != null && !rec.in_group) {
        rec.selected = opts.selected;
      }
      if (ix === -1) {
        if (changeset["$push"] == null) {
          changeset["$push"] = [];
        }
        changeset["$push"].push(rec);
      }
      changeset[ix] = { $set: rec };
    }

    return this.updateUsing(changeset);
  }
}
DataManager.initClass();

const noOpDispatch = () => {};

type AppDispatch = React.Dispatch<AppAction>;

const AppDataContext = createContext(null);
const AppDispatchContext = createContext<AppDispatch>(noOpDispatch);

type AppReducer = (
  state: AppState,
  action: AppSyncAction | AppPrivateAction
) => AppState;

type AppSyncAction =
  | { type: "set-data"; data: AttitudeData }
  | { type: "toggle-selection"; data: AttitudeData }
  | { type: "hover"; data: Attitude | null }
  | { type: "select-box"; data: LatLngBounds }
  | { type: "group-selected" }
  | { type: "clear-selection" }
  | { type: "group-remove-item"; data: Attitude }
  | { type: "group-add-item"; data: Attitude }
  | { type: "clear-focus" }
  | { type: "focus-item"; data: Attitude }
  | { type: "refresh-data" }
  | TagAction;

type AppPrivateAction = { type: "set-state"; data: AttitudeData };

type AppAsyncAction = { type: "get-initial-data" };

type AppAction = AppAsyncAction | AppSyncAction;

const baseReducer: AppReducer = (
  state: AppState = initialState,
  action: AppSyncAction | AppPrivateAction
) => {
  switch (action.type) {
    case "set-state":
      return action.data;
    case "set-data":
      return { ...state, data: action.data };
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
    default:
      return tagReducer(state);
  }
};

async function actionCreator(
  state: AppState,
  action: AppAction,
  dispatch
): Promise<AppSyncAction> {
  switch (action.type) {
    case "get-initial-data":
      const res = await pg.from("attitude");
      return {
        type: "set-data",
        data: res.data.map(prepareData),
      };
    default:
      return await tagAsyncHandler(state, action);
  }
}

const initialState: AppState = {
  data: [],
  hovered: null,
  focused: null,
  selected: new Set(),
};

function useActionRunner() {
  // @ts-ignore
  const [state, dispatch] = useReducer<AppReducer, AppState>(
    baseReducer,
    initialState
  );
  const runAction = useCallback(
    async function runAction(action) {
      console.log(action);
      const _action = await actionCreator(action, state, dispatch);
      dispatch(_action);
    },
    [dispatch]
  );
  return [state, runAction];
}

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
  const [state, runAction] = useActionRunner();

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

export { DataManager, AppDataContext, AttitudeData };
