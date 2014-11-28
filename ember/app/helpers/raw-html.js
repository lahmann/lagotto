import Ember from 'ember';

export function rawHtml(html) {
  return new Ember.Handlebars.SafeString(html);
}

export default Ember.Handlebars.makeBoundHelper(rawHtml);
