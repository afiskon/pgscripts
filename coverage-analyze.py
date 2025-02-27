#!/usr/bin/env python3

# coverage-analyze.py
# Aleksander Alekseev 2025
# see https://postgr.es/m/CAJ7c6TPHyN0mBQQyjkq-ke6qaKUwzRV6pcmTx8ErsgtGvzzHJA%40mail.gmail.com

import re
import sys

functions = set()

with open("src/include/catalog/pg_proc.dat") as f:
	proc_data = f.read()
	re_str = """prosrc[ ]+=>[ ]+['"](.*?)['"]"""
	for m in re.finditer(re_str, proc_data):
		func_name = m.group(1)
		functions.add(func_name)
# print("DEBUG functions found: {}".format(len(functions)))

# function_name -> {
# 'file_name': xxx
# 'start_line': yyy
# 'end_line': zzz
# 'covered_lines': set(covered line numbers)
# }
summary = {}

current_file_name = None
current_func_name = None
line_number_to_func_name = {}
with open("build/meson-logs/coverage.info") as f:
	for line in f:
		line = line.strip()
		if line.startswith("SF:"):
			current_file_name = line.split(":")[1]
			line_number_to_func_name = {}
			# print("DEBUG current file: '{}'".format(current_file_name))
		elif line.startswith("FN:"):
			temp = line.split(":")
			temp = temp[1].split(",")
			func_start_line = int(temp[0])
			func_name = temp[1]

			if current_func_name != None:
				summary[current_func_name]['end_line'] = func_start_line - 1
				for num in range(summary[current_func_name]['start_line'], summary[current_func_name]['end_line']+1):
					line_number_to_func_name[num] = current_func_name

			current_func_name = func_name
			# print("DEBUG found function '{}'".format(func_name))
			if current_func_name not in functions:
				current_func_name = None
				continue

			summary[current_func_name] = {
				'file_name': current_file_name,
				'start_line': func_start_line,
				'end_line': None,
				'covered_lines': set()
			}
		else:
			if current_func_name != None:
				if summary[current_func_name]['end_line'] == None:
					summary[current_func_name]['end_line'] = sum(1 for _ in open(current_file_name))
					for num in range(summary[current_func_name]['start_line'], summary[current_func_name]['end_line']+1):
						line_number_to_func_name[num] = current_func_name
				current_func_name = None

			if line.startswith("DA:"):
				temp = line.split(":")
				temp = temp[1].split(",")
				line_number = int(temp[0])
				exec_number = int(temp[1])
				if exec_number > 0:
					if line_number not in line_number_to_func_name:
						continue # not within any function that may interest us
					func_name = line_number_to_func_name[line_number]
					summary[func_name]['covered_lines'].add(line_number)

# ignore functions with zero lines - it's possible in several cases
func_list = filter(lambda k: summary[k]['end_line'] > summary[k]['start_line'], summary.keys())
# sort by coverage
func_list = sorted(func_list, key = lambda k: len(summary[k]['covered_lines']) / (summary[k]['end_line'] - summary[k]['start_line']))

print("Filename,Function,Lines Covered,Lines Total,Percentage")
for func_name in func_list:
	lines_covered = len(summary[func_name]['covered_lines'])
	lines_total = summary[func_name]['end_line'] - summary[func_name]['start_line']
	print("{},{},{},{},{:.1f}%".format(summary[func_name]['file_name'], func_name, lines_covered, lines_total, lines_covered*100/lines_total))
