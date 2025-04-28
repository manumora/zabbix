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

define zabbix_agent2::remote_file($remote_location=undef, $mode='0644', $onlyif){
  exec{ "retrieve_${title}":
    command => "wget -q ${remote_location} -O ${title}",
    path => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    creates => $title,
    onlyif => $onlyif
  }

  file{$title:
    mode    => $mode,
    require => Exec["retrieve_${title}"],
  }
}
