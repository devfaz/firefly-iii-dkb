#!/usr/bin/env python3
import argparse
import csv
import pandas as pd
import re
import datetime
import pprint

parser = argparse.ArgumentParser(description="convert csv")
parser.add_argument("--input", dest="input", help="file to read csv", required=True)
parser.add_argument(
    "--output",
    dest="output",
    help="file to read csv",
    default="output.csv",
    required=False,
)
parser.add_argument("--delimiter", dest="delimiter", help="str to delimit", default=";")
parser.add_argument(
    "--verbose",
    dest="verbose",
    help="be more verbose",
    required=False,
    default=False,
    action=argparse.BooleanOptionalAction,
)
parser.add_argument(
    "--title",
    dest="title",
    help="uppercase first letter of all words",
    required=False,
    default=False,
    action=argparse.BooleanOptionalAction,
)
parser.add_argument(
    "--slashsplit",
    dest="slashsplit",
    help="remove everything behind / from remoteName",
    required=False,
    default=False,
    action=argparse.BooleanOptionalAction,
)
parser.add_argument(
    "--trimfile",
    dest="trimfile",
    help="if string is found in remoteName - trim remaining chars",
    required=False,
    default="",
)
parser.add_argument(
    "--extendfile",
    dest="extendfile",
    help="if string is found in remoteName - extend remoteName by IBAN",
    required=False,
    default="",
)
parser.add_argument(
    "--write-delimiter", dest="wdelimiter", help="str to delimit", default=","
)
parser.add_argument(
    "--date-filter-field",
    dest="dffield",
    type=str,
    help="field to apply date-filter on",
    default="date",
)
parser.add_argument(
    "--date", dest="date", help="date to apply on date-filter-field", required=False
)
parser.add_argument(
    "--search",
    dest="search",
    help="skip all lines till this string was found",
    required=False,
)

args = parser.parse_args()

trimRegexs = []
if len(args.trimfile) > 0:
    with open(args.trimfile, "r") as trimfile:
        trimRegexs = [line.rstrip() for line in trimfile]
        if args.verbose:
            pprint.pprint(trimRegexs)

extendRegexs = []
if len(args.extendfile) > 0:
    with open(args.extendfile, "r") as extendfile:
        extendRegexs = [line.rstrip() for line in extendfile]
        if args.verbose:
            pprint.pprint(extendRegexs)

if re.match(r".*\.xls.*", args.input):
    print("XLS file detected")
    data_xls = pd.read_excel(args.input, "Sheet1", dtype=str, index_col=None)
    data_xls.to_csv(args.input + ".csv", encoding="utf-8", index=False)
    args.input = args.input + ".csv"
    args.delimiter = ","

csvfile = open(args.input, newline="")
w_csvfile = open(args.output, "w", newline="")
reader = csv.DictReader(csvfile, delimiter=args.delimiter)
writer = csv.DictWriter(
    w_csvfile,
    fieldnames=reader.fieldnames,
    delimiter=args.wdelimiter,
    quoting=csv.QUOTE_MINIMAL,
)
writer.writeheader()
found = 0

for row in reader:
    if args.verbose:
        print("---")
        pprint.pprint(row)

    for k in row.keys():
        row[k] = row[k].replace("€", "").strip()
        if args.search:
            if re.search(args.search, row[k]):
                if args.verbose:
                    print("Hey! Found search-string")
                found = 1

    if args.search and found != 1:
        if args.verbose:
            print("Skipping line: search-string not found yet")
        continue

    if args.date:
        if re.match(r"\d{2}.\d{2}.\d{4}", row[args.dffield]):
            line_date = datetime.datetime.strptime(row[args.dffield], "%d.%m.%Y")
            filter_date = datetime.datetime.strptime(args.date, "%d.%m.%Y")
            if line_date <= filter_date:
                if args.verbose:
                    print("Skipping line: outdated")
                continue

    if args.title:
        row["remoteName"] = row["remoteName"].title()

    if args.slashsplit:
        row["remoteName"] = row["remoteName"].split("/")[0]

    for trimRegex in trimRegexs:
        match = re.search(trimRegex, row["remoteName"], re.IGNORECASE)
        if match:
            if args.verbose:
                print("Found trimprefix")
            row["remoteName"] = match.group()

    for extendRegex in extendRegexs:
        match = re.search(extendRegex, row["remoteName"], re.IGNORECASE)
        if match:
            if args.verbose:
                print("Found extendRegex")
            row["remoteName"] = f"{row['remoteName']} ({row['remoteAccountNumber']})"

    if "ultimateDebtor" in row.keys():
        if len(row["ultimateDebtor"]) == 0:
            if args.verbose:
                print("No ultimateDebtor - using RemoteName")
            row["ultimateDebtor"] = row["remoteName"]
        else:
            if args.verbose:
                print("Found ultimateDebtor - so filling purpose")
            row["purpose"] = row["ultimateDebtor"] + ": " + row["purpose"]

    writer.writerow(row)
