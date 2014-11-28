import DS from 'ember-data';

export default DS.Model.extend({
  worksCount: DS.attr('number'),
  worksLast30Count: DS.attr('number'),
  eventsCount: DS.attr('number'),
  responsesCount: DS.attr('number'),
  requestsCount: DS.attr('number'),
  alertsCount: DS.attr('number'),
  usersCount: DS.attr('number'),
  sourcesActiveCount: DS.attr('number'),
  delayedJobsActiveCount: DS.attr('number'),
  version: DS.attr('string'),
  outdatedVersion: DS.attr('boolean'),
  couchdbSize: DS.attr('number'),
  workers: DS.attr(),
  agents: DS.attr(),
  updateDate: DS.attr('date')
});
