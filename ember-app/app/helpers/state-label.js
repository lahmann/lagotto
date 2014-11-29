import Ember from 'ember';

export function stateLabel(state) {
  switch (state) {
    case "working":
      return new Ember.Handlebars.SafeString('<span class="label label-success">working</span>');
    case "inactive":
      return new Ember.Handlebars.SafeString('<span class="label label-info">inactive</span>');
    case "disabled":
      return new Ember.Handlebars.SafeString('<span class="label label-warning">disabled</span>');
    case "available":
      return new Ember.Handlebars.SafeString('<span class="label label-default">available</span>');
    case "retired":
      return new Ember.Handlebars.SafeString('<span class="label label-primary">retired</span>');
    default:
      return state;
  }
}

export default Ember.Handlebars.makeBoundHelper(stateLabel);
