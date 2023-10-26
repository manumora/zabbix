#!/usr/bin/env python

import yaml
import argparse

def get_puppet_data():
    with open("/var/lib/puppet/state/last_run_summary.yaml", 'r') as stream:
        return yaml.load(stream)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--lastrun', default=None, action='store_true')

    arguments = parser.parse_args()

    if arguments.lastrun:
         print get_puppet_data()["time"]["last_run"]
    else:
         print get_puppet_data()
