---
layout: post
title: Getting Started with the Duke Compute Cluster
date: 2026-11-01
categories: guides
related_posts: false
toc:
  sidebar: left
---

This guide accompanies my talk at the Duke Sociology Pro-Seminar on November 20, 2026. It walks through the Duke Compute Cluster (DCC) from first login to running hundreds of jobs at once, and it is meant to stay useful after the session as a reference.

The idea is simple: the DCC lets you do what you already do on your laptop, on a much more powerful remote machine. Every job needs three things:

1. **Data**, the files you want to analyze.
2. **Code**, your R, Stata, or Python script.
3. **A job script**, a short file telling the cluster what resources you need and which code to run.

<figure class="flow">
<svg viewBox="0 0 720 150" role="img" aria-label="Files move from your computer to DCC storage with Globus; sbatch sends the job to compute nodes, which write results back to storage.">
<defs><marker id="flow-arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0,0 L10,5 L0,10 z" class="head"/></marker></defs>
<rect x="1" y="35" width="190" height="76" rx="8"/>
<text x="96" y="68" class="t">Your computer</text>
<text x="96" y="90" class="s">data · code · job script</text>
<rect x="265" y="35" width="190" height="76" rx="8"/>
<text x="360" y="68" class="t">DCC storage</text>
<text x="360" y="90" class="s">/hpc/group/wenhaolab</text>
<rect x="529" y="35" width="190" height="76" rx="8"/>
<text x="624" y="68" class="t">Compute nodes</text>
<text x="624" y="90" class="s">CPUs · GPUs · memory</text>
<line x1="195" y1="62" x2="259" y2="62" class="a" marker-end="url(#flow-arrow)"/>
<text x="228" y="52" class="l">Globus</text>
<line x1="459" y1="62" x2="523" y2="62" class="a" marker-end="url(#flow-arrow)"/>
<text x="492" y="52" class="l">sbatch</text>
<path d="M624,115 C624,140 360,140 360,117" class="a back" marker-end="url(#flow-arrow)"/>
<text x="492" y="148" class="s">results and logs</text>
</svg>
</figure>

## Why use the DCC

Social science data increasingly outgrow a personal computer. A cluster gives you more CPUs, GPUs, memory, and storage, and it keeps working for hours or days after you close your laptop.

- **Mobility and networks.** Nilforoshan et al. (2023) built mobility networks from 1.6 billion co-location events among 9.6 million people.
- **Images.** Ludwig and Mullainathan (2024) trained a neural network on mugshots to study judges' detention decisions; Müller et al. (2022) measured neighborhood perceptions from street-level images. Both need GPUs.
- **Everyday work.** Bootstrapping a regression 100 times on 10 million ACS records can take more than a day on a laptop. On the DCC, 100 bootstrap draws can run side by side and finish in minutes.

## How the cluster works

A cluster is many computers, called **nodes**, sharing storage and managed by a **scheduler**. You never pick a machine yourself. You describe what your job needs, and the scheduler, Slurm, finds a node with those resources free.

| Term             | Meaning                                                                                             |
| :--------------- | :-------------------------------------------------------------------------------------------------- |
| Login node       | Where you arrive after `ssh`. Shared by everyone; for editing files and submitting jobs only        |
| Compute node     | Where jobs actually run. Each has many CPU cores, a lot of memory, and sometimes GPUs               |
| Job              | One unit of work you submit, with its requested resources                                           |
| Partition        | A queue of nodes with its own rules, such as `common` for CPU jobs and `gpu-common` for GPU jobs    |
| Resources        | What a job asks for: CPU cores, memory, GPUs, and time (walltime)                                   |

Slurm reserves exactly what you request for the whole life of the job, whether or not you use it. Small, accurate requests start sooner; oversized ones wait longer and keep resources from everyone else.

## Get access

You need a Duke NetID and a working Duo login. The Duke VPN is not required.

### For the Pro-Seminar

