#!/usr/bin/env bash

#########################################################
# Arguments
#########################################################

helpFunction()
{
   echo "#########################################################" 
   echo "Usage: bash $0 -p <PIPELINEMODE> -o <OUTPUTDIR>"
   echo "#########################################################" 
   echo "Acceptable inputs:"
   echo -e "\t<PIPELINEMODE> options: dry, run"
   echo -e "\t<OUTPUTDIR> : absolute path to output folder required"
   echo "#########################################################" 
   exit 1 # Exit script after printing help
}

while getopts "p:o:" opt
do
   case "$opt" in
      p ) pipeline="$OPTARG" ;;
      o ) output_dir="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$pipeline" ] || [ -z "$output_dir" ]; then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

#remove trailing / on directories
output_dir=$(echo $output_dir | sed 's:/*$::')

# set source_dir
PIPELINE_HOME=$(readlink -f $(dirname "$0"))

# initialize
if [[ ! -d $output_dir ]]; then mkdir $output_dir; fi
dir_list=(config log)
for pd in "${dir_list[@]}"; do if [[ ! -d $output_dir/$pd ]]; then mkdir -p $output_dir/$pd; fi; done

files_save=('config/snakemake_config.yaml' 'workflow/Snakefile' 'config/cluster_config.yaml')
for f in ${files_save[@]}; do
    f="${PIPELINE_HOME}/$f"
    IFS='/' read -r -a strarr <<< "$f" 
    sed -e "s/PIPELINE_HOME/${PIPELINE_HOME//\//\\/}/g" -e "s/OUTPUT_DIR/${output_dir//\//\\/}/g" $f > "${output_dir}/config/${strarr[-1]}"

done

if [[ $pipeline == "dry" ]]; then
    echo "------------------------------------------------------------------------"
	echo "*** STARTING DryRun ***"
    module load snakemake python

    snakemake -s $output_dir/config/Snakefile \
    --configfile $output_dir/config/snakemake_config.yaml \
    --printshellcmds \
    --verbose \
    --rerun-incomplete \
    --cluster-config ${output_dir}/config/cluster_config.yaml \
    -npr

elif [[ $pipeline == "local" ]]; then
    echo "------------------------------------------------------------------------"
	echo "*** STARTING Local Execution ***"
    module load snakemake python

    snakemake -s $output_dir/config/Snakefile \
    --configfile $output_dir/config/snakemake_config.yaml \
    --printshellcmds \
    --verbose \
    --rerun-incomplete \
    --cores 1

elif [[ $pipeline == "cluster" ]]; then
    echo "------------------------------------------------------------------------"
	echo "*** STARTING Cluster Execution ***"
    module load snakemake python

    sbatch --job-name="snakemake_tutorial" \
    --gres=lscratch:200 \
    --time=120:00:00 \
    --output=${output_dir}/log/%j_%x.out \
    --mail-type=BEGIN,END,FAIL \
    snakemake -s $output_dir/config/Snakefile \
    --configfile $output_dir/config/snakemake_config.yaml \
    --printshellcmds \
    --verbose \
    --rerun-incomplete \
    --latency-wait 120 \
    --use-envmodules \
    --cluster-config ${output_dir}/config/cluster_config.yaml \
        cluster "sbatch --gres {cluster.gres} --cpus-per-task {cluster.threads} \
        -p {cluster.partition} -t {cluster.time} --mem {cluster.mem} --job-name={params.rname} \
        --output=${output_dir}/log/{params.rname}{cluster.output} \
        --error=${output_dir}/log/{params.rname}{cluster.error}"

else 
    echo "Select the options dry, local, cluster with the -p flag"

fi