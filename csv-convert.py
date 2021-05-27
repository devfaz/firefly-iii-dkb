#!/home/m3m0r3x/.venv/csv-convert/bin/python
import argparse
import csv
import pylightxl as xl
import pandas as pd
import re
import datetime

parser = argparse.ArgumentParser(description='convert csv')
parser.add_argument('--input', dest='input', help='file to read csv', required=True)
parser.add_argument('--output', dest='output', help='file to read csv', default='output.csv', required=False)
parser.add_argument('--delimiter', dest='delimiter', help='str to delimit', default=';')
parser.add_argument('--write-delimiter', dest='wdelimiter', help='str to delimit', default=',')
parser.add_argument('--date-filter-field', dest='dffield', type=int, help='field to apply date-filter on', default='1')
parser.add_argument('--date', dest='date', help='date to apply on date-filter-field', required=False)

args = parser.parse_args()

if re.match(".*\.xls.*", args.input):
    print("XLS file detected")
    data_xls = pd.read_excel(args.input, 'Sheet1', dtype=str, index_col=None)
    data_xls.to_csv(args.input + ".csv", encoding='utf-8', index=False)
    args.input = args.input + ".csv"
    args.delimiter = ','

csvfile = open(args.input, newline='')
w_csvfile = open(args.output, 'w', newline='')
reader = csv.reader(csvfile, delimiter=args.delimiter)
writer = csv.writer(w_csvfile, delimiter=args.wdelimiter, quoting=csv.QUOTE_MINIMAL)
found = 0
for row in reader:
  if len(row) > 0 and re.match("(Referenznummer|transactionId|Umsatz)", row[0]):
    found = 1

  if found != 1:
    continue

  length = len(row)
  for i in range(length):
    row[i] = row[i].replace("€", "").strip()

  if args.date:
    if re.match('\d{2}.\d{2}.\d{4}', row[args.dffield]):
        line_date = datetime.datetime.strptime(row[args.dffield], '%d.%m.%Y')
        filter_date = datetime.datetime.strptime(args.date, '%d.%m.%Y')
        if line_date <= filter_date:
          continue

  writer.writerow(row)
