import Ember from 'ember';
// import d3 from "d3";

export function signPosts(work) {
  var a = [];
  var b = [];
  var viewed = work.get('viewed');
  var cited = work.get('cited');
  var saved = work.get('saved');
  var discussed = work.get('discussed');
  // var formatFixed = d3.format(",.0f");

  // if (viewed > 0) { b.push("Viewed: " + formatFixed(viewed)); }
  // if (cited > 0) { b.push("Cited: " + formatFixed(cited)); }
  // if (saved > 0) { b.push("Saved: " + formatFixed(saved)); }
  // if (discussed > 0) { b.push("Discussed: " + formatFixed(discussed)); }
  if (viewed > 0) { b.push("Viewed: " + viewed); }
  if (cited > 0) { b.push("Cited: " + cited); }
  if (saved > 0) { b.push("Saved: " + saved); }
  if (discussed > 0) { b.push("Discussed: " + discussed); }
  if (b.length > 0) {
    a.push(b.join(" • "));
    return a.join(" | ");
  } else {
    return a;
  }
}

export default Ember.Handlebars.makeBoundHelper(signPosts);

// // function signpostsToString(work) {
// //   if (source != "") {
// //     s = work["sources"].filter(function(d) { return d.name == source })[0];
// //     a = [s.title + ": " + formatFixed(s.metrics.total)];
// //   } else if (order != "") {
// //     s = work["sources"].filter(function(d) { return d.name == order })[0];
// //     a = [s.title + ": " + formatFixed(s.metrics.total)];
// //   } else {
// //     a = [];
// //   }
