import hyper from "@macrostrat/hyper";
import { useAppState, useAppDispatch } from "app/data-manager";
import { usePostgrestSelect } from "../data-manager/database";
import { ErrorBoundary } from "@macrostrat/ui-components";
import styles from "./style.module.styl";

import { Button, MenuItem, Tag, Intent } from "@blueprintjs/core";
import { Select } from "@blueprintjs/select";

interface ITag {
  name: string;
}

// Select<T> is a generic component to work with your data types.
// In TypeScript, you must first obtain a non-generic reference:
const _TagSelect = Select.ofType<ITag>();

const h = hyper.styled(styles);

function TagSelect({
  tags = [],
  children,
  onSelect,
  textRenderer = (t) => t.name,
}) {
  return h(
    _TagSelect,
    {
      items: tags,
      itemRenderer: (tag) => {
        const text = textRenderer(tag);
        return h(MenuItem, {
          key: text,
          text,
          onClick() {
            onSelect(tag);
          },
        });
      },
      itemPredicate: (query, tag) =>
        textRenderer(tag).toLowerCase().includes(query.toLowerCase()),
      noResults: h(MenuItem, { disabled: true, text: "No results." }),
      onItemSelect: onSelect,
    },
    children
  );
}

function TagSelectList({
  selectedData = [],
  data,
  onChange,
  textRenderer = (t) => t.name,
}) {
  return h("div.tag-filter", null, [
    h("div.tag-list", [
      selectedData.map((tag) =>
        h(
          Tag,
          {
            onRemove() {
              onChange(selectedData.filter((d) => d != tag));
            },
            intent: Intent.SUCCESS,
            minimal: true,
            //color,
          },
          textRenderer(tag)
        )
      ),
      h(
        TagSelect,
        {
          tags: data,
          onSelect: (tag) => onChange([...selectedData, tag]),
          textRenderer,
        },
        h(Button, {
          icon: "more",
          onClick: () => {},
          small: true,
          minimal: true,
        })
      ),
    ]),
  ]);
}

function TagFilterPanel(props) {
  const { tags: selectedData = [], onChange } = props;
  const { data = [] } = usePostgrestSelect("tag");
  return h([
    h("h3", "Tags"),
    h(TagSelectList, { data, selectedData, onChange }),
  ]);
}

function ClassFilterPanel(props) {
  const { classes: selectedData = [], onChange } = props;
  const { data = [] } = usePostgrestSelect("feature_class");
  return h([
    h("h3", "Feature classes"),
    h(TagSelectList, {
      data,
      selectedData,
      onChange,
      textRenderer: (c) => c.type,
    }),
  ]);
}

export default function FilterPanel() {
  const { filterData = {} } = useAppState();
  const dispatch = useAppDispatch();
  const { classes = [], tags = [] } = filterData ?? {};

  return h(
    ErrorBoundary,
    h("div.filter-panel", [
      h("h2", "Filter data"),
      h("div.filter-pane", [
        h(TagFilterPanel, {
          tags,
          onChange(tags) {
            console.log(tags);
            dispatch({
              type: "set-filter-data",
              data: { ...filterData, tags },
            });
          },
        }),
        h(ClassFilterPanel, {
          classes,
          onChange(classes) {
            dispatch({
              type: "set-filter-data",
              data: { ...filterData, classes },
            });
          },
        }),
      ]),
    ])
  );
}
