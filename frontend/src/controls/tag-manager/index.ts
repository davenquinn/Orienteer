import { useAppDispatch, useAppState } from "../../data-manager";

/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const ReactDOM = require("react-dom");
const style = require("./style.styl");
const h = require("react-hyperscript");
const { Tag, Intent } = require("@blueprintjs/core");

const buildTagData = function (records) {
  let func = function (a, d) {
    Array.prototype.push.apply(a, d.tags);
    return a;
  };
  let arr = records.reduce(func, []);
  func = function (d, name) {
    if (!(name in d)) {
      d[name] = 0;
    }
    d[name] += 1;
    return d;
  };
  const data = arr.reduce(func, {});
  arr = [];
  for (let tag in data) {
    const num = data[tag];
    arr.push({
      name: tag,
      all: num >= records.length,
    });
  }
  return arr;
};

class TagForm extends React.Component {
  constructor(props) {
    super(props);
    this.sanitizeField = this.sanitizeField.bind(this);
    this.submitForm = this.submitForm.bind(this);
    this.state = { value: "" };
  }

  render() {
    const vals = { onSubmit: this.submitForm };
    return h("form.form-inline", vals, [
      h("input.pt-input.pt-fill", {
        autoComplete: "off",
        type: "text",
        name: "tag",
        value: this.state.value,
        placeholder: "Tag",
        onChange: this.sanitizeField,
      }),
    ]);
  }

  sanitizeField(event) {
    const val = event.target.value;
    return this.setState({ value: val.toLowerCase() });
  }

  submitForm(event) {
    event.preventDefault();
    this.props.onUpdate(this.state.value);
    return this.setState({ value: "" });
  }
}

function TagManager() {
  const records = useAppState((state) => state.selected);
  const hovered = useAppState((state) => state.hovered);
  const dispatch = useAppDispatch();

  const rec = hovered != null ? [hovered] : records;
  const tags = buildTagData(rec);
  const val = hovered != null ? "Hovered item" : "Selection";

  return h("div.tag-manager", [
    h("div.header", [h("h6", "Tags"), h("h6.info", val)]),
    h(
      "p.tag-list",
      tags.map(({ all, name }) => {
        const intent = all ? Intent.SUCCESS : null;
        return h(
          Tag,
          {
            onRemove() {
              dispatch({ type: "remove-tag", tag: name });
            },
            intent,
            name,
            className: "pt-minimal",
          },
          name
        );
      })
    ),
    h(TagForm, { onUpdate: (tag) => dispatch({ type: "add-tag", tag }) }),
  ]);
}
export default TagManager;
