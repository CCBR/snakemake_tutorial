## Prepare the environment
Connect to Biowulf and load an interactive session
```
# login
ssh -Y $USER@biowulf.nih.gov

# load interactive session
srun -N 1 -n 1 --time=12:00:00 -p interactive --mem=8gb  --cpus-per-task=4 --pty bash
```

## Clone the Repo
Clone the github repo
```
cd /path/to/working/dir

git clone https://github.com/slsevilla/snakemake_tutorial.git

cd snakemake_tutorial
```

## Completing the Activty
Two diretories were created within the repo. The `pipeline_todo` directory should be used to complete the tutorial, editing all files as needed. The `pipeline_example` directory has the activity completed and should be used a reference for completing each of the tasks.

NOTE: There are multiple ways to complete each rule, so review the expected outputs within the `pipeline_example/output` directory if your code varies.