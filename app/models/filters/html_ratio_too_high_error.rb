class HtmlRatioTooHighError < Filter
  def run_filter(state)
    source = Source.where(name: "counter").first
    first_response = Change.filter(state[:id]).first
    responses = first_response.get_html_ratio

    if responses.count > 0
      responses = responses.map do |response|
        doi = response['id'] && response['id'][8..-1]
        work = Work.where(doi: doi).first
        work_id = work && work.id
        date = Date.today.to_formatted_s(:short)

        { source_id: source.id,
          work_id: work_id,
          level: Notification::WARN,
          message: "HTML/PDF ratio is #{response['value']['ratio']} with #{response['value']['html']} HTML views on #{date}" }
      end
      raise_notifications(responses)
    end

    responses.count
  end
end

module Exceptions
  class HtmlRatioTooHighError < ApiResponseError; end
end
