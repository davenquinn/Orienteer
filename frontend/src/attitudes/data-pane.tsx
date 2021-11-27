/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from "react";
import Measure from "react-measure";
import Stereonet from "../controls/stereonet";
import TagManager from "../controls/tag-manager";
import SelectType from "../controls/select-type";
import { debounce } from "underscore";
import style from "./style.styl";

class DataPane extends React.Component {
  constructor(props) {
    super(props);

    this._setSize = this._setSize.bind(this);
    this.state = { width: 300 };
    // Create debounced method for setting size
    this.setSize = debounce(this._setSize, 200);
  }

  render() {
    return (
      <Measure onMeasure={this.setSize}>
        <div className={style.sidebarComponent}>
          <TagManager
            records={this.props.records}
            hovered={this.props.hovered}
          />
          <div>
            <h6>Data type</h6>
            <SelectType
              records={this.props.records}
              hovered={this.props.hovered}
              featureTypes={this.props.featureTypes}
            />
          </div>
          <Stereonet
            data={this.props.records}
            hovered={this.props.hovered}
            width={this.state.width}
          />
        </div>
      </Measure>
    );
  }

  _setSize(dimensions) {
    return this.setState({ width: dimensions.width });
  }
}

export default DataPane;
