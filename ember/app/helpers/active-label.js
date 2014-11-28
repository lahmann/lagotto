import Ember from 'ember';

export function activeLabel(status) {
  if (status === "active") {
    return status;
  } else {
    return new Ember.Handlebars.SafeString('<span class="label label-info">inactive</span>');
  }
}

export default Ember.Handlebars.makeBoundHelper(activeLabel);
