import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  otherNames: DS.attr(),
  prefixes: DS.attr(),
  updateDate: DS.attr('date')
});
