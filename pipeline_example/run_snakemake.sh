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


if [[ $pipeline == "dry" ]]; then
    echo "------------------------------------------------------------------------"
	echo "*** STARTING DryRun ***"
    module load snakemake python

    snakemake -s workflow/Snakefile \
    --configfile config/snakemake_config.yaml \
    --printshellcmds \
    --verbose \
    --rerun-incomplete \
    -npr

elif [[ $pipeline == "run" ]]; then
    echo "------------------------------------------------------------------------"
	echo "*** STARTING Local Execution ***"
    module load snakemake python

    snakemake -s workflow/Snakefile \
    --configfile config/snakemake_config.yaml \
    --printshellcmds \
    --verbose \
    --rerun-incomplete

else 
    echo "Select the options dry or run with the -p flag"

fi