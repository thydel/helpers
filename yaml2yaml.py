#!/usr/bin/env python                                                                                                                
import sys,yaml
print yaml.safe_dump(yaml.load(sys.stdin), allow_unicode=True)
