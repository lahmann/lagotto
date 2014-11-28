import Ember from 'ember';

export default Ember.ObjectController.extend({
  queryParams: ['page','source_id','publisher_id','className','q', 'order'],
  page: 1,
  source_id: null,
  publisher_id: null,
  className: null,
  q: null,
  order: null,
  // to reset query params
  nullParams: null,

  source: function() {
    return this.get('model.sources').findBy('id', this.get('source_id'));
  }.property('model.sources'),
  hasManyPublishers: function() {
    var publishers = this.get('model.publishers');
    return publishers.length > 0;
  }.property('model.publishers')
});
