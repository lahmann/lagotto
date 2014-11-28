import Ember from 'ember';

export default Ember.Route.extend({
  model: function() {
    return Ember.RSVP.hash({
           users: this.store.find('user'),
           roles: ["admin", "staff", "user"]
    });
  }
});
