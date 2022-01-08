import "core-js/stable";
import "regenerator-runtime/runtime";
import h from "@macrostrat/hyper";
import { render } from "react-dom";
import App from "./app";
import "@blueprintjs/core/lib/css/blueprint-modern.css";
import "@macrostrat/ui-components/lib/esm/index.css";
import "leaflet/dist/leaflet.css";
import "./styles/layout.styl";

render(h(App), document.getElementById("app"));
