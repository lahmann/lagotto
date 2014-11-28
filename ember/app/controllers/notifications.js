import Ember from 'ember';

export default Ember.ObjectController.extend({
  queryParams: ['page','hostname','agent_id','source_id','level','className'],
  page: 1,
  hostname: null,
  agent_id: null,
  source_id: null,
  level: null,
  className: null,
  // to reset query params
  nullParams: null,

  agent: function() {
    return this.get('model.agents').findBy('id', this.get('agent_id'));
  }.property('model.agents'),
  source: function() {
    return this.get('model.sources').findBy('id', this.get('source_id'));
  }.property('model.sources'),
});
