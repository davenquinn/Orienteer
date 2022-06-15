import _ from "underscore";
import update, { Spec } from "immutability-helper";
import pg from "./database";
import axios from "axios";
import { Attitude, AppState } from "./types";
import { prepareData } from "./util";
import { ORIENTEER_API_BASE } from "../config";

async function refreshRecords(
  state,
  ids,
  opts: { selected?: number[] | null; changeset: Spec<Attitude[], any> }
) {
  // Options:
  //   selected: boolean (should set data to be selected)
  //   changeset: an input changeset to use
  const { selected = [], changeset = {} } = opts ?? {};
  const res = await pg.from("attitude").select("*").in("id", ids);
  const data = res.data.map(prepareData);

  changeset.$push ??= [];
  for (const rec of data) {
    // Remove empty groups
    const ix = state.data.findIndex((a) => rec.id === a.id);
    if (ix === -1) {
      changeset["$push"].push(rec);
    }
    changeset[ix] = { $set: rec };
  }

  let spec: Spec<AppState, any> = { data: changeset };
  if (selected != null) {
    spec.selected = {
      $set: new Set(data.filter((d) => selected.includes(d.id))),
    };
  }

  return { type: "apply-spec", spec };
}

type GroupAction =
  | { type: "create-group"; attitudes: Attitude[]; samePlane: boolean }
  | { type: "destroy-group"; attitude: Attitude }
  | { type: "group-selected"; samePlane: boolean }
  | { type: "group-deleted" }
  | { type: "group-remove-item"; data: Attitude }
  | { type: "group-add-item"; data: Attitude };

async function groupActionHandler(
  state: AppState,
  action: GroupAction,
  dispatch
) {
  const baseURI = ORIENTEER_API_BASE + "/api/group";
  switch (action.type) {
    case "create-group":
      const { attitudes } = action;
      try {
        const data = {
          measurements: attitudes.map((d) => d.id),
          same_plane: action.samePlane,
        };
        const res = await axios.post(baseURI, data);
        const { data: obj, status, deleted_groups, message } = res.data;
        if (status == "failure") {
          return { type: "error", error: message };
        }
        const ids = obj.measurements.concat([obj.id]);
        // Splice empty groups from records
        const changeset = { $splice: [] };
        for (const id of deleted_groups) {
          const ix = state.data.findIndex((a) => id === a.id);
          changeset.$splice.push([ix, 1]);
        }
        return refreshRecords(state, ids, { selected: [obj.id], changeset });
      } catch (error) {
        console.log(error);
        return { type: "error", error };
      }

    case "destroy-group":
      const { attitude } = action;
      // Currently, we know that all groups that are deleted were selected
      const groupWasSelected = true;

      const { id } = attitude;
      try {
        const res = await axios.delete(baseURI + `/${id}`);
        const data = res.data;
        const newMeasurements = data.measurements;
        const ix = state.data.findIndex((d) => id === d.id);
        const changeset = { $splice: [[ix, 1]] };
        return refreshRecords(state, newMeasurements, {
          changeset,
          selected: newMeasurements,
        });
      } catch (error) {
        console.error(error);
        return { type: "error", error };
      }
    default:
      return action;
  }
}

export { groupActionHandler, refreshRecords, GroupAction };
