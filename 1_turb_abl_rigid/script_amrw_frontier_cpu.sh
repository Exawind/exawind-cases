for i in "$@"; do
    case "$1" in
        -a=*|--amrw_nodes=*)
            amrw_nodes="${i#*=}"
            shift # past argument=value
            ;;
        -rpn=*|--ranks_per_node=*)
            ranks_per_node="${i#*=}"
            shift # past argument=value
            ;;
        --)
            shift
            break
            ;;
    esac
done

amrw_ranks=$((amrw_nodes*ranks_per_node))
nodes=$((amrw_nodes))
ranks=$((amrw_ranks))
echo $nodes, $ranks, $amrw_ranks, $nalu_ranks 
sed "s/%NODES%/$nodes/g;s/%RANKS%/$ranks/g;s/%RANKS_PER_NODE%/$ranks_per_node/g;s/%AMRW_RANKS%/$amrw_ranks/g;" run_amrw_frontier_cpu.batch.i > run_amrw_frontier_cpu.batch

sbatch run_amrw_frontier_cpu.batch
