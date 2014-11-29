// Format time into human-readable format
// use the d3 time formatting function
// optional format parameter allows for different time formats

import Ember from 'ember';
// import d3 from "d3";

export function formatTime(time) {
  return time;
  // var format = typeof options.hash['format'] !== 'undefined' ? options.hash['format'] : "%d %b %H:%M UTC";
  // var formatTime = d3.time.format.utc(format);

  // return formatTime(time);
}

export default Ember.Handlebars.makeBoundHelper(formatTime);
