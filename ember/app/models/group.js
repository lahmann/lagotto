import DS from 'ember-data';

export default DS.Model.extend({
  title: DS.attr('string'),
  agents: DS.hasMany('agent', {async: true}),
  sources: DS.hasMany('source', {async: true})
});
