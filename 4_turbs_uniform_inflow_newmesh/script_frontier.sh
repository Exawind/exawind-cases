for i in "$@"; do
    case "$1" in
        -a=*|--amrw_ranks=*)
            amrw_ranks="${i#*=}"
            shift # past argument=value
            ;;
        -n=*|--nalu_ranks=*)
            nalu_ranks="${i#*=}"
            shift # past argument=value
            ;;
        --)
            shift
            break
            ;;
    esac
done

nalu_nodes=$((nalu_ranks/8))
total_nalu_nodes=$((nalu_nodes*4))
total_nalu_ranks=$((total_nalu_nodes*8))
amrw_nodes=$((amrw_ranks/8))
nodes=$((total_nalu_nodes+amrw_nodes))
ranks=$((nodes*8))
echo $nodes, $ranks, $amrw_ranks, $nalu_nodes, $nalu_ranks, $total_nalu_ranks 

sed "s/%NODES%/$nodes/g;s/%RANKS%/$ranks/g;s/%RANKS_PER_NODE%/8/g;s/%AMRW_RANKS%/$amrw_ranks/g;s/%NALU_RANKS%/$nalu_ranks/g;s/%TOTAL_NALU_RANKS%/$total_nalu_ranks/g;" run_frontier.batch.i > run_frontier.batch

sbatch run_frontier.batch
