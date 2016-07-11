# === Define: device_group
#
# This resource type defines a device group in your LogicMonitor account.
# The purpose is to introduce the following information into a puppetDB catalog for use by the LogicMonitor Master node.
#
# === Parameters
#
# [*namevar*]
#    Or "fullpath" 
#    Sets the path of the group. Path must start with a "/"
#
# [*description*]
#    Set the description shown in the LogicMonitor portal
#
# [*properties*]
#    Must be a Hash object of property names and associated values.
#    Set custom properties at the group level in the LogicMonitor Portal
#
# [*alertenable*]
#    Boolean value setting whether to deliver alerts on devices within this group.
#    Overrides device level alert enable setting
#
# [*mode*]
#    Set the puppet management mode.
#    :purge - will update all information for puppet controlled groups.
#             Information not in puppet will be deleted.
#
# === Examples
#
# device_group { "/puppet":
#   properties => {"mysql.port"=>1234, "snmp.community"=>"puppetlabs" },
#     description => 'This is the top level puppet managed device group',
# }
#
# device_group {"/puppetlabs":}
#
# device_group { "/puppetlabs/puppet":
#   alertenable => false,
#   description => "A very useful description",
# }
#
# === Authors
#
# Sam Dacanay <sam.dacanay@logicmonitor.com>
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# === Copyright
#
# Copyright 2016 LogicMonitor, Inc
#

Puppet::Type.newtype(:lm_device_group) do
  @doc = 'Manage a LogicMonitor Device Group'
  ensurable

  newparam(:fullpath, :namevar => true) do
    desc 'The full path including all parent groups. Format: \"/parent/child\"'
    validate do |value|
      unless value.start_with?('/')
        raise ArgumentError, "#{value} is not a valid path"
      end
    end
  end

  newproperty(:description) do
    desc 'The long text description of a device group'
  end

  newproperty(:properties) do
    desc 'A hash where the keys represent the property names and the values represent the property values. '\
        '(e.g. {\"snmp.version\" => \"v2c\", \"snmp.community\" => \"public\"})'
    defaultto {}
    validate do |value|
      unless value.class == Hash
        raise ArgumentError, "#{value} is not a valid set of group properties. Properties must be in the format "\
                             "{\"propName0\"=>\"propValue0\",\"propName1\"=>\"propValue1\", ... }"
      end
    end
  end

  newproperty(:alertenable) do
    desc 'Set alerting at the device group level. A value of false will turn off alerting for all devices and subgroups '\
         'in that group due to LogicMonitor\'s inheritance rules. For further reading: '\
         'http://help.logicmonitor.com/using/i-got-an-alert-now-what/how-do-prevent-alerts-on-a-host-or-group/'
    newvalues(:true, :false)
  end

  newparam(:mode) do
    desc 'Set how strict puppet is regarding changes made on the LogicMonitor device group. Valid inputs: '\
         '\"purge\" - puppet will remove all properties not set by puppet (for groups under puppet control) '\
         'Additional options coming soon.'
    newvalues(:purge)
    defaultto :purge
  end

  newparam(:account) do
    desc 'This is the LogicMonitor account name'
  end

  newparam(:user) do
    desc 'This is the LogicMonitor username'
  end

  newparam(:password) do
    desc 'This is the password for the LogicMonitor user specified'
  end
end