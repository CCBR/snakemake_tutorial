
# Dry Run Expected Output
- The output of the dry-run for Rule A should look as follows:
```
job      count    min threads    max threads
-----  -------  -------------  -------------
A            2              1              1
all          1              1              1
total        3              1              1
```

- The output of the dry-run for Rules A-B should look as follows:
```
job      count    min threads    max threads
-----  -------  -------------  -------------
A            2              1              1
B            2              1              1
all          1              1              1
total        5              1              1
```

- The output of the dry-run for Rules A-C should look as follows:
```
job      count    min threads    max threads
-----  -------  -------------  -------------
A            2              1              1
B            2              1              1
C            1              1              1
all          1              1              1
total        6              1              1
```

- The output of the dry-run for Rules A-D should look as follows:
```
job      count    min threads    max threads
-----  -------  -------------  -------------
A            2              1              1
B            2              1              1
C            1              1              1
D            2              1              1
all          1              1              1
total        8              1              1
```

- The output of the dry-run for Rules A-E should look as follows:
```
job      count    min threads    max threads
-----  -------  -------------  -------------
A            2              1              1
B            2              1              1
C            1              1              1
D            2              1              1
E            2              1              1
all          1              1              1
total        10             1              1
```

# Expected Output Files / Structure
- The output of Rule A:
├── sample_1_rulea.txt
├── sample_2_rulea.txt

- The output of Rule B:
├── sample_1_rulea.txt
├── sample_1_ruleb.txt
├── sample_2_rulea.txt
├── sample_2_ruleb.txt

- The output of Rule C:
├── final_output
│   ├── merged_rulea.txt
├── sample_1_rulea.txt
├── sample_1_ruleb.txt
├── sample_2_rulea.txt
└── sample_2_ruleb.txt

- The output of Rule D:
├── final_output
│   ├── merged_rulea.txt
│   ├── sample_1_copied_ruleb.txt
│   ├── sample_2_copied_ruleb.txt
├── sample_1_rulea.txt
├── sample_1_ruleb.txt
├── sample_2_rulea.txt
└── sample_2_ruleb.txt

- The output of advanced tasks:
final_output/
├── merged_rulea.txt
├── sample_1_copied_ruleb.txt
└── sample_2_copied_ruleb.txt

- The output of Rule E:
final_output/
├── merged_rulea.txt
├── sample_1_copied_ruleb.txt
├── sample_1.sam
├── sample_2_copied_ruleb.txt
└── sample_2.sam

# Explanations
## General Notes
- The `join` and `expand` functions
    - the join function is used to create and manage path structure by converting all "," to 
    - the expand expands each variable defined, iterating through combinations
    - for example (expand(join(out_dir,'{sp}_rulea.txt'),sp=sp_list)) expands to the following:
        - expand(/path/to/out_dir/{sp}_rulea.txt)
    - the sp_list is defined as ('sample_1' and 'sample_2'), the command expands further to:
        - (/path/to/out_dir/sample_1_rulea.txt,/out/dir/sample_2_rulea.txt)

## Cluster notes
- An example of the full cluster command needed to excute the pipeline is as follow:
```
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
```

The breakdown of this is to create an sbatch job which acts as the `master` job, and controls all subsequent jobs. This master job submits the `snakemake` command, with all accompanying Snakefile and config files. Finally, the `cluster` command submits the criterion for all rule-related sbatch jobs that will be used as the pipeline runs