#!/usr/bin/env python

import numpy as np

nodes = 64
amr_wind_ranks_per_node = 8
total_amr_wind_ranks = nodes * amr_wind_ranks_per_node
nalu_wind_ranks_per_node = 56
total_ranks_per_node = amr_wind_ranks_per_node + nalu_wind_ranks_per_node
total_nalu_wind_ranks = nodes * nalu_wind_ranks_per_node
total_ranks = total_nalu_wind_ranks + total_amr_wind_ranks

print(f"AMR-Wind rank total: {total_amr_wind_ranks}")
print(f"Nalu-Wind rank total: {total_nalu_wind_ranks}")

amr_wind_ranks_on_node = np.arange(amr_wind_ranks_per_node)
nalu_wind_ranks_on_node = (
    (
        np.reshape(
            np.arange(
                total_amr_wind_ranks, total_ranks_per_node + total_amr_wind_ranks
            ),
            [amr_wind_ranks_per_node, -1],
        )
        - np.arange(amr_wind_ranks_per_node)[:, np.newaxis]
    )[:, :-1]
).flatten(order="F")

mapping = np.concatenate(
    [
        np.hstack(
            (
                nalu_wind_ranks_on_node + n * nalu_wind_ranks_per_node,
                amr_wind_ranks_on_node + n * amr_wind_ranks_per_node,
            )
        )
        for n in range(nodes)
    ]
)

np.savetxt("exawind.rank_map", mapping[None, :], fmt="%.d", delimiter=",")
