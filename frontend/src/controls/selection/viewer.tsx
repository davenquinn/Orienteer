/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const $ = require("jquery");
const d3 = require("d3");
const style = require("./style.styl");
const SelectionList = require("./list");
const { Button, Intent } = require("@blueprintjs/core");

const sf = d3.format(">8.1f");
const df = d3.format(">6.1f");

const strikeDip = function (d) {
  const strike = sf(d.strike);
  const dip = df(d.dip);
  return (
    <span>
      <span className="strike">{strike}º</span>{" "}
      <span className="dip">{dip}º</span>
    </span>
  );
};

class GroupedAttitudeControl extends React.Component {
  constructor(...args) {
    super(...args);
    this.shouldDestroyGroup = this.shouldDestroyGroup.bind(this);
  }

  render() {
    // Group type selector should go here...
    const rec = app.data.get(...this.props.data.measurements);
    return (
      <div>
        <h6>Component planes</h6>
        <SelectionList records={rec} hovered={this.props.hovered} />
        <p>
          <Button
            intent={Intent.DANGER}
            iconName="ungroup"
            onClick={this.shouldDestroyGroup}
          >
            Ungroup
          </Button>
        </p>
      </div>
    );
  }

  shouldDestroyGroup() {
    return app.data.destroyGroup(this.props.data.id);
  }
}

class DataViewer extends React.Component {
  static initClass() {
    this.defaultProps = {
      hovered: false,
      focusItem() {},
      data: null,
    };
  }
  constructor(props) {
    this.onNetworkData = this.onNetworkData.bind(this);
    super(props);
    this.state = { content: <span className="loading">Loading...</span> };
  }

  componentDidMount() {
    if (this.props.data == null) {
      return this.setState({
        content: <p>Hover over data to display fit statistics.</p>,
      });
    } else {
      const url = `${window.server_url}/elevation/attitude/${this.props.data.id}/data.html`;
      return $.get(url, this.onNetworkData);
    }
  }

  onNetworkData(data) {
    const c = <div dangerouslySetInnerHTML={{ __html: data }} />;
    return this.setState({ content: c });
  }

  renderGroupData() {
    return (
      <GroupedAttitudeControl
        data={this.props.data}
        hovered={this.props.hovered}
      />
    );
  }

  render() {
    const grouped = this.props.data.is_group;
    const method = grouped ? this.props.focusItem : function () {};

    return (
      <div>
        <h4>
          {grouped ? "Group" : "Attitude"} {this.props.data.id}
        </h4>
        <SelectionList records={[this.props.data]} focusItem={method} />
        {grouped ? this.renderGroupData() : undefined}
        <div className="data-container">
          <h6>Axis-aligned residuals</h6>
          <img
            src={`${window.server_url}/elevation/attitude/${this.props.data.id}/axis-aligned.png`}
          />
        </div>
      </div>
    );
  }
}
DataViewer.initClass();

module.exports = DataViewer;
