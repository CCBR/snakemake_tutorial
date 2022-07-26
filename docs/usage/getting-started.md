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

cd snakemake_tutorial/pipeline_todo
```