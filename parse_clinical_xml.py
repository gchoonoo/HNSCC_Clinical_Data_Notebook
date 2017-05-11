# -*- coding: utf-8 -*-
"""
Created on Tue May  9 14:09:34 2017

@author: choonoo
"""

"""
Parse TCGA clinical XML files, structure contains clinical, rx, radiation, nte (followup data)

Start with one patient, and each is in a separate file
"""

import xml.etree.ElementTree as et

import os

import csv

os.chdir("/Users/choonoo/TCGA_new_exp/clinical_data_5_9_17")

rootdir = "/Users/choonoo/TCGA_new_exp/clinical_data_5_9_17"

dir_list = []
for subdir, dirs, files in os.walk(rootdir):
    for file in files:
        print os.path.join(subdir, file)
        clin_files = os.path.join(subdir, file)
        dir_list.append(clin_files)
        
dir_list2 = [dir_list for dir_list in dir_list if 'parcel' not in dir_list]

dir_list3 = [dir_list2 for dir_list2 in dir_list2 if 'xml' in dir_list2]

for i in range(0,len(dir_list3)):
    new_list = []      
    iter_et = et.iterparse(dir_list3[i], events=['start', 'end'])
    event, root = iter_et.next()
    for event, element in iter_et:
        if event == "end" and element.tag != root.tag:
            print element.tag + ":", element.text
            result = element.tag + ":", element.text
            new_list.append(result) 
            element.clear()

    root.clear() 
    fh = open("/Users/choonoo/TCGA_new_exp/clinical_data_5_9_17_parsed/file" + str(i) + ".txt", 'w')
    w = csv.writer(fh, delimiter='\t')
    w.writerows(new_list[1:])    
    fh.close()  