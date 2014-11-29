import Ember from 'ember';

export default Ember.Route.extend({
  model: function(params) {
    return Ember.RSVP.hash({
           works: this.store.find('work', {
                  page: params.page,
                  source_id: params.source_id,
                  publisher_id: params.publisher_id,
                  order: params.order }),
           sources: this.store.find('source'),
           publishers: this.store.find('publisher'),
           workClassNames: ["EventCountDecreasingError", "EventCountIncreasingTooFastError", "HtmlRatioTooHighError", "WorkNotUpdatedError", "CitationMilestoneAlert"]
    });
  }
});
