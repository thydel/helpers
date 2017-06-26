#!/usr/bin/python
import sys,os
os.chdir(sys.argv[1])
os.execvp(sys.argv[2],sys.argv[2:])
