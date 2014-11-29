import Ember from 'ember';

export function formatBytes(bytes) {
  var thresh = 1000;
  if (bytes < thresh) { return bytes + ' B'; }
  var units = ['kB','MB','GB','TB','PB'];
  var u = -1;
  do {
    bytes /= thresh;
    ++u;
  } while (bytes >= thresh);
  return bytes.toFixed(1)+' '+units[u];
}

export default Ember.Handlebars.makeBoundHelper(formatBytes);
