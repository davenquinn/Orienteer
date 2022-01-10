import update from "immutability-helper";
import { AppState, AttitudeCore, Attitude } from "./types";

export function refreshSelected(state: AppState): AppState {
  // refresh selection
  const sel = Array.from(state.selected).map((d) => d.id);
  const newSel = new Set(state.data.filter((d) => sel.includes(d.id)));
  const cset = { selected: { $set: newSel } };

  for (const dt of ["hovered", "focused"]) {
    const val = state[dt];
    if (val == null) continue;
    cset[dt] = { $set: state.data.find((d) => state[dt].id == d.id) };
  }
  return update(state, cset);
}

export type NotifyError = { type: "error"; error: Error };

export function prepareData(d: AttitudeCore): Attitude {
  // Transform raw data
  return {
    ...d,
    grouped: d.type === "group",
    selected: false,
    hovered: false,
    type: "Feature",
    tags: new Set(d.tags ?? []),
  };
}
