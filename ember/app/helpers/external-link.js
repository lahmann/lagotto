import Ember from 'ember';

export function externalLink(text, url) {
  text = Ember.Handlebars.Utils.escapeExpression(text);
  url  = Ember.Handlebars.Utils.escapeExpression(url);

  var result = '<a href="' + url + '">' + text + '</a>';

  return new Ember.Handlebars.SafeString(result);
}

export default Ember.Handlebars.makeBoundHelper(externalLink);
