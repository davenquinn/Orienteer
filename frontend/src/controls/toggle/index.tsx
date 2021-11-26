/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Spine = require("spine");
const React = require('react');
const ReactDOM = require('react-dom');
const {Dragdealer} = require("dragdealer");
const style = require('./style');

const int = function(v) { if (v) { return 1; } else { return 0; } };

class Toggle extends React.Component {
  static initClass() {
    this.defaultProps = {
      values: [false,true],
      labels: ["Disabled","Enabled"],
      enabled: false,
      onChange() {}
    };
  }
  render() {
    const i = int(this.props.enabled);
    return <div className={`${style.toggle} dragdealer`}>
      <div className='red-bar handle'>{this.props.labels[i]}</div>
    </div>;
  }
  componentDidMount() {
    const el = ReactDOM.findDOMNode(this);
    this.slider = new Dragdealer(el, {
      x: int(this.props.enabled),
      steps: 2,
      callback: x=> {
        if (int(this.props.enabled) === x) { return; }
        const enabled = x === 1 ? true : false;
        return this.props.onChange(this.props.values[int(this.props.enabled)]);
      }
    });
    return console.log(this.slider);
  }
}
Toggle.initClass();

module.exports = Toggle;
