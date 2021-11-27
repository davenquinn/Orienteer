import tags from "./shared/data/tags";
import Promise from "bluebird";
import { LatLng } from "leaflet";
import _ from "underscore";
import update from "immutability-helper";
import { readFileSync } from "fs";
import {
  createContext,
  useState,
  useContext,
  useReducer,
  useEffect,
} from "react";
//const { storedProcedure, db } = require("./database");
import h from "@macrostrat/hyper";
import { PostgrestClient } from "@supabase/postgrest-js";

import API from "./api";

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
    this.clearSelection = this.clearSelection.bind(this);
    if (opts == null) {
      opts = {};
    }
    this.log = opts.logger || console;
    this.onUpdated = opts.onUpdated;

    // Setup requests for updated data
    this.fetchInitialData();

    //@selection = Selection
    //@selection.bind "tags-updated", @filter
    //
    Object.defineProperty(this, "selection", {
      get() {
        return this.records.filter((d) => d.selected);
      },
    });
  }

  fetchInitialData() {
    this.featureTypes = [];
    const sql = storedProcedure("get-types");
    return db.query(sql).then((records) => {
      this.featureTypes = records;
      return this.onUpdated({ featureTypes: records });
    });
  }

  getData(subquery, complete) {
    // Grab data directly from postgresql dataset
    // We used to use a Python API here but this
    // is a factor of at least 100 quicker
    // Transfer selection
    this.subquery = subquery;
    if (complete == null) {
      complete = false;
    }
    const selectedIDs = this.records.filter((d) => d.selected).map((d) => d.id);

    let sql = readFileSync(`${__dirname}/sql/get-dataset.sql`, "utf8");
    if (this.subquery != null) {
      const v = sql.replace("attitude_data", "subquery");
      sql = `WITH subquery AS (${this.subquery}) ${v}`;
    }

    return db
      .query(sql)
      .map(prepareData)
      .then((records) => {
        let changeset;
        console.log("Getting records");

        // Only integrate changed records
        // We could have a separate thing to completely refresh data
        if (complete || this.records.length === 0) {
          changeset = { $set: records };
        } else {
          changeset = { $push: [] };
          // Set all to null by default
          this.records.forEach((d, i) => (changeset[i] = { $set: null }));

          // Add back records that are changed
          for (let record of Array.from(records)) {
            const ix = this.getRecordIndex(record.id);
            if (ix === -1) {
              changeset["$push"].push(record);
            } else {
              delete changeset[ix];
            }
          }
        }

        this.updateUsing(changeset);
        return this.log.success(`Loaded ${records.length} features`);
      })
      .catch(function (e) {
        throw e;
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

  addToSelection(...records) {
    const changeset = {};
    for (let record of Array.from(records)) {
      const ix = this.getRecordIndex(record.id);
      changeset[ix] = { selected: { $set: true } };
    }
    return this.updateUsing(changeset);
  }

  removeFromSelection(...records) {
    const changeset = {};
    for (let record of Array.from(records)) {
      const ix = this.getRecordIndex(record.id);
      changeset[ix] = { selected: { $set: false } };
    }
    return this.updateUsing(changeset);
  }

  updateSelection(record) {
    // Add or remove record from selection depending on membership
    const ix = this.getRecordIndex(record.id);
    const changeset = {};
    changeset[ix] = { selected: { $set: !record.selected } };
    return this.updateUsing(changeset);
  }

  clearSelection() {
    const rec = this.records.filter((d) => d.selected);
    return this.removeFromSelection(...rec);
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

  async addTag(tag, records) {
    const sql = storedProcedure("add-tag");
    const ids = records.map((d) => d.id);
    records = await db.query(sql, [tag, ids]);

    const changeset = {};
    for (let rec of Array.from(records)) {
      console.log(rec);
      const ix = this.getRecordIndex(rec.attitude_id);
      changeset[ix] = { tags: { $push: [rec.tag_name] } };
    }

    this.updateUsing(changeset);
    if (this.subquery == null) {
      return;
    }
    if (this.subquery.includes("tags")) {
      return this.refreshAllData();
    }
  }

  async removeTag(tag, records) {
    const sql = storedProcedure("remove-tag");
    const ids = records.map((d) => d.id);
    records = await db.query(sql, [tag, ids]);

    const changeset = {};
    for (let rec of Array.from(records)) {
      console.log(rec);
      const ix = this.getRecordIndex(rec.attitude_id);
      const tagindex = this.records[ix].tags.indexOf(tag);
      if (tagindex === -1) {
        continue;
      }
      changeset[ix] = { tags: { $splice: [[tagindex, 1]] } };
    }

    this.updateUsing(changeset);
    if (this.subquery == null) {
      return;
    }
    if (this.subquery.includes("tags")) {
      return this.refreshAllData();
    }
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

const AppDataContext = createContext(null);
const AppDispatchContext = createContext<React.Dispatch<any>>(noOpDispatch);

const baseReducer = (state, action) => {
  return state;
};

const POSTGREST_URL = process.env.ORIENTEER_API_BASE + "/models";
const pg = new PostgrestClient(POSTGREST_URL);

function useAttitudeData() {
  const [data, setData] = useState([]);
  useEffect(() => {
    pg.from("attitude")
      .select()
      .then((res) => {
        setData(res.data.map(prepareData));
      });
  }, []);
  return data;
}

function AppDataProvider(props) {
  const [data, dispatch] = useReducer(baseReducer, {});
  return h(
    AppDataContext.Provider,
    { value: data },
    h(AppDispatchContext.Provider, { value: dispatch }, props.children)
  );
}

export { DataManager, AppDataContext, AppDataProvider, useAttitudeData };
