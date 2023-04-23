#!/usr/bin/env python
import argparse
import csv
import pylightxl as xl
import pandas as pd
import re
import datetime
import pprint

parser = argparse.ArgumentParser(description='convert csv')
parser.add_argument('--input', dest='input', help='file to read csv', required=True)
parser.add_argument('--output', dest='output', help='file to read csv', default='output.csv', required=False)
parser.add_argument('--delimiter', dest='delimiter', help='str to delimit', default=';')
parser.add_argument('--write-delimiter', dest='wdelimiter', help='str to delimit', default=',')
parser.add_argument('--date-filter-field', dest='dffield', type=str, help='field to apply date-filter on', default='date')
parser.add_argument('--date', dest='date', help='date to apply on date-filter-field', required=False)
parser.add_argument('--search', dest='search', help='skip all lines till this string was found', required=False)

args = parser.parse_args()

if re.match(".*\.xls.*", args.input):
    print("XLS file detected")
    data_xls = pd.read_excel(args.input, 'Sheet1', dtype=str, index_col=None)
    data_xls.to_csv(args.input + ".csv", encoding='utf-8', index=False)
    args.input = args.input + ".csv"
    args.delimiter = ','

csvfile = open(args.input, newline='')
w_csvfile = open(args.output, 'w', newline='')
reader = csv.DictReader(csvfile, delimiter=args.delimiter)
writer = csv.DictWriter(w_csvfile, fieldnames=reader.fieldnames, delimiter=args.wdelimiter, quoting=csv.QUOTE_MINIMAL)
writer.writeheader()
found = 0

for row in reader:
  pprint.pprint(row)


  for k in row.keys():
      row[k] = row[k].replace("€", "").strip()
      if args.search:
          if re.search(args.search, row[k]):
              found =1

  if args.search and found != 1:
      continue

  if args.date:
    if re.match('\d{2}.\d{2}.\d{4}', row[args.dffield]):
        line_date = datetime.datetime.strptime(row[args.dffield], '%d.%m.%Y')
        filter_date = datetime.datetime.strptime(args.date, '%d.%m.%Y')
        if line_date <= filter_date:
          continue

  if 'ultimateDebtor' in row.keys():
      if len(row['ultimateDebtor']) == 0:
          print("No ultimateDebtor - using RemoteName")
          row['ultimateDebtor'] = row['remoteName']
      else:
          print("Found ultimateDebtor - so filling purpose")
          row['purpose'] = row['ultimateDebtor'] + ": " + row['purpose']

  writer.writerow(row)
