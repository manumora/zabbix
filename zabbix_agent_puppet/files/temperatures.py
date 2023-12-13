#!/usr/bin/env python3
##############################################################################
# -*- coding: utf-8 -*-
# Project:     Zabbix modules
# Module:      temperatures.py
# Purpose:     Get temperatures of computers
# Language:    Python 3
# Date:        13-Dec-2023.
# Ver:         13-Dec-2023.
# Author:      Manuel Mora Gordillo
# Copyright:   2023 - Manuel Mora Gordillo    <manuel.mora.gordillo @nospam@ gmail.com>
#
# Zabbix modules is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# Zabbix modules is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with Zabbix modules. If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################

import psutil

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

    print(temperatures)
