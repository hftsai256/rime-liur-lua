#!/usr/bin/env python3
# TODO: Need better documentation

import os, sys
import yaml

with open(sys.argv[1], 'r') as f:
    data = yaml.safe_load(f)

if not {'schema':'liur'} in data['patch']['schema_list']:
    data['patch']['schema_list'].append({'schema_list': 'liur'})

with open(sys.argv[2], 'w+') as f:
    yaml.safe_dump(data, f, encoding='utf-8')
