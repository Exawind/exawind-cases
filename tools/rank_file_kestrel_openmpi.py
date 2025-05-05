# This writes rankfiles for Exawind for OpenMPI on Kestrel GPU nodes

import sys

nodes = int(sys.argv[1])

amr_wind_ranks_per_node = 4
nalu_wind_ranks_per_node = 124

total_amr_wind_ranks = nodes * amr_wind_ranks_per_node
total_nalu_wind_ranks = nodes * nalu_wind_ranks_per_node
total_ranks_per_node = nalu_wind_ranks_per_node + amr_wind_ranks_per_node
total_ranks = total_nalu_wind_ranks + total_amr_wind_ranks

print(f"AMR-Wind rank total: {total_amr_wind_ranks}")
print(f"Nalu-Wind rank total: {total_nalu_wind_ranks}")

aqueue = []
nqueue = []
for arank in range(total_amr_wind_ranks):
    aqueue.append(arank)
for nrank in range(total_amr_wind_ranks, total_ranks):
    nqueue.append(nrank)
cpu_map = ''
node = -1
core = 0
for rank in range(total_ranks):
    if ((rank % total_ranks_per_node) == 0):
        node = node + 1
    if ((core % (total_ranks_per_node / amr_wind_ranks_per_node) == 0) and aqueue):
        cpu_map = cpu_map + 'rank ' + str(aqueue.pop(0)) + '=+n' + str(node) + ' slot=' + str(core) + '\n'
    elif (nqueue):
        cpu_map = cpu_map + 'rank ' + str(nqueue.pop(0)) + '=+n' + str(node) + ' slot=' + str(core) + '\n'
    if (core < (total_ranks_per_node - 1)):
        core = core + 1
    else:
        core = 0
cpu_map = cpu_map[:-1]

with open('exawind.rank_file', "w") as f:
    f.write(cpu_map + '\n')
