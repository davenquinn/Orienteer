/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require('react');
const E = require('elemental');

const styles = require('./styles');

class NewButton extends React.Component {
  render() {
    return <button type='button' className='btn btn-default' onClick={this.props.handler}>
      <i className="fa fa-plus"> New item</i>
    </button>;
  }
}

class EditControl extends React.Component {
  constructor(props){
    super(props);
  }
  render() {
    let txt;
    const h = this.props.handlers;
    console.log(h);
    if (this.props.complete) {
      txt = 'Done';
    } else {
      txt = 'Edit vertices';
    }

    const opts = ['LineString','Polygon'].map(d=> {
      return {
        label:d,
        value: d,
        selected: this.props.featureType===d
      };
  });

    return <div>
      <E.FormSelect
        label="Feature type"
        options={opts}
        onChange={h.onChangeType} />
      <E.Button
        type='default-success'
        onClick={h.onFinish}>{txt}</E.Button>
    </div>;
  }
}

class ItemPanel extends React.Component {
  constructor(props){
    super(props);
  }
  renderToolbar() {
    const handlers = this.props.toolbarHandlers;
    return <div>
      <button
        type='button'
        className='btn btn-warning fa fa-pencil btn-sm'
        onClick={handlers.edit}> Edit</button>
      <button type='button' className='btn btn-danger fa fa-trash btn-sm'> Delete</button>
      <button
        type='button'
        className='btn btn-default fa btn-sm'
        onClick={handlers.cancel}>Cancel</button>
    </div>;
  }
  render() {
    return <div className={styles.item}>
      {!this.props.editing.enabled ? this.renderToolbar() : undefined}
      {this.props.editing.enabled ? <EditControl
        featureType={this.props.editing.targetType}
        handlers={this.props.editHandlers} /> : undefined}
    </div>;
  }
}

class Sidebar extends React.Component {
  constructor(props){
    super(props);
    this.state = {
      item: null,
      editing: {
        targetType: 'Polygon',
        enabled: false,
        complete: false
      }
    };
  }
  render() {
    return <div className={styles.sidebar}>
      {(this.state.item == null) ? <NewButton handler={this.props.newHandler} /> : undefined}
      {(this.state.item != null) ? <ItemPanel
        item={this.state.item}
        editing={this.state.editing}
        toolbarHandlers={this.props.toolbarHandlers}
        editHandlers={this.props.editHandlers} /> : undefined}
    </div>;
  }
}

module.exports = Sidebar;
