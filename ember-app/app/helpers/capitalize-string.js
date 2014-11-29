import Ember from 'ember';

export function capitalizeString(str) {
  return str.charAt(0).toUpperCase() + str.substring(1);
}

export default Ember.Handlebars.makeBoundHelper(capitalizeString);
