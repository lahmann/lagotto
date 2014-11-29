import DS from 'ember-data';

export default DS.Model.extend({
  title: DS.attr('string'),
  description: DS.attr('string'),
  group: DS.belongsTo('group', {async: true}),
  workCount: DS.attr('number'),
  eventCount: DS.attr('number'),
  status: DS.attr('string'),
  updateDate: DS.attr('date')
});
