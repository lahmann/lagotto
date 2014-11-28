import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  username: DS.attr('string'),
  email: DS.attr('string'),
  role: DS.attr('string'),
  createDate: DS.attr('date'),
  updateDate: DS.attr('date'),
  publisher: DS.belongsTo('publisher', {async: true})
});
