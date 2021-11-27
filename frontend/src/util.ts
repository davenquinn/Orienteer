/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const ReactDOM = require("react-dom");

const reactifySpine = function (cls, options) {
  // Wrap Spine controller in React component
  let SpineWrapper;
  return (SpineWrapper = class SpineWrapper extends React.Component {
    constructor(props) {
      this.props = props;
      super(this.props);
    }
    render() {
      return React.createElement("div");
    }
    componentDidMount() {
      options.el = ReactDOM.findDOMNode(this);
      return (this.component = new cls(options));
    }
    componentWillUnmount() {}
    shouldComponentUpdate() {
      return false;
    }
  });
};

module.exports = { reactifySpine };
