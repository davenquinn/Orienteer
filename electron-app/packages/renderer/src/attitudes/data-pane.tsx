/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react');
const Measure = require('react-measure');
const Stereonet = require("../controls/stereonet");
const TagManager = require("../controls/tag-manager");
const SelectType = require("../controls/select-type");
const {debounce} = require("underscore");
const style = require('./style');

class DataPane extends React.Component {
  constructor(props){
    this._setSize = this._setSize.bind(this);
    super(props);
    this.state =
      {width: 300};
    // Create debounced method for setting size
    this.setSize = debounce(this._setSize, 200);
  }

  render() {
    return <Measure onMeasure={this.setSize}>
      <div className={style.sidebarComponent}>
        <TagManager records={this.props.records} hovered={this.props.hovered} />
        <div>
          <h6>Data type</h6>
          <SelectType
            records={this.props.records}
            hovered={this.props.hovered}
            featureTypes={this.props.featureTypes} />
        </div>
        <Stereonet
          data={this.props.records}
          hovered={this.props.hovered}
          width={this.state.width} />
      </div>
    </Measure>;
  }

  _setSize(dimensions){
    return this.setState({width: dimensions.width});
  }
}

module.exports = DataPane;
