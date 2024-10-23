#Rank mapping for Aurora
#Still requires the first column to be sorted, so need `cat exawind.rank_file | sort -g` at the moment

import sys

nodes = int(sys.argv[1])
amr_wind_ranks_per_node = 12
total_amr_wind_ranks = nodes * amr_wind_ranks_per_node
nalu_wind_ranks_per_node = 44
total_nalu_wind_ranks = nodes * nalu_wind_ranks_per_node
total_ranks = total_nalu_wind_ranks + total_amr_wind_ranks

print(f"AMR-Wind rank total: {total_amr_wind_ranks}")
print(f"Nalu-Wind rank total: {total_nalu_wind_ranks}")

cpu_map = ''
for node in range(nodes):
    hwthread = 0
    for amr_wind_rank in range(amr_wind_ranks_per_node):
        offset_amr_wind_rank = amr_wind_rank + (node * amr_wind_ranks_per_node)
        cpu_map = cpu_map + str(offset_amr_wind_rank) + ' ' + str(node) + ' ' + str(hwthread) + '\n'
        hwthread = hwthread + 1
    for nalu_wind_rank in range(nalu_wind_ranks_per_node):
        offset_nalu_wind_rank = nalu_wind_rank + total_amr_wind_ranks + (node * nalu_wind_ranks_per_node)
        cpu_map = cpu_map + str(offset_nalu_wind_rank) + ' ' + str(node) + ' ' + str(hwthread) + '\n'
        hwthread = hwthread + 1
cpu_map = cpu_map[:-1]

with open('exawind.rank_file', "w") as f:
    f.write(cpu_map + '\n')