Before the session, I add each of you to my research group, `wenhaolab`, in [Research Toolkits](https://rtoolkits.web.duke.edu). This gives you temporary access to the cluster and to the demo files in `/hpc/group/wenhaolab/Proseminar`. Please send me your NetID if I do not have it yet.

This access is for the session and a short period after. For your own research, claim your PhD allocation below.

### Your own PhD allocation

Duke PhD students can claim a personal allocation with compute hours and 500 GB of storage, independent of any lab.

1. Log in to [Research Toolkits](https://rtoolkits.web.duke.edu) and click **Claim Doctoral Resources**.
2. Open the new project, choose **Add a service**, and select **DCC Grant**.

The second step is easy to miss: without it the project does not give you cluster access. See Duke's [PhD allocation guide](https://dcc.duke.edu/help/Phdstudentaccess/).

> ##### If you cannot log in
>
> Allow some time for provisioning after being added, and make sure Duo works at [Duke MFA help](https://idms-mfa.oit.duke.edu/mfa/help). If it still fails, email [rescomputing@duke.edu](mailto:rescomputing@duke.edu) with the command you ran and its full output.
{: .block-warning }

## Move your files

[Globus](https://app.globus.org) is the easiest way to move files between your computer and the DCC.

1. Install **Globus Connect Personal** and log in at [app.globus.org](https://app.globus.org) with your Duke account.
2. In the File Manager, set one panel to **Duke Compute Cluster (DCC) Data Transfer Node** at `/hpc/group/wenhaolab/`.
3. Set the other panel to your own computer.
4. Select files and click **Start**.

### Where things live

| Location               | Size              | Use it for                                     | Kept                         |
| :--------------------- | :---------------- | :--------------------------------------------- | :--------------------------- |
| `/hpc/home/<netid>`    | 25 GB             | Scripts, settings, environment setup           | While your NetID is active   |
| `/hpc/group/wenhaolab` | 1 TB, shared      | Lab data and code                              | Persistent, 7-day snapshots  |
| `/hpc/dctrl/<netid>`   | 500 GB            | Your PhD allocation                            | Persistent, no backups       |
| `/work/<netid>`        | Large, shared     | Big data sets and intermediate results         | **Purged after 75 days**     |

Treat `/work` as scratch: anything older than 75 days is deleted automatically. Keep code and anything you cannot afford to lose elsewhere. See Duke's [storage guide](https://dcc.duke.edu/storage/) for details.

## Run your first job

### Point your code at the cluster

Your code usually runs unchanged. Only the file paths need to point to the DCC instead of your laptop:

```r
acs <- read.csv("/hpc/group/wenhaolab/Proseminar/Data/demoACS.csv")
```

### Write a job script

A job script is a shell script whose `#SBATCH` lines request resources from Slurm. Save this as `demo.sh` next to your code:

```bash
#!/usr/bin/env bash
#SBATCH --job-name=demo
#SBATCH --partition=common
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=<netid>@duke.edu

module load R-openblas/4.6.1
Rscript demo.R
```

| Line           | Meaning                                                                                                          |
| :------------- | :--------------------------------------------------------------------------------------------------------------- |
| `--partition`  | The queue to use. `common` is the default for CPU jobs ([all partitions](https://dcc.duke.edu/dcc/partitions/))  |
| `--cpus-per-task`, `--mem`, `--time` | What you request. See [Request the right resources](#request-the-right-resources)                |
| `--output`     | Where printed output goes. `%x` is the job name and `%j` the job ID. Create the folder first with `mkdir logs`  |
| `--mail-type`  | Email you when the job ends or fails                                                                             |
| `module load`  | The software to use. `module avail` lists everything installed                                                   |

### Connect and submit

Open Terminal (macOS) or MobaXterm (Windows) and log in with your NetID:

```bash
ssh <netid>@dcc-login.oit.duke.edu
```

Type your Duke password (nothing appears as you type) and approve the Duo prompt. Then go to your code and submit:

```bash
cd /hpc/group/wenhaolab/Proseminar/Codes
mkdir -p logs
sbatch demo.sh
```

Slurm replies with a job ID, such as `Submitted batch job 186554`. The job runs as soon as resources are free, whether or not you stay logged in.

> ##### Do not compute on the login node
>
> The login node is shared by everyone. Use it to move around, edit files, and submit jobs. Heavy processes started there are stopped automatically; use an [interactive session](#gpus-and-interactive-work) instead.
{: .block-danger }

## Request the right resources

### Time

Set a walltime with `--time`, as `HH:MM:SS` or `D-HH:MM:SS`. A job that runs past its walltime is stopped, so leave some margin, but not days of it. Each partition has a maximum; `common` allows up to 30 days.

### Memory

Without a request, a job gets 2 GB per CPU, and this is a hard limit: a job that needs more is stopped with `OUT_OF_MEMORY`. Ask for the peak your job needs with `--mem=16G` (total) or `--mem-per-cpu=4G`. A data frame usually takes several times its file size once loaded in R.

### CPUs and parallel R

One CPU is enough for most R and Stata scripts. Ask for more only if your code uses them. With `--cpus-per-task=4`, R can run four tasks at a time:

```r
library(parallel)
cores <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK"))
results <- mclapply(1:100, function(b) {
  boot <- acs[sample(nrow(acs), replace = TRUE), ]
  coef(lm(y ~ x, data = boot))   # replace with your model
}, mc.cores = cores)
```

Read the core count from `SLURM_CPUS_PER_TASK` rather than typing a number, so the code always matches what Slurm gave you. The `R-openblas` module also speeds up matrix operations such as `lm` on large data when you request several CPUs. See Duke's [parallel R guide](https://dcc.duke.edu/examples/parallel-r/).

### Check what you actually used

After a job finishes, compare what it used with what you asked for, and adjust the next request:

```bash
seff <jobid>
```

`seff` reports CPU efficiency and peak memory. If your job used 2 GB of a 32 GB request, ask for 4 GB next time; it will start sooner.

## Run many jobs at once

### Job arrays

Many social science tasks are the same code run many times: bootstrap draws, simulations, one model per state or year. A **job array** submits all of them from one script. Each copy receives its own number in `SLURM_ARRAY_TASK_ID`.

```bash
#!/usr/bin/env bash
#SBATCH --job-name=boot
#SBATCH --array=1-100%20
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --output=logs/%x_%A_%a.out

module load R-openblas/4.6.1
Rscript boot.R
```

`--array=1-100%20` runs tasks 1 to 100, at most 20 at a time. In the output name, `%A` is the array's job ID and `%a` the task number. In `boot.R`, use the task number to make each draw distinct and to name its output:

```r
task <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))
set.seed(task)
acs  <- read.csv("/hpc/group/wenhaolab/Proseminar/Data/demoACS.csv")
boot <- acs[sample(nrow(acs), replace = TRUE), ]
fit  <- lm(y ~ x, data = boot)   # replace with your model
saveRDS(coef(fit), sprintf("results/boot_%03d.rds", task))
```

When all tasks finish, a short script reads the 100 files in `results/` and combines them. If task 37 fails, rerun just that one with `sbatch --array=37 boot.sh`. The same pattern works for one task per input file: put the file names in a list and let each task pick the line matching its number.

### Chaining jobs

To start a job only after another succeeds, such as combining results after the array finishes, use a dependency:

```bash
jid=$(sbatch --parsable boot.sh)
sbatch --dependency=afterok:$jid combine.sh
```

## GPUs and interactive work

### Interactive sessions

To try things line by line on a compute node, request an interactive session instead of a batch job:

```bash
srun --partition=common --cpus-per-task=1 --mem=4G --time=01:00:00 --pty bash
```

When the prompt changes, you are on a compute node: load modules and start R or Python as usual. Type `exit` when done to release the resources.

### GPUs

Deep learning, image models, and local language models need a GPU. Request one in a job script with:

```bash
#SBATCH --partition=gpu-common
#SBATCH --gres=gpu:1
```

or interactively:

```bash
srun --partition=gpu-common --gres=gpu:1 --mem=16G --time=01:00:00 --pty bash
```

Run `gpuavail gpu-common` on the login node to see which GPU types are free right now. The `gpu-common` partition allows jobs of up to 2 days.

> ##### Prefer a browser?
>
> [Open OnDemand](https://dcc-ondemand-01.oit.duke.edu) runs RStudio, Jupyter, and a Linux desktop on the DCC in your web browser, no terminal needed. It is a gentle way to start, and it still runs on compute nodes.
{: .block-tip }

## Monitor and troubleshoot

### Everyday commands

| Command                                                         | What it does                                  |
| :-------------------------------------------------------------- | :-------------------------------------------- |
| `squeue --me`                                                   | Your queued (`PD`) and running (`R`) jobs     |
| `scontrol show job <jobid>`                                     | Full details of one job, including why it waits |
| `scancel <jobid>`                                               | Cancel a job                                  |
| `sacct -j <jobid> --format=JobID,State,Elapsed,MaxRSS,ExitCode` | How a job ended and its peak memory           |
| `seff <jobid>`                                                  | CPU and memory efficiency of a finished job   |
| `module avail`                                                  | Software installed on the DCC                 |
| `du -h --max-depth=1`                                           | How much space each folder uses               |

### When something goes wrong

| What you see                         | Likely cause and fix                                                                                       |
| :----------------------------------- | :--------------------------------------------------------------------------------------------------------- |
| Job stays `PD` for a long time       | The request is large or the cluster is busy. Ask for less memory, fewer CPUs, or less time                  |
| State `OUT_OF_MEMORY`                | The job exceeded its memory. Check `MaxRSS` with `sacct` and raise `--mem`                                 |
| State `TIMEOUT`                      | The job ran past `--time`. Raise it, or split the work into an array                                       |
| `command not found`                  | The software is not loaded. Add the `module load` line to the job script                                   |
| `cannot open file`                   | A path still points to your laptop, or the file is not on the DCC yet                                      |
| Nothing in the output file           | Look at the end of the log in `logs/` for the error; R and Python print it there                           |

> ##### Test small first
>
> Before submitting 100 tasks or a two-day job, run one small version: a 1% sample, one array task, or a few minutes in an interactive session. Most errors show up in the first minute.
{: .block-tip }

## Get help

- Duke's [DCC user guide](https://dcc.duke.edu) covers everything here in more depth, including SSH keys, VS Code, and containers.
- Research Computing answers questions at [rescomputing@duke.edu](mailto:rescomputing@duke.edu).
- Pro-Seminar participants can reach me at [wenhao.jiang@duke.edu](mailto:wenhao.jiang@duke.edu).
