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
