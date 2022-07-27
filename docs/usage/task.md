# Overview
Learn some of the basics of Snakemake through the following tutorial.

1. Create a script to run Snakemake
2. Create variables to run a snakemake_config file
3. Create rules for scenarios
4. Use script to invoke Snakemake

# Manifest Files
Manifest files have already been created in the `/snakemake_tutorial/manifest` directory. This includes:

sample_manifest.csv
```
sample_id,fq_name,bam_name
sample_1,sample_1.fq,sample_1.bam
sample_2,sample_2.fq,sample_2.bam
```

# Activity
The task can be broken up into A. pre-processing, B. sample handling, C. rule creation, and D. Advanced Commands. All edits should be completed in the `/snakemake_tutorial/pipeline_todo/` directory.

## A. Pre-Processing 

- Create the `output_dir`, and a subdirectory `log`
- Create two different Snakemake commands, one for a dry run and one for a local run to the `run_snakemake.sh`. The commands should be `dry` or `local`.
    - Include the path to the workflow/Snakefile, the config/snakemake_config.yaml in both commands
    - Include flags --printshellcmds, --verbose, --rerun-incomplete in both commands
    - Include flag --cores 1 for the `local` command

## B. Sample Handling

- Create the parameters in the `config/snakemake_config.yaml`
```
'sampleManifest' which gives the path of the sampleManifest

'out_dir' which gives the path to the output dir (must exist)

'data_dir' which gives the path to the data dir found under "/snakemake_tutorial/data/"
```
- Create the sample dictionaries and project lists from the manifest in the `workflow/Snakefile`
```
`CreateSampleDicts` creates a dictionary matching sample_id to fq_file and a dictionary which matches sample_id to bam_file

`CreateProjLists` creates a project lists `sp_list` which contains all sample_ids, `fq_list` which contains all fq_file names, and `bam_list` which contains all bam_file names
```

## C. Basic activities
Complete each of the following tasks, in order. Be sure to perform dry runs and complete runs between each rule creation. The Hints section below provides guidance on each rule, while the Example page provides a detailed explanation of rule creation and features.

- General Tasks
    - Create rule_all for each rule one at a time in the `workflow/Snakefile`.
    - Create rule_all input for all fq input files, from the `fq_list`
- Rule A
    - input files should be `{sample_id}.fq`
    - output should be `{sample_id}_rulea.txt` and should be output to the `out_dir`
    - shell command should add a line "ruleA completed on a new line" to the original file
- Rule B
    - input files should be `get_input_files`. this definition will look up the name of the fq by taking in the `sample_id` as a wildcard, and using the `samp_dict`
    - output should be `{sample_id}_ruleb.txt` and should be output to the `out_dir`
    - shell command should add a line "ruleB completed on a new line" to the original file
- Rule C
    - input files should be all of Rule A's output files
    - params should be def `get_rulec_cmd` which iterates through all samples and creates a command `cat {sample1}_rulea.txt {sample2}_rulea.txt >> {final_file}` 
    - output should be `merged_rulea.txt` and should be output to the `out_dir/final_output`
    - shell command should touch the `{final_file}`, then run the `cmd` parameter
- Rule D
    - input files should be directly linked to Rule B's output files
    - params should be def `get_ruled_cmd` which iterates through all samples and creates a command `cp /output/path/{sample_id}_ruleb.txt /output/path/final_output/{sample_id)_copies_ruleb.txt;` for each sample
    - output should be `{sample_id}_copied_ruleb.txt` and should be output to the `out_dir/final_output`
    - shell command should run the `cmd` parameter

## D. Advanced activities
- Add features to the `workflow/Snakefile`:
    - Designate temp files
        - flag rule A and rule B files so they are deleted after the pipeline completion
    - Link rule names to log files
        - all rules must have a param called `rname` where the rule name is identified uniquely
- Utilize `cluster` for rules
    - Add features to the `run_snakemake.sh` file to include:
        - check if output_dir or output_dir/log are created; if not create them during invocation of the `run_snakemake.sh` file
        - copy the config/snakemake_config.yaml, config/cluster_config.yaml to the output_dir; ensure snakemake runs use these files
        - update all config files with the `output_dir` variable given from the command line and `pipeline_dir` variable based on the invocation location of the pipeline;
        - update the copies `cluster_config.yaml` to change the time limit from `2` hours to `1` hour and threads from `4` to `2` for Rule E
    - Add a new command to the `run_snakemake.sh` file:
        - name the new command `cluster`. This command will include all of the previous flags of `local`.
        - expand the `cluster` command with`sbatch` additional flags: 
            - `--job-name="snakemake_tutorial"`
            - `--gres=lscratch:200`
            - `--time=120:00:00`
            - `--output=${output_dir}/log/%j_%x.out`
            - `--mail-type=BEGIN,END,FAIL`
        - expand the `cluster` command further, with additional snakemake flags:
            - `--latency-wait 120`
            - `--use-envmodules`
            - `--cluster-config ${output_dir}/log/cluster_config.yml`
        - expand the `cluster` command further, with additional snakemake cluster flags:
            - `cluster "sbatch --gres {cluster.gres} --cpus-per-task {cluster.threads} -p {cluster.partition} -t {cluster.time} --mem {cluster.mem} --job-name={params.rname} --output=${output_dir}/log/{params.rname}{cluster.output} --error=${output_dir}/log/{params.rname}{cluster.error}"`
- Rule E
     General Tasks
        - Create rule_all input for all bam input files, from the `bam_list`
    - input files should be `{sample_id}.fq`
    - envmodules should load the samtools version `samtools/1.15.1` from the `snakemake_config.yaml` file
    - threads should use def `getthreads`
    - params should have `rname` set as a unique rule name
    - output should be `{sample_id}.sam` and should be output to the `out_dir/final_output`
    - shell command should use samtools to output the header to a sam file

# Hints
- Rule A and rule B are using the same input files, but only differ in how these files are being referenced. There are times when the sample_id of an input file will match, but other times (as when taking in a multiplexed ID when they will not be the same). Rule A handles cases where they match, rule B handles cases where they would not match.
- Rule B invokes a function to define the input files. Read more about this [here](https://snakemake.readthedocs.io/en/stable/tutorial/advanced.html#step-3-input-functions).
- Rule C uses the expand feature for to gather all required input files. Read more about this [here](https://snakemake.readthedocs.io/en/stable/tutorial/advanced.html#step-3-input-functions).
- Rule C and Rule D are outputting data to a directory that does not exist (`out_dir/final_output`). Snakemake will automatically create directories that don't exist, when they are listed as `output` files.
- Rule C should use the def definted to iterate through all the samples created in the sp_list.
- Rule D requires a "link" to Rule B's outptu through the use of the `rules.RuleName.output.OutputName`. Read more about this [here](https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#rule-dependencies).
- Advanced commands require use of the `temp` feature of snakemake. Read more about this [here](html#step-6-temporary-and-protected-files).
- Advanced commands require the use of the `cluster` feature of snakemake. Read more about this [here](https://snakemake.readthedocs.io/en/stable/executing/cluster.html#cluster-execution).
- Cluster config file will follow the variable format from Biowulf for all sbatch [parameters](https://hpc.nih.gov/docs/userguide.html)
- Rule E requires outputting the header `samtools view -H` of a file