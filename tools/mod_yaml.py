#!/usr/bin/env python3

import getopt
import os, sys
import re

optlist, args = getopt.getopt(sys.argv[1:], 'adi:o:')
sections = args[0].split("/")
sections_line = [0] * len(sections)
field = args[1]
entry = args[2]
entry_line = 0
re_pattern = r'\s*(' + r'|'.join(sections) + r'|- {:s}:\s?{:s})'.format(field, entry)
insert_pattern = '- {:s}: {:s}'.format(field, entry)


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

if out_file is None:
    out_file = in_file


with open(in_file, 'r') as f:
    num = 0
    for line in f:
        num += 1
        buf.append(line)
        match = re.match(re_pattern, line)
        if match:
            spaces = len(line) - len(line.lstrip())
            token = match.groups()[0]
            if entry in token:
                entry_line = num
            else:
                sections_line[sections.index(token)] = num


if (entry_line != 0) and (mode == 'delete'):
    buf.pop(entry_line-1)
elif (entry_line == 0) and (mode == 'add'):
    indent = " " * (spaces+2)
    buf.insert(sections_line[-1], indent + insert_pattern + "\n")


with open(out_file, 'w+') as f:
    f.write("".join(buf))
