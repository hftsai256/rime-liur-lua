#!/usr/bin/env python3

import getopt
import os, sys

optlist, args = getopt.getopt(sys.argv[1:], 'adi:o:')
token = "patch/schema_list/liur".split("/")
loc = {t: 0 for t in token}
buf = []
out_file = None

for opt, arg in optlist:
    if   opt in ('-i', '--input'):
        in_file = arg
    elif opt in ('-o', '--output'):
        out_file = arg
    elif opt in ('-a', '--add'):
        mode = 'add'
    elif opt in ('-d', '--delete'):
        mode = 'delete'

with open(in_file, 'r') as f:
    num = 0
    for i, t in enumerate(token):
        for line in f:
            num += 1
            buf.append(line)
            if t in line:
                #TODO: might want to use regex for generalization
                indent = len(line) - len(line.lstrip())
                loc[t] = num
                break
    for line in f:
        buf.append(line)

if loc[token[-1]] is not 0:
    if (mode == 'delete'):
        buf.pop(loc[token[-1]]-1)
else:
    if (mode == 'add'):
        buf.insert(loc[token[-2]], " "*indent + "- schema: liur\n")

if out_file:
    with open(out_file, 'w+') as f:
        f.write("".join(buf))
else:
    print("".join(buf))
