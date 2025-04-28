##############################################################################
# Module:      Zabbix Agent 2 installation
# Date:        19-Feb-2024.
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

class zabbix_agent2 {
    
    zabbix_agent2::remote_file{"/var/lib/apt/zabbix-release_latest+ubuntu22.04_all.deb":
        remote_location => "https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu22.04_all.deb",
        onlyif => "facter sistema | grep -q 'ubuntu2204'",
    }

    zabbix_agent2::remote_file{"/var/lib/apt/zabbix-release_latest+ubuntu18.04_all.deb":
        remote_location => "https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu18.04_all.deb",
        onlyif => "facter sistema | grep -q 'ubuntu1804'",
    }

    exec { "instalar_zabbix_release_2204":
        command => "dpkg -i /var/lib/apt/zabbix-release_latest+ubuntu22.04_all.deb ; apt update ;",
        path => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
        unless => "dpkg -l | grep zabbix-release | grep ^ii",
        onlyif => "facter sistema | grep -q 'ubuntu2204'"
    }

    exec { "instalar_zabbix_release_1804":
        command => "dpkg -i /var/lib/apt/zabbix-release_latest+ubuntu18.04_all.deb ; apt update ;",
        path => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
        unless => "dpkg -l | grep zabbix-release | grep ^ii",
        onlyif => "facter sistema | grep -q 'ubuntu1804'"
    }

    package{"zabbix-agent2":
        ensure => "installed"
    }

    ### Zabbix Agent configuration ###

    zabbix_agent2::set_configuration{
        "set-zabbix-server": line => "Server=zabbix.santaeulalia"
    }

    zabbix_agent2::set_configuration{
        "set-zabbix-server-active": line => "ServerActive=zabbix.santaeulalia"
    }
    
    zabbix_agent2::set_configuration{
        "set-zabbix-hostname": line => "Hostname=${hostname}"
    }
}
