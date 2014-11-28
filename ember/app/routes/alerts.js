import Ember from 'ember';
import AuthenticatedRouteMixin from 'simple-auth/mixins/authenticated-route-mixin';

export default Ember.Route.extend(AuthenticatedRouteMixin, {
  model: function(params) {
    return Ember.RSVP.hash({
      alerts: this.store.find('alert', {
              page: params.page,
              hostname: params.hostname,
              agent_id: params.agent_id,
              source_id: params.source_id,
              class_Name: params.className,
              level: params.level }),
      groups: this.store.find('group'),
      agents: this.store.find('agent'),
      sources: this.store.find('source'),
      classNames: ["Net::HTTPUnauthorized", "Net::HTTPForbidden", "Net::HTTPRequestTimeOut", "Net::HTTPGatewayTimeOut", "Net::HTTPConflict", "Net::HTTPServiceUnavailable", "-", "Faraday::ResourceNotFound", "ActiveRecord::RecordInvalid", "-", "Delayed::WorkerTimeout", "DelayedJobError", "TooManyErrorsBySourceError", "SourceInactiveError", "TooManyWorkersError", "-", "EventCountDecreasingError", "EventCountIncreasingTooFastError", "HtmlRatioTooHighError", "WorkNotUpdatedError", "AgentNotUpdatedError", "CitationMilestoneAlert"],
      levels: ["debug", "info", "warn", "error", "fatal"]
    });
  }
});
