INTERNAL_PARAMS = %w(controller action format _method only_path)

ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
  if payload[:params]["api_key"].present? && payload[:status].to_i < 400
    ApiRequest.create! do |api_request|
      api_request.format = payload[:format] || "html"
      api_request.view_duration = payload[:view_runtime]
      api_request.db_duration = payload[:db_runtime]
      params = payload[:params].except(*INTERNAL_PARAMS)
      api_request.api_key = params["api_key"]
      api_request.info = params["info"]
      if params["source"] || params["ids"]
        api_request.source = params["source"]
        api_request.ids = params["ids"]
      else
        api_request.source = params["id"]
        api_request.ids = payload[:controller]
      end
    end
  end
end

ActiveSupport::Notifications.subscribe "api_response.get" do |name, start, finish, id, payload|
  ApiResponse.create! do |api_response|
    api_response.agent_id = payload[:agent_id]
    api_response.duration = (finish - start) * 1000
  end
end

ActiveSupport::Notifications.subscribe "change.get" do |name, start, finish, id, payload|
  Change.create! do |change|
    change.work_id = payload[:work_id]
    change.source_id = payload[:source_id]
    change.trace_id = payload[:trace_id]
    change.skipped = payload[:skipped]
    change.event_count = payload[:event_count]
    change.previous_count = payload[:previous_count]
    change.update_interval = payload[:update_interval]
  end
end
