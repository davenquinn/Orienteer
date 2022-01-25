import "regenerator-runtime/runtime";
import h from "@macrostrat/hyper";
import { render } from "react-dom";

import App from "./app";
import "@blueprintjs/core/lib/css/blueprint-modern.css";
import "@macrostrat/ui-components/lib/esm/index.css";
import "leaflet/dist/leaflet.css";
import "./styles/layout.styl";

const container = document.createElement("div");
container.id = "app";
document.body.appendChild(container);

render(h(App), document.getElementById("app"));
