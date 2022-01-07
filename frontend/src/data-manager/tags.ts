import { Attitude, AppState } from "./types";
import pg from "./database";
import update from "immutability-helper";

type TagResultAction =
  | { type: "tag-added"; tag: string; records: number[] }
  | { type: "tag-removed"; tag: string; records: number[] };

type TagAction =
  | { type: "add-tag"; tag: string }
  | { type: "remove-tag"; tag: string };

type TagLinkRecord = {
  tag_name: string;
  attitude_id: number;
};

async function tagAsyncHandler(
  state: AppState,
  action: TagAction
): Promise<TagResultAction> {
  switch (action.type) {
    case "add-tag" || "remove-tag":
      const { tag } = action;
      const { selected } = state;
      const attitudes = Array.from(selected).map((d) => d.id);
      const proc = action.type === "add-tag" ? "add_tag" : "remove_tag";
      const type = action.type === "add-tag" ? "tag-added" : "tag-removed";
      const res: TagLinkRecord[] = await pg.rpc(proc, { tag, attitudes });
      return { type, tag, records: res.map((d) => d.attitude_id) };
    default:
      return action;
  }
}

function refreshSelected(state: AppState): AppState {
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

function tagReducer(state: AppState, action: TagResultAction): string[] {
  switch (action.type) {
    case "tag-added" || "tag-removed":
      const indices = action.records.map((d) =>
        state.data.findIndex((rec) => rec.id === d)
      );
      const op = action.type === "tag-added" ? "$add" : "$remove";

      let changeset = {};
      for (let ix of indices) {
        changeset[ix] = { tags: { [op]: [action.tag] } };
      }

      return refreshSelected(update(state, { data: changeset }));
    default:
      return state;
  }
}

export { TagAction, tagReducer, tagAsyncHandler };
