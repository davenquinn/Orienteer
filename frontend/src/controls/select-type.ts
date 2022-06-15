import Select from "react-select";
import h from "@macrostrat/hyper";
import { useAppState } from "app/data-manager";
import { usePostgrestSelect } from "../data-manager/database";

function getCurrentRecord(recs) {
  const s = new Set(recs);
  if (s.size > 1) {
    return "multiple";
  }
  return recs[0] || null;
}

function SelectType() {
  const selected = useAppState((d) => d.selected);
  const hovered = useAppState((d) => d.hovered);
  console.log(selected, hovered);
  const { data: featureTypes } = usePostgrestSelect("feature_class");
  if (featureTypes == null) return null;

  let recs = hovered != null ? [hovered] : Array.from(selected);
  recs = recs.map((d) => d["class"]);

  const recID = getCurrentRecord(recs);

  const options = featureTypes.map((d) => ({
    value: d.id,
    label: d.type,
    color: d.color,
  }));
  if (value == "multiple") {
    options.push({ value: "multiple", label: "Multiple", color: "gray" });
  }

  const value = options.find((d) => d.value == recID);

  const onChange = (type) => {
    let val;
    if (hovered != null) {
      return false;
    }
    if (type != null) {
      val = type.value;
    } else {
      val = "null";
    }
    //return app.data.changeClass(val, records);
  };

  console.log(value);

  const renderOption = function (opt) {
    const v = opt.value.replace("_", " ");
    v.charAt(0).toUpperCase() + v.slice(1);
    return v;
  };

  return h(Select, {
    name: "select-type",
    value,
    options,
    onChange,
    //optionRenderer: renderOption,
  });
}

export default SelectType;
