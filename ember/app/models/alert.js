import DS from 'ember-data';

export default DS.Model.extend({
  level: DS.attr('string'),
  className: DS.attr('string'),
  message: DS.attr('string'),
  agent: DS.belongsTo('agent', {async: true}),
  source: DS.belongsTo('source', {async: true}),
  work: DS.belongsTo('work', {async: true}),
  createDate: DS.attr('date')
});
