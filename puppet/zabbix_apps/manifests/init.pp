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

    # Reinicia el agente solo cuando cambia algún .conf de zabbix_agent2.d,
    # para que cargue los UserParameter nuevos o modificados.
    exec {"restart-zabbix-agent2":
        command => "/bin/systemctl restart zabbix-agent2",
        refreshonly => true
    }

    ### Monitor puppet ###

    file {"/etc/zabbix/zabbix_agent2.d/zabbix_check_puppetstate.conf":
        source => "puppet:///modules/zabbix_apps/zabbix_check_puppetstate.conf",
        owner => root, group => root, mode => '644',
        notify => Exec["restart-zabbix-agent2"]
    }

    file {"/etc/zabbix/run/zabbix_check_puppetstate":
        source => "puppet:///modules/zabbix_apps/zabbix_check_puppetstate",
        owner => root, group => root, mode => '755',
        require => File["/etc/zabbix/run"]
    }

    ### Monitor network interface ###

    file {"/etc/zabbix/zabbix_agent2.d/interface_info.conf":
        source => "puppet:///modules/zabbix_apps/interface_info.conf",
        owner => root, group => root, mode => '644',
        notify => Exec["restart-zabbix-agent2"]
    }

    file {"/etc/zabbix/run/interface_info.py":
        source => "puppet:///modules/zabbix_apps/interface_info.py",
        owner => root, group => root, mode => '755',
        require => File["/etc/zabbix/run"]
    }

    ### Monitor logged user ###

    file {"/etc/zabbix/zabbix_agent2.d/user_logged.conf":
        source => "puppet:///modules/zabbix_apps/user_logged.conf",
        owner => root, group => root, mode => '644',
        notify => Exec["restart-zabbix-agent2"]
    }

    ### Monitor temperatures ###

    exec {"python3-psutil":
        command => "/usr/bin/apt install -y python-yaml",
        unless => "/usr/bin/facter sistema | /bin/grep -q 'ubuntu2204'"
    }

    file {"/etc/zabbix/zabbix_agent2.d/temperatures.conf":
        source => "puppet:///modules/zabbix_apps/temperatures.conf",
        owner => root, group => root, mode => '644',
        notify => Exec["restart-zabbix-agent2"]
    }

    file {"/etc/zabbix/run/temperatures.py":
        source => "puppet:///modules/zabbix_apps/temperatures.py",
        owner => root, group => root, mode => '755',
        require => File["/etc/zabbix/run"]
    }

    ### Monitor HDMI ###

    file {"/etc/zabbix/zabbix_agent2.d/hdmi.conf":
        source => "puppet:///modules/zabbix_apps/hdmi.conf",
        owner => root, group => root, mode => '644',
        notify => Exec["restart-zabbix-agent2"]
    }
}
