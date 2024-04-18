#!/usr/bin/env python
import pandas
import numpy
import sys
from io import StringIO

table = StringIO("""
hwt,idx,gpu,app
000,000,4,blank
008,001,4,nwind
016,002,4,blank
024,003,4,nwind
032,004,4,blank
040,005,4,nwind
048,006,4,blank
056,007,4,awind
001,008,5,blank
009,009,5,nwind
017,010,5,blank
025,011,5,nwind
033,012,5,blank
041,013,5,nwind
049,014,5,blank
057,015,5,awind
002,016,2,blank
010,017,2,nwind
018,018,2,blank
026,019,2,nwind
034,020,2,blank
042,021,2,nwind
050,022,2,blank
058,023,2,awind
003,024,3,blank
011,025,3,nwind
019,026,3,blank
027,027,3,nwind
035,028,3,blank
043,029,3,nwind
051,030,3,blank
059,031,3,awind
004,032,6,blank
012,033,6,nwind
020,034,6,blank
028,035,6,nwind
036,036,6,blank
044,037,6,nwind
052,038,6,blank
060,039,6,awind
005,040,7,blank
013,041,7,nwind
021,042,7,blank
029,043,7,nwind
037,044,7,blank
045,045,7,nwind
053,046,7,blank
061,047,7,awind
006,048,0,blank
014,049,0,nwind
022,050,0,blank
030,051,0,nwind
038,052,0,blank
046,053,0,nwind
054,054,0,blank
062,055,0,awind
007,056,1,blank
015,057,1,nwind
023,058,1,blank
031,059,1,nwind
039,060,1,blank
047,061,1,nwind
055,062,1,blank
063,063,1,awind
""")

nodes = int(sys.argv[1])
mymap = pandas.read_csv(table)
mymap["aidx"] = 0

amr_wind_ranks_per_node = len(mymap.loc[mymap['app'] == 'awind'])
nalu_wind_ranks_per_node = len(mymap.loc[mymap['app'] == 'nwind'])
blank_ranks_per_node = len(mymap.loc[mymap['app'] == 'blank'])
total_ranks_per_node = amr_wind_ranks_per_node + nalu_wind_ranks_per_node
amr_wind_ranks_total = nodes * amr_wind_ranks_per_node
nalu_wind_ranks_total = nodes * nalu_wind_ranks_per_node
blank_ranks_total = nodes * blank_ranks_per_node
ranks_total = nodes * total_ranks_per_node

print(f"AMR-Wind ranks per node: {amr_wind_ranks_per_node}")
print(f"Nalu-Wind ranks per node: {nalu_wind_ranks_per_node}")
print(f"Blank ranks per node: {blank_ranks_per_node}")
print(f"Total ranks per node: {total_ranks_per_node}")
print(f"AMR-Wind rank total: {amr_wind_ranks_total}")
print(f"Nalu-Wind rank total: {nalu_wind_ranks_total}")
print(f"Total ranks: {ranks_total}")

mymap.loc[mymap['app'] == 'nwind', 'aidx'] = numpy.arange(nalu_wind_ranks_per_node)
mymap.loc[mymap['app'] == 'nwind', 'aidx'] += amr_wind_ranks_total
mymap.loc[mymap['app'] == 'awind', 'aidx'] = numpy.arange(amr_wind_ranks_per_node)
mymap.loc[mymap['app'] == 'blank', 'aidx'] = ''
mymap.sort_values(by=['idx'],inplace=True)

with open('exawind.reorder_file', "w") as f:
    for node in range(nodes):
        f.write(','.join([str(x) for x in mymap['aidx']]))
        mymap.loc[mymap['app'] == 'nwind', 'aidx'] += nalu_wind_ranks_per_node
        mymap.loc[mymap['app'] == 'awind', 'aidx'] += amr_wind_ranks_per_node
        if node < nodes - 1:
            f.write(',')
    f.write('\n')
