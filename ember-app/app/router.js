import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.resource('works', function() { });
  this.resource('sources', function() { });
  this.resource('agents', function() { });
  this.resource('users', function() { });
  this.resource('notifications', function() { });
  this.resource('publishers', function() { });
  this.resource('docs', function() { });
});

export default Router;
