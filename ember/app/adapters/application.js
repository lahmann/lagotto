import Ember from "ember";
import DS from "ember-data";

export default DS.ActiveModelAdapter.extend({
  namespace: 'api/v6',
  headers: {
    "Authorization": "Token token=8897f9349100728d66d64d56bc21254bb346a9ed21954933"
  }
});

var inflector = Ember.Inflector.inflector;
inflector.uncountable('status');
