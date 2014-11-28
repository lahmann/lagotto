import DS from 'ember-data';

export default DS.Model.extend({
  title: DS.attr('string'),
  group: DS.belongsTo('group', {async: true}),
  status: DS.attr('string'),
  jobs: DS.attr(),
  responses: DS.attr(),
  articles: DS.attr(),
  errorCount: DS.attr('number'),
  updateDate: DS.attr('date')
});
