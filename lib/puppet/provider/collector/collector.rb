# collector.rb
# === Authors
#
# Sam Dacanay <sam.dacanay@logicmonitor.com>
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# Copyright 2016 LogicMonitor, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#         limitations under the License.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'logicmonitor'))

Puppet::Type.type(:collector).provide(:collector, :parent => Puppet::Provider::Logicmonitor) do
  desc 'This provider handles the creation, status, and deletion of collectors'

  # Creates a Collector
  def create
    start = Time.now
    debug "Creating Collector \"#{resource[:description]}\""
    create_collector = rest(nil,
                            Puppet::Provider::Logicmonitor::COLLECTORS_ENDPOINT,
                            Puppet::Provider::Logicmonitor::HTTP_POST,
                            nil,
                            build_collector_json(resource[:description]))
    alert(create_collector) unless valid_api_response?(create_collector)
    debug "Finished in #{(Time.now-start)*1000.0} ms"
  end

  # Deletes a Collector
  def destroy
    start = Time.now
    debug "Deleting Collector \"#{resource[:description]}\""
    collector = rest(nil,
                     Puppet::Provider::Logicmonitor::COLLECTORS_ENDPOINT,
                     Puppet::Provider::Logicmonitor::HTTP_GET,
                     build_query_params("description:#{resource[:description]}", 'id', 1))
    if valid_api_response?(collector, true)
      debug "Found Collector: #{collector}"
      delete_collector = rest(nil,
                              Puppet::Provider::Logicmonitor::COLLECTOR_ENDPOINT % collector['data']['items'][0]['id'],
                              Puppet::Provider::Logicmonitor::HTTP_DELETE)
      alert(delete_collector) unless valid_api_response?(delete_collector, false, true)
      debug "Finished in #{(Time.now-start)*1000.0} ms"
    else
      alert collector.to_s
    end
  end

  # Checks if Collector exists
  def exists?
    start = Time.now
    debug "Checking if Collector exists with description \"#{resource[:description]}\""
    collectors = rest(nil,
                      Puppet::Provider::Logicmonitor::COLLECTORS_ENDPOINT,
                      Puppet::Provider::Logicmonitor::HTTP_GET,
                      build_query_params("description:#{resource[:description]}", 'id', 1))
    if valid_api_response?(collectors, true)
      debug "Finished in #{(Time.now-start)*1000.0} ms"
      return true
    end
    debug "Finished in #{(Time.now-start)*1000.0} ms"
    false
  end

  # Builds JSON required to create a Collector
  # description: description of collector
  def build_collector_json(description)
    collector_hash = Hash.new
    collector_hash['description'] = description

    # The Rest of the fields are default values.
    # This can be modified to include customer entered values, but then need to implement update functionality
    collector_hash['backupAgentId'] = 0
    collector_hash['enableFailBack'] = true
    collector_hash['resendIval'] = 15
    collector_hash['suppressAlertClear'] = false
    collector_hash['escalatingChainId'] = 0
    collector_hash['collectorGroupId'] = 1

    collector_hash.to_json
  end
end