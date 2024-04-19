#!/usr/bin/env python
import pandas
import numpy
import sys
from io import StringIO

table = StringIO("""
hwt,idx,gpu,app
000,000,4,nwind
001,008,4,nwind
002,016,4,nwind
003,024,4,nwind
004,032,4,nwind
005,040,4,nwind
006,048,4,nwind
007,056,4,awind
008,001,5,nwind
009,009,5,nwind
010,017,5,nwind
011,025,5,nwind
012,033,5,nwind
013,041,5,nwind
014,049,5,nwind
015,057,5,awind
016,002,2,nwind
017,010,2,nwind
018,018,2,nwind
019,026,2,nwind
020,034,2,nwind
021,042,2,nwind
022,050,2,nwind
023,058,2,awind
024,003,3,nwind
025,011,3,nwind
026,019,3,nwind
027,027,3,nwind
028,035,3,nwind
029,043,3,nwind
030,051,3,nwind
031,059,3,awind
032,004,6,nwind
033,012,6,nwind
034,020,6,nwind
035,028,6,nwind
036,036,6,nwind
037,044,6,nwind
038,052,6,nwind
039,060,6,awind
040,005,7,nwind
041,013,7,nwind
042,021,7,nwind
043,029,7,nwind
044,037,7,nwind
045,045,7,nwind
046,053,7,nwind
047,061,7,awind
048,006,0,nwind
049,014,0,nwind
050,022,0,nwind
051,030,0,nwind
052,038,0,nwind
053,046,0,nwind
054,054,0,nwind
055,062,0,awind
056,007,1,nwind
057,015,1,nwind
058,023,1,nwind
059,031,1,nwind
060,039,1,nwind
061,047,1,nwind
062,055,1,nwind
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

mymap.loc[mymap['app'] == 'nwind', 'aidx'] = numpy.arange(nalu_wind_ranks_per_node) + amr_wind_ranks_total
mymap.loc[mymap['app'] == 'awind', 'aidx'] = numpy.arange(amr_wind_ranks_per_node)
mymap.loc[mymap['app'] == 'blank', 'aidx'] = ''
mymap.sort_values(by=['idx'],inplace=True)
#print(mymap.to_string())

with open('exawind.reorder_file', "w") as f:
    for node in range(nodes):
        f.write(','.join([str(x) for x in mymap['aidx']]))
        mymap.loc[mymap['app'] == 'nwind', 'aidx'] += nalu_wind_ranks_per_node
        mymap.loc[mymap['app'] == 'awind', 'aidx'] += amr_wind_ranks_per_node
        if node < nodes - 1:
            f.write(',')
    f.write('\n')
