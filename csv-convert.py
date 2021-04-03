#!/home/m3m0r3x/.venv/csv-convert/bin/python
import argparse
import csv
import pylightxl as xl
import pandas as pd
import re

parser = argparse.ArgumentParser(description='convert csv')
parser.add_argument('--input', dest='input', help='file to read csv', required=True)
parser.add_argument('--output', dest='output', help='file to read csv', default='output.csv', required=False)
parser.add_argument('--delimiter', dest='delimiter', help='str to delimit', default=';')
parser.add_argument('--write-delimiter', dest='wdelimiter', help='str to delimit', default=',')

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

  length = len(row)
  for i in range(length):
    row[i] = row[i].replace("€", "").strip()

  if found == 1:
    writer.writerow(row)
