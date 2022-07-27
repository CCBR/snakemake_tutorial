
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
```
├── sample_1_rulea.txt
├── sample_2_rulea.txt
```

- The output of Rule B:
```
├── sample_1_rulea.txt
├── sample_1_ruleb.txt
├── sample_2_rulea.txt
├── sample_2_ruleb.txt
```

- The output of Rule C:
```
├── final_output
│   ├── merged_rulea.txt
├── sample_1_rulea.txt
├── sample_1_ruleb.txt
├── sample_2_rulea.txt
└── sample_2_ruleb.txt
```

- The output of Rule D:
```
├── final_output
│   ├── merged_rulea.txt
│   ├── sample_1_copied_ruleb.txt
│   ├── sample_2_copied_ruleb.txt
├── sample_1_rulea.txt
├── sample_1_ruleb.txt
├── sample_2_rulea.txt
└── sample_2_ruleb.txt
```

- The output of advanced tasks:
```
final_output/
├── merged_rulea.txt
├── sample_1_copied_ruleb.txt
└── sample_2_copied_ruleb.txt
```

- The output of Rule E:
```
final_output/
├── merged_rulea.txt
├── sample_1_copied_ruleb.txt
├── sample_1.sam
├── sample_2_copied_ruleb.txt
└── sample_2.sam
```

# Explanations
## General Notes
- The `join` and `expand` functions
    - the join function is used to create and manage path structure by converting all "," to 
    - the expand expands each variable defined, iterating through combinations
    - for example (expand(join(out_dir,'{sp}_rulea.txt'),sp=sp_list)) expands to the following:
        - expand(/path/to/out_dir/{sp}_rulea.txt)
    - the sp_list is defined as ('sample_1' and 'sample_2'), the command expands further to:
        - (/path/to/out_dir/sample_1_rulea.txt,/out/dir/sample_2_rulea.txt)
## Rule A
- Rule A requires that wildcards `{sp}` used in both the input and output. This wildcard is defined in the rule all, by setting the output of rule A with definition as `sp=sp_list`.
```
# ruleA output
expand(join(out_dir,'{sp}_rulea.txt'),sp=sp_list),
```
- An example of this rule's execution follows:
```
rule A:
    input:
        fq = join(data_dir,'{sp}.fq')
    output:
        final = join(out_dir,'{sp}_rulea.txt')
    shell:
        '''
        cat {input.fq} > {output.final}
        echo "\nruleA completed" >> {output.final}
        '''
```

## Rule B
- Rule B requires a function to be used in order to generate the required input. The function uses the `wildcards` feature to pull the information from the output `{sp}`. Again, this wildcard is defined in the rule all, by setting the output of rule B with `sp=sp_list`.
- An example of this def and the rule's execution follows:
```
def get_input_files(wildcards):
    #example: {data_dir}/{sample_id.fq}
    fq = join(data_dir,fastq_dict[wildcards.sp])
    return(fq)

rule B:
    input:
        fq = get_input_files    
    output:
        final = join(out_dir,'{sp}_ruleb.txt')
    shell:
        '''
        cat {input.fq} > {output.final}
        echo "\nruleB completed" >> {output.final}
        '''
```
## Rule C
- Rule C requires a function to perform a command, which is directed through `params: cmd`. In this example the command is a simple copy, where the output has changed names.
- An example of this def and the rule's execution follows:
```
def get_rulec_cmd(wildcards):
    cmd='cat '
    sp_paths=''
    for sp in sp_list:
        # set source (ruleB) and destination files
        source = join(out_dir, sp + '_rulea.txt')

        # create command
        sp_paths = source + ' ' + sp_paths
    
    # add output path    
    destination = join(out_dir, 'final_output','merged_rulea.txt')
    cmd = cmd + sp_paths + ' >> ' + destination

    return(cmd)

rule C:
    input:
        rulea = expand(join(out_dir,'{sp}_rulea.txt'),sp=sp_list)
    params:
        cmd = get_rulec_cmd
    output:
        final = join(out_dir,'final_output','merged_rulea.txt')
    shell:
        '''
        # create the final output file
        touch {output.final}

        # run the cat command
        {params.cmd}
        '''
```

