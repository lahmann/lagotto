import Ember from 'ember';

export default Ember.Route.extend({
  model: function() {
    return Ember.RSVP.hash({
      groups: this.store.find('group'),
      agents: this.store.find('agent')
    });
  }
});