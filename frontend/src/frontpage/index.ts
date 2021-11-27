/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const { Link } = require("react-router-dom");
const style = require("./main.styl");
const h = require("react-hyperscript");

class Frontpage extends React.Component {
  render() {
    return h("div", { className: style.main }, [
      h("h1", "Orienteer"),
      h(
        "p",
        { className: "subtitle" },
        "An application to manage the collection of attitude data"
      ),
      h("ul", [
        h("li", [h(Link, { to: "/map" }, "Map")]),
        h("li", [h(Link, { to: "/stereonet" }, "Stereonet")]),
      ]),
    ]);
  }
}

module.exports = Frontpage;
