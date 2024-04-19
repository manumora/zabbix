##############################################################################
# Module:      Zabbix APPS installation
# Date:        26-Oct-2023.
# Copyright:   2024 - Manuel Mora Gordillo       <manuel.mora.gordillo @nospam@ gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
#############################################################################

class zabbix_apps {
    
    file {"/etc/zabbix/run":
        ensure => "directory",
    }

    ### Monitor puppet ###

    file {"/var/lib/puppet/state":
        ensure => "directory",
        recurse => true,
        mode   => "0644"
    }

    file {"/etc/zabbix/zabbix_agent2.d/zabbix_check_puppetstate.conf":
        source => "puppet:///modules/zabbix_apps/zabbix_check_puppetstate.conf",
        owner => root, group => root, mode => 644
    }

    file {"/etc/zabbix/run/zabbix_check_puppetstate":
        source => "puppet:///modules/zabbix_apps/zabbix_check_puppetstate",
        owner => root, group => root, mode => 755,
        require => File["/etc/zabbix/run"]
    }

    ### Monitor network interface ###

    file {"/etc/zabbix/zabbix_agent2.d/interface_info.conf":
        source => "puppet:///modules/install_zabbix_agent/interface_info.conf",
        owner => root, group => root, mode => 644
    }

    file {"/etc/zabbix/run/interface_info.py":
        source => "puppet:///modules/install_zabbix_agent/interface_info.py",
        owner => root, group => root, mode => 755,
        require => File["/etc/zabbix/run"]
    }

    ### Monitor logged user ###

    file {"/etc/zabbix/zabbix_agent2.d/user_logged.conf":
        source => "puppet:///modules/install_zabbix_agent/user_logged.conf",
        owner => root, group => root, mode => 644
    }

    ### Monitor temperatures ###

    exec {"python3-psutil":
        command => "/usr/bin/apt install -y python-yaml",
        unless => "/usr/bin/facter sistema | /bin/grep -q 'ubuntu2204'"
    }

    file {"/etc/zabbix/zabbix_agent2.d/temperatures.conf":
        source => "puppet:///modules/install_zabbix_agent/temperatures.conf",
        owner => root, group => root, mode => 644
    }

    file {"/etc/zabbix/run/temperatures.py":
        source => "puppet:///modules/install_zabbix_agent/temperatures.py",
        owner => root, group => root, mode => 755,
        require => File["/etc/zabbix/run"]
    }
}
