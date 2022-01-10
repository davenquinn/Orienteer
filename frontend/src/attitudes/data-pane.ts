/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from "react";
import Measure from "react-measure";
//import Stereonet from "../controls/stereonet";
import TagManager from "../controls/tag-manager";
import SelectType from "../controls/select-type";
import { debounce } from "underscore";
import styles from "./style.module.styl";
import hyper, { hyperStyled } from "@macrostrat/hyper";
import { Orientation } from "@attitude/core";
import { Attitude } from "app/data-manager";
import { InteractiveStereonetComponent } from "@attitude/notebook-ui/src/components/stereonet";
import { ErrorBoundary } from "@macrostrat/ui-components";
import { useAppState } from "app/hooks";
import "d3-selection-multi";

const h = hyperStyled(styles);

function transformRecord(record: Attitude): Orientation {
  return {
    strike: record.strike,
    dip: record.dip,
    rake: record.rake,
    minError: record.min_angular_error,
    maxError: record.max_angular_error,
  };
}

function DataPane(props) {
  const [width, setWidth] = React.useState(300);
  const { records } = props;
  const hovered = useAppState((d) => d.hovered);
  let hoveredRec = [];
  if (hovered != null) {
    hoveredRec = [transformRecord(hovered)];
  }
  return h(
    Measure,
    {
      onMeasure: debounce((d) => setWidth(d.width), 200),
    },
    h("div.sidebarComponent.bp3-text", [
      h(TagManager, {
        records: props.records,
        hovered,
      }),
      h("div", null, [
        h("h5", null, "Data type"),
        h(SelectType, {
          records,
          hovered,
          featureTypes: props.featureTypes,
        }),
      ]),
      h(ErrorBoundary, [
        h(InteractiveStereonetComponent, {
          data: records.map(transformRecord),
          hovered: hoveredRec,
          width,
        }),
      ]),
    ])
  );
}

export default DataPane;
