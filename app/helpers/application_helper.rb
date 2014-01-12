# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2012 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'github/markdown'

module ApplicationHelper
  def login_link
    link_to "Sign In", user_omniauth_authorize_path(:cas), :id => "sign_in"
  end

  def markdown(text)
    GitHub::Markdown.render_gfm(text).html_safe
  end

  def state_label(state)
    if state == "working"
      '<span class="label label-success">working</span>'
    elsif state == "inactive"
      '<span class="label label-info">inactive</span>'
    elsif state == "disabled"
      '<span class="label label-warning">disabled</span>'
    elsif state == "available"
      '<span class="label label-primary">available</span>'
    elsif state == "retired"
      '<span class="label label-default">retired</span>'
    else
      state
    end
  end

  def article_statistics_report_path
    path = "/public/files/alm_report.zip"
    if File.exist?(Rails.root + path)
      path
    else
      nil
    end
  end

  def sources
    Source.order("group_id, display_name")
  end

  def alerts
    %w(Net::HTTPUnauthorized ActionDispatch::RemoteIp::IpSpoofAttackError Net::HTTPRequestTimeOut Delayed::WorkerTimeout Net::HTTPConflict Net::HTTPServiceUnavailable TooManyErrorsBySourceError SourceInactiveError EventCountDecreasingError EventCountIncreasingTooFastError ApiResponseTooSlowError HtmlRatioTooHighError ArticleNotUpdatedError SourceNotUpdatedError CitationMilestoneAlert)
  end

  def article_alerts
    %w(EventCountDecreasingError EventCountIncreasingTooFastError ApiResponseTooSlowError HtmlRatioTooHighError ArticleNotUpdatedError CitationMilestoneAlert)
  end

  def documents
    %w(Home Installation Setup Sources API Rake Alerts FAQ Roadmap Past-Contributors)
  end

  def roles
    %w(user staff admin)
  end
end
