/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import { useState } from "react";
import Measure from "react-measure";
//import Stereonet from "../controls/stereonet";
import TagManager from "../controls/tag-manager";
import SelectType from "../controls/select-type";
import { debounce } from "underscore";
import styles from "./style.module.styl";
import { hyperStyled } from "@macrostrat/hyper";

import { InteractiveStereonetComponent } from "@attitude/notebook-ui/src/components/stereonet";
import { ErrorBoundary } from "@macrostrat/ui-components";
import { useAppState } from "app/hooks";
import { NumericInput, Tab, Tabs, FormGroup } from "@blueprintjs/core";
import { NewStereonet, transformRecord } from "./new-stereonet";

const h = hyperStyled(styles);

function DataPane(props) {
  const [width, setWidth] = useState(300);
  const { records } = props;
  const hovered = useAppState((d) => d.hovered);
  const [scale, setScale] = useState(200);
  const [dipLabelSpacing, setDipLabelSpacing] = useState(5);

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
      h("h4", null, "Feature class"),
      h(SelectType),
      h(Tabs, { id: "stereonet-tabs", renderActiveTabPanelOnly: true }, [
        h(Tab, {
          id: "new-stereonet-tab",
          title: "New stereonet",
          panel: h(ErrorBoundary, null, [
            h(NewStereonet, {
              width,
              height: width,
              scale: (scale * width) / 200,
              dipLabelSpacing,
            }),
            h(FormGroup, { label: "Scale", inline: true }, [
              h(NumericInput, {
                value: scale,
                onValueChange(v) {
                  setScale(v);
                },
              }),
            ]),
            h(FormGroup, { label: "Dip label spacing", inline: true }, [
              h(NumericInput, {
                value: dipLabelSpacing,
                onValueChange(v) {
                  setDipLabelSpacing(v);
                },
              }),
            ]),
          ]),
        }),
        h(Tab, {
          id: "old-stereonet-tab",
          title: "Legacy",
          panel: h(ErrorBoundary, [
            h(InteractiveStereonetComponent, {
              data: records.map(transformRecord),
              hovered: hoveredRec,
              width,
            }),
          ]),
        }),
      ]),
    ])
  );
}

export default DataPane;
