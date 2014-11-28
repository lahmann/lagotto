import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('login');
  this.resource('apiRequests');
  this.resource('status');
  this.resource('works');
  this.resource('work', { path: '/works/:work_id' });
  this.resource('sources');
  this.resource('source', { path: '/sources/:source_id' });
  this.resource('publishers');
  this.resource('publisher', { path: '/publishers/:publisher_id' });
  this.resource('agents');
  this.resource('agent', { path: '/agents/:agent_id' });
  this.resource('users');
  this.resource('filters');
  this.resource('filter', { path: '/filters/:filter_id' });
  this.resource('alerts');
  this.resource('docs');
  this.resource('doc', { path: '/docs/:doc_id'});
  this.route('works/view');
  this.route('sources/view');
  this.route('agents/view');
  this.route('works/show');
  this.route('sources/show');
});

export default Router;
