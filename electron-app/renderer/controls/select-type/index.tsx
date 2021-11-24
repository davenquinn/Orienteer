/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react');
const Select = require('react-select');
const h = require('react-hyperscript');
require("react-select/dist/react-select.css");

class SelectType extends React.Component {
  render() {
    let rec;
    const {records, hovered, featureTypes} = this.props;
    let recs = (hovered != null) ? [hovered] : records;
    recs = recs.map(d => d.class);

    const allSame = recs.every(e => e === recs[0]);
    if (allSame) {
      rec = recs[0] || null;
    } else {
      rec = 'multiple';
    }

    const t = featureTypes.map(d => ({
      value: d.id,
      label: d.id,
      color: d.color
    }));
    if (recs.length > 1) {
      t.push({value: 'multiple', label: 'Multiple', color: 'gray'});
    }

    const onChange = type=> {
      let val;
      if (hovered != null) { return false; }
      console.log(`Changed select to ${type}`);
      if (type != null) {
        val = type.value;
      } else {
        val = 'null';
      }
      return app.data.changeClass(val, this.props.records);
    };

    const renderOption = function(opt){
      const v = opt.value.replace('_',' ');
      v.charAt(0).toUpperCase()+v.slice(1);
      return v;
    };

    return h(Select, {name: "select-type", value: rec, options:t, onChange, optionRenderer:renderOption});
  }
}

module.exports = SelectType;