## Rule D
- Rule D required that the input of the rule be the linked to Rule B. This is accomplished using the `rules.output` format. Since individual files are included through the iteration of `sp` in the rules all. If the output file was a single file, all output files of rule B would be given as a single list.
- An example of this def and the rule's execution follows:
```
def get_ruled_cmd(wildcards):
    cmd=''
    for sp in sp_list:
        # set source (ruleB) and destination files
        source = join(out_dir, wildcards.sp + '_ruleb.txt')
        destination = join(out_dir, 'final_output', wildcards.sp + '_copied_ruleb.txt')

        # cp the the files
        cmd = 'cp ' + source + ' ' + destination + '; ' + cmd

    return(cmd)

rule D:
    input:
        ruleb = rules.B.output.final
    params:
        cmd = get_ruled_cmd
    output:
        final = join(out_dir, 'final_output', '{sp}_copied_ruleb.txt')
    shell:
        '''
        # run the command
        {params.cmd}
        '''
```
## Temp files
- To designate a `temp` file, simply include `temp` prior to the file name in output, as shown below:
```
rule B:
    input:
        fq = get_input_files
    params:
        rname='rule_B',
    output:
        final = temp(join(out_dir,'{sp}_ruleb.txt'))
    shell:
        '''
        cat {input.fq} > {output.final}
        echo "\nruleB completed" >> {output.final}
        '''
```

## Link rule name to log files
- This must be done in two steps. First, each rule must include a param with the `rname` variable, as shown below:
```
rule B:
    input:
        fq = get_input_files
    params:
        rname='rule_B',
    output:
        final = temp(join(out_dir,'{sp}_ruleb.txt'))
    shell:
        '''
        cat {input.fq} > {output.final}
        echo "\nruleB completed" >> {output.final}
        '''
```
- Then, the param variable can be used in the submission of the sbatch file. For example `{params.rname}` is used below:
```
"sbatch --gres {cluster.gres} --cpus-per-task {cluster.threads} \
    -p {cluster.partition} -t {cluster.time} --mem {cluster.mem} --job-name={params.rname} \
    --output=${output_dir}/log/{params.rname}{cluster.output} \
    --error=${output_dir}/log/{params.rname}{cluster.error}"
```

## Initalization
- Initialization features ensure that the pipeline configuration files and documentation is stored with the pipeline. This includes creating output dirs, not included in snakemake and copiying configuration files that are utilized within the pipeline. Finally, sed commands can be used to replace variables with either command_line inputs or current_directory inputs, as shown below:
```
# create directories if they do not exist
if [[ ! -d $output_dir ]]; then mkdir $output_dir; fi
dir_list=(config log)
for pd in "${dir_list[@]}"; do if [[ ! -d $output_dir/$pd ]]; then mkdir -p $output_dir/$pd; fi; done

# saving files, updating the configs with correct paths
files_save=('config/snakemake_config.yaml' 'workflow/Snakefile' 'config/cluster_config.yaml')
for f in ${files_save[@]}; do
    # set absolute path of file
    f="${PIPELINE_HOME}/$f"

    # create an array of the absolute path, with the delimiter of "/"
    IFS='/' read -r -a strarr <<< "$f" 

    # replace the variables PIPELINE_HOME and OUTPUT_dir in any files within the files_save array ($f)
    # save this output to the file name (strarr[-1]) in the output_dir/config location
    sed -e "s/PIPELINE_HOME/${PIPELINE_HOME//\//\\/}/g" -e "s/OUTPUT_DIR/${output_dir//\//\\/}/g" $f > "${output_dir}/config/${strarr[-1]}"

done
```
## Cluster notes
- Update the `cluster_config.yaml` for a specific rule by adding that rule name, and including the parameter to change. For example, to change the time limit from `2` hours to `1` hour and threads from `4` to `2` for Rule E:
```
E:
  time: 00-01:00:00
  threads: 2
```

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
    --cores 1 \
    --cluster-config ${output_dir}/config/cluster_config.yaml \
    -j 5 \
    --cluster \
    "sbatch --gres {cluster.gres} --cpus-per-task {cluster.threads} \
    -p {cluster.partition} -t {cluster.time} --mem {cluster.mem} --job-name={params.rname} \
    --output=${output_dir}/log/{params.rname}{cluster.output} \
    --error=${output_dir}/log/{params.rname}{cluster.error}"
```
- The breakdown of this is to create an sbatch job which acts as the `master` job, and controls all subsequent jobs. This master job submits the `snakemake` command, with all accompanying Snakefile and config files. Finally, the `cluster` command submits the criterion for all rule-related sbatch jobs that will be used as the pipeline runs

## Rule E
- Rule E required the addition of `envmodules` which reads from the added config parameter `samtools`, as well as the `threads` option. 
- An example of this rule's execution follows:
```
rule E:
    input:
        bamfile = join(data_dir,'{sp}.bam')
    envmodules:
        config['samtools']
    params:
        rname='rule_E',
    threads: getthreads("E")
    output:
        final = join(out_dir, 'final_output', '{sp}.sam')
    shell:
        '''
        samtools view -H -@ {threads} {input.bamfile} > {output.final}
        '''
```