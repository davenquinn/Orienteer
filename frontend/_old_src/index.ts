import h from "@macrostrat/hyper";
import { render } from "react-dom";

const App = () => h("div", "Hello, world!");

render(h(App), document.getElementById("app"));
