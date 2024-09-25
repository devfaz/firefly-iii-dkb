#!/bin/env python3
import re
import sys

f = open(sys.argv[1], "r")

regex = r"balance {\n\s+.*date=\"([0-9]+)\".*\n\s+.*value=\"([0-9]+)([0-9]{2})%2F100.*\n\s.*type=\"noted\"\n\s+}\s#balance\b"
matches = re.findall(regex, f.read(), re.MULTILINE)

for balance in matches:
    print(f'{balance[0]} {balance[1]},{balance[2]}€')
