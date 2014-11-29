import DS from 'ember-data';

export default DS.Model.extend({
  doi: DS.attr('string'),
  pmid: DS.attr('string'),
  pmcid: DS.attr('string'),
  mendeley_uuid: DS.attr('string'),
  url: DS.attr('string'),
  canonicalUrl: DS.attr('string'),
  title: DS.attr('string'),
  issued: DS.attr(),

  viewed: DS.attr('number'),
  saved: DS.attr('number'),
  discussed: DS.attr('number'),
  cited: DS.attr('number'),

  updateDate: DS.attr('date'),

  issuedDate: function() {
    var dateParts = this.get('issued')["date-parts"][0];
    var date = datePartsToDate(dateParts);
    return date;
  }.property('issued')
});

// construct date object from date parts
function datePartsToDate(dateParts) {
  var len = dateParts.length;

  // not in expected format
  if (len === 0 || len > 3) { return null; }

  // turn numbers to strings and pad with 0
  for (var i = 0; i < len; ++i) {
    if (dateParts[i] < 10) {
      dateParts[i] = "0" + dateParts[i];
    } else {
      dateParts[i] = "" + dateParts[i];
    }
  }

  // convert to date, workaround for different time zones
  var timestamp = Date.parse(dateParts.join('-') + 'T12:00');
  return new Date(timestamp);
}

