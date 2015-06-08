#!/usr/bin/python
#
# Created by Alan Bouzek 4/1/2015
# Creates an externalized header version of a file of NSString *const definitions
#
# Accepts a .m file of NSString *const <name> = <value>
# Generates a .h file of extern NSString *const <name> = <value>
#
# Usage: create_extern_header.py <.m filename>
# Output File: <.m filename without extension>.h
#

import sys
import os

if __name__ == '__main__':
	infile = sys.argv[1]
	outfile = os.path.splitext(infile)[0] + '.h'
	with open(infile, 'r') as ins:
		with open(outfile, 'w+') as outs:
			for line in ins:
				if line[0] == '/' or line[0] == '*' or line[0] == '\n' or line[0] == ' ':
					line_to_write = line
				else:
					words = line.split()
					line_to_write = 'extern'
					for word in words:
						if word == '=':
							line_to_write += ';\n'
							break
						else:
							line_to_write += ' ' + word
				outs.write(line_to_write)
