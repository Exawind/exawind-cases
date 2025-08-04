# This writes reorder files for Exawind for cray-mpich on Kestrel GPU nodes

import sys

nodes = int(sys.argv[1])

amr_wind_ranks_per_node = 4
nalu_wind_ranks_per_node = 56

total_amr_wind_ranks = nodes * amr_wind_ranks_per_node
total_nalu_wind_ranks = nodes * nalu_wind_ranks_per_node
total_ranks_per_node = nalu_wind_ranks_per_node + amr_wind_ranks_per_node
total_ranks = total_nalu_wind_ranks + total_amr_wind_ranks

print(f"AMR-Wind rank total: {total_amr_wind_ranks}")
print(f"Nalu-Wind rank total: {total_nalu_wind_ranks}")
print(f"Total ranks: {total_ranks}")

aqueue = []
nqueue = []
for arank in range(total_amr_wind_ranks):
    aqueue.append(arank)
for nrank in range(total_amr_wind_ranks, total_ranks):
    nqueue.append(nrank)

cpu_map = ''
node = -1
core = 0
for rank in range(128 * nodes):
    if (((core == 0) or (core == 64) or (core == 1) or (core == 65)) and aqueue):
        cpu_map = cpu_map + str(aqueue.pop(0)) + ','
    elif (nqueue):
        cpu_map = cpu_map + str(nqueue.pop(0)) + ','
    else:
        cpu_map = cpu_map + ','

    if (core > 127):
        core = 0
    else:
        core = core + 1

cpu_map = cpu_map[:-1]

with open('exawind.reorder_file', "w") as f:
    f.write(cpu_map + '\n')
