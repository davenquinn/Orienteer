import _ from "underscore";
import update, { Spec } from "immutability-helper";
import pg from "./database";
import axios from "axios";
import { Attitude, AppState } from "./types";
import { prepareData } from "./util";

async function refreshRecords(
  state,
  ids,
  opts: { selected?: boolean; changeset: Spec<Attitude[], any> }
) {
  // Options:
  //   selected: boolean (should set data to be selected)
  //   changeset: an input changeset to use
  const { selected, changeset = {} } = opts ?? {};
  const res = await pg.from("attitude").select("*").in("id", ids);
  const data = res.data.map(prepareData);

  changeset.$push ??= [];
  for (const rec of data) {
    // Remove empty groups
    const ix = state.attitudes.findIndex((a) => rec.id === a.id);
    if (ix === -1) {
      changeset["$push"].push(rec);
    }
    changeset[ix] = { $set: rec };
  }

  return { type: "apply-changeset", changeset };
}

type GroupAction =
  | { type: "create-group"; attitudes: Attitude[]; samePlane: boolean }
  | { type: "destroy-group"; attitude: Attitude }
  | { type: "group-selected" }
  | { type: "group-deleted" };

async function groupActionHandler(
  state: AppState,
  action: GroupAction,
  dispatch
) {
  const baseURI = process.env.ORIENTEER_API_BASE + "/api/group";
  switch (action.type) {
    case "create-group":
      const { attitudes } = action;
      console.log(attitudes);

      try {
        const data = {
          measurements: attitudes.map((d) => d.id),
          same_plane: false,
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
        return refreshRecords(state, ids, { selected: true, changeset });
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
        const res = axios.delete(baseURI + `/${id}`);
        const newMeasurements = res.measurements;
        const ix = state.data.findIndex((d) => id === d.id);
        const changeset = { $splice: [[ix, 1]] };
        return refreshRecords(state, newMeasurements, {
          changeset,
          selected: true,
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
