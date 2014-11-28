// Format date into human-readable format
// use the d3 date formatting function
// optional len parameter allows formatting of partial dates, e.g. year only
import Ember from "ember";
// import d3 from "d3";

export default Ember.Handlebars.makeBoundHelper('format-date', function(date) {
  return date;
  // var len = options.hash['len'],
  //     formatDate = d3.time.format.utc("%B %d, %Y"),
  //     formatMonthYear = d3.time.format.utc("%B %Y"),
  //     formatYear = d3.time.format.utc("%Y");

  // len = typeof len !== 'undefined' ? len : 3;

  // switch (len) {
  //   case 1:
  //     return formatYear(date);
  //   case 2:
  //     return formatMonthYear(date);
  //   case 3:
  //     return formatDate(date);
  // }
});
