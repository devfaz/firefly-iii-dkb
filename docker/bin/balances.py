#!/bin/env python3
import re
import sys

f = open(sys.argv[1], "r")
content = f.read()

regex = r"balance {\n\s+.*date=\"([0-9]+)\".*\n\s+.*value=\"([0-9]+)%2F(\d+).*\n\s.*type=\"noted\"\n\s+}\s#balance\b"
matches = re.findall(regex, content, re.MULTILINE)
for balance in matches:
    date = int(balance[0])
    value = int(balance[1])
    div = int(balance[2])
    amount = value / div
    print(f"{date} {amount:0.2f}€")

regex = r"balance {\n\s+.*date=\"([0-9]+)\".*\n\s+.*value=\"([0-9]+)%3AEUR.*\n\s.*type=\"noted\"\n\s+}\s#balance\b"
matches = re.findall(regex, content, re.MULTILINE)
for balance in matches:
    date = int(balance[0])
    amount = int(balance[1])
    print(f"{date} {amount:0.2f}€")
