# Overview
Learn some of the basics of Snakemake through the following tutorial.
1. Create a rule
2. Perform a dry-run (Command Line)
3. Perform a complete run (Command line)
4. Use script to invoke Snakemake

# Create a rule
Manifest files have already been created in the `/snakemake_tutorial/pipeline_todo/manifest` directory. This includes

sample_manifest.csv
```
sample_id,file_name
sample1,sample1.fq
sample2,sample2.fq
```

The task can be broken up into pre-processing, sample handling, and rule creation, all which should be completed in the `/snakemake_tutorial/pipeline_todo/workflow/Snakefile`

A. Pre-Processing
- Create two different Snakemake commands, one for a dry run and one for a local run
- Include the path to the workflow/Snakefile, the config/snakemake_config.yaml
- Include flags --printshellcmds, --verbose, --rerun-incomplete

B. Sample Handling
- Create the parameters in the `snakemake_tutorial/pipeline_todo/config/snakemake_config.yaml`
```
'sampleManifest' which gives the path of the sampleManifest

'out_dir' which gives the path to the output dir (must exist)

'data_dir' which gives the path to the data dir found under "/snakemake_tutorial/data/"
```
- Create the sample dictionaries and project lists from the manifest
```
`CreateSampleDicts` creates a dictionary matching sample_id to filename

`CreateProjLists` creates a project lists `sp_list` which contains all sample_ids and `file_list` which contains all filenames
```

C. Create three rules
- Rule A
    - input files should be `{sample_id}.fq`
    - output should be `{sample_id}_rulea.txt` and should be output to the `out_dir`
    - shell command should add a line "ruleA completed" to the original file
- Rule B
    - input files should be `get_input_files`
    - this definition will look up the name of the fq by taking in the `sample_id` as a wildcard, and using the `samp_dict`
    - output should be `{sample_id}_ruleb.txt` and should be output to the `out_dir`
    - shell command should add a line "ruleB completed" to the original file
- Rule C
    - input files should be all of Rule B's output files
    - output should be `merged.txt` and should be output to the `out_dir`
    - params should be def `get_rulec_cmd` which iterates through all samples and creates a command `cat {sample1}_ruleb.txt >> {final_file}; cat {sample2}_ruleb.txt >> {final_file}` 
    - shell command should run the `cmd_rulec` parameter

# Hints / Reminders
- Create rule_all for each rule one at a time. Start with Rule A, then B, then C. Perform dry runs and complete runs between each rule
- Rule A and rule B are using the same input files, but only differ in how these files are being referenced. There are times when the sample_id of an input file will match, but other times (as when taking in a multiplexed ID when they will not be the same). Rule A handles cases where they match, rule B handles cases where they would not match.
- Use the expand feature for Rule C's input to gather all required input files
- Use the sp_list that was created to iterate through all of the samples to create the ruleC cmd