##############################################################################
# Module:      Zabbix Agent installation
# Date:        26-Oct-2023.
# Copyright:   2023 - Manuel Mora Gordillo       <manuel.mora.gordillo @nospam@ gmail.com>
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

class install_zabbix_agent {
    
    ### Zabbix Agent deb package ###
    package{"zabbix-agent":
        ensure => "installed"
    }

    ### Zabbix Agent configuration ###
    setConfigurationZabbix{
        "set-zabbix-server": line => "Server=zabbix"
    }
    setConfigurationZabbix{
        "set-zabbix-hostname": line => "Hostname=${hostname}"
    }
    file {"/etc/zabbix/run":
        ensure => "directory",
    }

    ### Monitor network interface ###
    file {"/etc/zabbix/zabbix_agentd.conf.d/interface_info.conf":
        source => "puppet:///modules/install_zabbix_agent/interface_info.conf",
        owner => root, group => root, mode => 644
    }
    file {"/etc/zabbix/run/interface_info.py":
        source => "puppet:///modules/install_zabbix_agent/interface_info.py",
        owner => root, group => root, mode => 755,
        require => File["/etc/zabbix/run"]
    }

    ### Monitor puppet ###
     exec {"python-yaml":
        command => "/usr/bin/apt install -y python-yaml",
        unless => "/usr/bin/facter sistema | /bin/grep -q 'ubuntu2204'"
     }
     exec {"python3-yaml":
        command => "/usr/bin/apt install -y python3-yaml",
        onlyif => "/usr/bin/facter sistema | /bin/grep -q 'ubuntu2204'",
        unless => "/usr/bin/dpkg -l | /bin/grep -q 'python3-yaml'"
     }
    file { '/var/lib/puppet':
        ensure => 'directory',
        mode   => '0755',
    }
    file {"/etc/zabbix/zabbix_agentd.conf.d/puppet_info.conf":
        source => "puppet:///modules/install_zabbix_agent/puppet_info.conf",
        owner => root, group => root, mode => 644
    }
    file {"/etc/zabbix/run/puppet_info.py":
        source => "puppet:///modules/install_zabbix_agent/puppet_info.py",
        owner => root, group => root, mode => 755,
        require => File["/etc/zabbix/run"]
    }

    ### Monitor logged user ###
    file {"/etc/zabbix/zabbix_agentd.conf.d/user_logged.conf":
        source => "puppet:///modules/install_zabbix_agent/user_logged.conf",
        owner => root, group => root, mode => 644
    }

    ### Monitor temperatures ###
    exec {"python3-psutil":
        command => "/usr/bin/apt install -y python-yaml",
        unless => "/usr/bin/facter sistema | /bin/grep -q 'ubuntu2204'"
    }
    file {"/etc/zabbix/zabbix_agentd.conf.d/temperatures.conf":
        source => "puppet:///modules/install_zabbix_agent/temperatures.conf",
        owner => root, group => root, mode => 644
    }
    file {"/etc/zabbix/run/temperatures.py":
        source => "puppet:///modules/install_zabbix_agent/temperatures.py",
        owner => root, group => root, mode => 755,
        require => File["/etc/zabbix/run"]
    }
}

# Functions
define setConfigurationZabbix($line) {
    $file = "/etc/zabbix/zabbix_agentd.conf"
    $defvar = split($line, '=')
    $var = $defvar[0]
    $value = $defvar[1]

    exec { "/bin/sed -i 's/'${var}'=.*/'${var}'='${value}'/' '${file}'; /etc/init.d/zabbix-agent restart":
       onlyif => "/bin/grep -q '${var}' '${file}'",
       unless => "/bin/grep -q '${line}' '${file}'"
    }

    exec { "/bin/echo '${line}' >> '${file}'":
       unless => "/bin/grep -q '${var}' '${file}'"
    }
}
