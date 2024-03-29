import { AppState } from "./types";
import pg from "./database";
import update from "immutability-helper";
import { refreshSelected, NotifyError } from "./util";

type TagResultAction =
  | { type: "tag-added"; tag: string; records: number[] }
  | { type: "tag-removed"; tag: string; records: number[] }
  | NotifyError;

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
): Promise<TagResultAction | undefined> {
  switch (action.type) {
    case "add-tag":
    case "remove-tag":
      const { tag } = action;
      const { selected } = state;
      const attitudes = Array.from(selected).map((d) => d.id);
      const proc = action.type === "add-tag" ? "add_tag" : "remove_tag";
      const type = action.type === "add-tag" ? "tag-added" : "tag-removed";
      const res = await pg.rpc(proc, { tag, attitudes });
      //if (res.error) return { type: "error", error: res.error };
      console.log(res);
      const data: TagLinkRecord[] = res.data;
      return { type, tag, records: data.map((d) => d.attitude_id) };
    default:
      return action;
  }
}

function tagReducer(state: AppState, action: TagResultAction): AppState {
  switch (action.type) {
    case "tag-added":
    case "tag-removed":
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
