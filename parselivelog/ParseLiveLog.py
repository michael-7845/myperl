#!/usr/bin/env python
#coding:utf-8
'''
Created on 2016-1-26

@author: admin
'''

import os
import re

def walk_dir(path):
    files = os.listdir(path)
    for fn in files:
        if fn.startswith("823"):'''此处需要看log文件的开头，务必能包含所有流log文件'''
            parse_log(fn)
def parse_log(fn):
    print fn
    a1 = []
    a2 = []
    a3 = []
    try:
        fobj = open(fn, 'r')
        lines = ''
        for line in fobj.readlines():
            a1.append(GetMiddleStr(line,"delay",",drop"))
       	    a2.append(GetMiddleStr(line,"drop_percentage",",score"))
            res = re.compile(r'score([-+]?[0-9]*\.?[0-9]+)')
            iofo=res.search(line)
            a3.append(iofo.group(1))
        fobj.close()
        write('delay.log',a1)
        write('drop.log',a2)
        write('score.log',a3)
    except IOError, e:
        print 'file open error:', e

def write(filename, content):
    try:
        fobj = open(filename, 'a')
        for item in content:
          fobj.write(str(item)+'\n')
        fobj.close()
    except IOError, e:
        print 'file open error:', e
        
        
def GetMiddleStr(content,startStr,endStr):
  startIndex = content.index(startStr)
#  print content
#  print startIndex
#  print endStr
  if startIndex>=0:
    startIndex += len(startStr)
  endIndex = content.index(endStr)
  return content[startIndex:endIndex]
 
if __name__ == '__main__':
    walk_dir(".")
