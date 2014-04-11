# encoding: UTF-8

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

class Figshare < Source

  def get_data(article, options={})

    return  { :events => [], :event_count => nil } unless article.doi[0..6] == CONFIG[:doi_prefix].to_s

    query_url = get_query_url(article)
    options[:source_id] = id
    result = get_json(query_url, options)

    if result.nil?
      nil
    elsif result.empty? or result["items"].empty?
      { :events => [], :event_count => nil }
    else
      views = result["items"].inject(0) { |sum, hash| sum + hash["stats"]["page_views"].to_i }
      downloads = result["items"].inject(0) { |sum, hash| sum + hash["stats"]["downloads"].to_i }
      likes = result["items"].inject(0) { |sum, hash| sum + hash["stats"]["likes"].to_i }
      total = views + downloads + likes

      event_metrics = { :pdf => downloads,
                        :html => views,
                        :shares => nil,
                        :groups => nil,
                        :comments => nil,
                        :likes => likes,
                        :citations => nil,
                        :total => total }

      { :events => result,
        :event_count => total,
        :event_metrics => event_metrics }
    end
  end

  def get_query_url(article)
    config.url % { :doi => article.doi }
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end
end