/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
//GroupedDataControl = require "./grouped-data"
const SelectionList = require("./list");
const ViewerControl = require("./viewer");
const React = require("react");
const style = require("./style.styl");
const h = require("react-hyperscript");
const { NonIdealState, Button } = require("@blueprintjs/core");

class SelectionControl extends React.Component {
  constructor(...args) {
    super(...args);
    this.createGroup = this.createGroup.bind(this);
  }

  render() {
    const a = this.props.actions;
    return (
      <div className={`${style.selectionControl}`}>
        <h3>Selection</h3>
        <SelectionList
          records={this.props.records}
          hovered={this.props.hovered}
          removeItem={a.removeItem}
          focusItem={a.focusItem}
          allowRemoval={true}
        />
        <p>
          <button
            className="group pt-button pt-intent-primary pt-icon-group-objects"
            onClick={this.createGroup}
          >
            Group measurements
          </button>
        </p>
      </div>
    );
  }

  createGroup() {
    return app.data.createGroup(this.props.records);
  }
}

class CloseButton extends React.Component {
  render() {
    return (
      <button
        className={`pt-button pt-intent-danger pt-icon-${this.props.icon}`}
        onClick={this.props.action}
      >
        {this.props.children}
      </button>
    );
  }
}

class Sidebar extends React.Component {
  static defaultProps = {
    records: [],
    hovered: null,
    openGroupViewer: null,
  };
  constructor(props) {
    super(props);
    this.focusItem = this.focusItem.bind(this);
    this.clearFocus = this.clearFocus.bind(this);
    this.state = { focused: null };
  }
  render() {
    let core;
    const rec = this.props.records;

    // Render nothing for empty selection
    if (rec.length === 0) {
      return h(NonIdealState, {
        title: "No items selected",
        description: "Select some items on the map",
        visual: "send-to-map",
      });
    }

    let closeButton = (
      <CloseButton action={app.data.clearSelection} icon="cross">
        Clear selection
      </CloseButton>
    );
    if (this.state.focused != null) {
      closeButton = (
        <CloseButton action={this.clearFocus} icon="chevron-left">
          Back to selection
        </CloseButton>
      );
      core = (
        <ViewerControl
          data={this.state.focused}
          hovered={this.props.hovered}
          focusItem={this.focusItem}
        />
      );
    } else if (rec.length === 1) {
      core = (
        <ViewerControl
          data={rec[0]}
          hovered={this.props.hovered}
          focusItem={this.focusItem}
        />
      );
    } else {
      const actions = {
        removeItem: app.data.updateSelection.bind(app.data),
        focusItem: this.focusItem,
        createGroup: app.data.createGroupFromSelection,
      };
      core = (
        <SelectionControl
          records={rec}
          hovered={this.props.hovered}
          actions={actions}
        />
      );
    }

    return (
      <div className={`${style.sidebar} flex flex-container`}>
        {core}
        <div className="modal-controls">
          <Button onClick={this.props.openGroupViewer}>View group</Button>
          {closeButton}
        </div>
      </div>
    );
  }

  focusItem(d) {
    return this.setState({ focused: d });
  }

  clearFocus(d) {
    return this.setState({ focused: null });
  }
}

module.exports = Sidebar;
