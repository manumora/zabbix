#!/usr/bin/env python3
##############################################################################
# -*- coding: utf-8 -*-
# Project:     Zabbix modules
# Module:      puppet_info.py
# Purpose:     Get puppet info of computers
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

import yaml
import argparse

def get_puppet_data():
    with open("/var/lib/puppet/state/last_run_summary.yaml", 'r') as stream:
        return yaml.load(stream, Loader=yaml.FullLoader)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--lastrun', default=None, action='store_true')

    arguments = parser.parse_args()

    if arguments.lastrun:
         print(get_puppet_data()["time"]["last_run"])
    else:
         print(get_puppet_data())