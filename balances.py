#!/bin/env python3
import re
import sys

f = open(sys.argv[1], "r")
content = f.read()

regex = r"balance {\n\s+.*date=\"([0-9]+)\".*\n\s+.*value=\"([0-9]+)([0-9]{2})%2F100.*\n\s.*type=\"noted\"\n\s+}\s#balance\b"
matches = re.findall(regex, content, re.MULTILINE)

for balance in matches:
    print(f'{balance[0]} {balance[1]},{balance[2]}€')

regex = r"balance {\n\s+.*date=\"([0-9]+)\".*\n\s+.*value=\"([0-9]+)%3AEUR.*\n\s.*type=\"noted\"\n\s+}\s#balance\b"
matches = re.findall(regex, content, re.MULTILINE)
for balance in matches:
    print(f'{balance[0]} {balance[1]},00€')
