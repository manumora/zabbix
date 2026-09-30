#!/usr/bin/env python3
# -*- coding: utf-8 -*-
##############################################################################
# Module:      Zabbix APPS installation
# Date:        30-Sep-2026.
# Copyright:   2026 - Manuel Mora Gordillo       <manuel.mora.gordillo @nospam@ gmail.com>
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

import psutil
import json

if __name__ == '__main__':
    temperatures = dict()
    for _type, items in psutil.sensors_temperatures().items():
        aux_label = 0
        for item in items:
            if not item[0]:
                name = aux_label
                aux_label += 1
            else:
                name = item[0]

            temperatures["%s - %s" % (_type, name)] = item[1]

    print(json.dumps(temperatures))

