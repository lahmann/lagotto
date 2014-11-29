import Ember from 'ember';

export function formatNumber(number, options) {
  // use the d3 number formatting function
  // return empty string for 0
  if (number > 0) {
    return number;
    // var formatNumber = d3.format(",.0f");
    // return formatNumber(number);
  } else if (options.hash['keepZero'] ) {
    return 0;
  } else {
    return "";
  }
}

export default Ember.Handlebars.makeBoundHelper(formatNumber);
