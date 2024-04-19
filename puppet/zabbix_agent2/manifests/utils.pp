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

define remote_file($remote_location=undef, $mode='0644', $onlyif){
  exec{ "retrieve_${title}":
    command => "/usr/bin/wget -q ${remote_location} -O ${title}",
    creates => $title,
    onlyif => $onlyif
  }

  file{$title:
    mode    => $mode,
    require => Exec["retrieve_${title}"],
  }
}

define set_configuration_zabbix_agent2($line) {
    $file = "/etc/zabbix/zabbix_agent2.conf"
    $defvar = split($line, '=')
    $var = $defvar[0]
    $value = $defvar[1]

    exec { "/bin/sed -i 's/'${var}'=.*/'${var}'='${value}'/g' '${file}'; /usr/bin/systemctl restart zabbix-agent2":
       onlyif => "/usr/bin/test -f '$file' && /bin/grep -q '${var}' '${file}'",
       unless => "/bin/grep -q '${line}' '${file}'"
    }
}
