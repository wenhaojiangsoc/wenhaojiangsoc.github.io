---
layout: post
title: Getting Started with the Duke Compute Cluster
date: 2026-11-01
description: How students in my group get access to the DCC, move their files, and run a first job.
categories: guides
related_posts: false
toc:
  sidebar: left
---

This guide is for students working with me, and for anyone at Duke who is new to the Duke Compute Cluster (DCC). It follows my Fall 2025 sociology pro-seminar talk, *Duke Compute Cluster and Cloud Computing*.

The idea is simple: the DCC lets you do what you already do on your laptop, on a much more powerful remote machine. Every job needs three things, and the guide covers them in order:

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
- **Everyday work.** Bootstrapping a regression 100 times on 10 million ACS records can take more than a day on a laptop. On the DCC you submit it and get on with your day.

## Get access

You need a Duke NetID and a working Duo login. The Duke VPN is not required.

### Students in my group

1. Send me your NetID.
2. I add you to my research group, `wenhaolab`, in [Research Toolkits](https://rtoolkits.web.duke.edu).
3. Once your access is provisioned, you can log in and use the shared folder `/hpc/group/wenhaolab`, where our project data live.

Access lasts while you work on a project with me. When the project ends, I remove you from the group, so copy anything you want to keep before then.

### PhD students

Duke PhD students can also claim a personal allocation with compute hours and 500 GB of storage, independent of any lab.

1. Log in to [Research Toolkits](https://rtoolkits.web.duke.edu) and click **Claim Doctoral Resources**.
2. Open the new project, choose **Add a service**, and select **DCC Grant**.

The second step is easy to miss: without it the project does not give you cluster access. See Duke's [PhD allocation guide](https://dcc.duke.edu/help/Phdstudentaccess/). If you also work with me, I still add you to `wenhaolab` so you can reach our shared data.

> ##### If you cannot log in
>
> Ask me to confirm you are on the group's member list, and allow some time for provisioning after being added. Make sure Duo works at [Duke MFA help](https://idms-mfa.oit.duke.edu/mfa/help). If it still fails, email [rescomputing@duke.edu](mailto:rescomputing@duke.edu) with the command you ran and its full output.
{: .block-warning }

## Move your files

[Globus](https://app.globus.org) is the easiest way to move files between your computer and the DCC.

1. Install **Globus Connect Personal** and log in at [app.globus.org](https://app.globus.org) with your Duke account.
2. In the File Manager, set one panel to **Duke Compute Cluster (DCC) Data Transfer Node** at `/hpc/group/wenhaolab/`.
3. Set the other panel to your own computer.
4. Select files and click **Start**.

### Where things live

| Location               | Use it for                                  |
| :--------------------- | :------------------------------------------ |
| `/hpc/home/<netid>`    | Your small home folder: settings, scripts   |
| `/hpc/group/wenhaolab` | Shared lab storage: project data and code   |
| `/work/<netid>`        | Large scratch space for temporary files     |

Treat `/work` as temporary and keep anything you cannot afford to lose in the group folder.

## Run your first job

### Point your code at the cluster

Your code usually runs unchanged. Only the file paths need to point to the DCC instead of your laptop:

```r
acs <- read.csv("/hpc/group/wenhaolab/Proseminar/Data/demoACS.csv")
```

### Write a job script

A job script is a shell script whose `#SBATCH` lines request resources from Slurm, the scheduler. Save this as `demo.sh` next to your code:

```bash
#!/usr/bin/env bash
#SBATCH --job-name=demo
#SBATCH --partition=common
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=<netid>@duke.edu

module purge
module load R
Rscript /hpc/group/wenhaolab/Proseminar/Codes/demo.R
```

| Line                                | Meaning                                                                                              |
| :---------------------------------- | :--------------------------------------------------------------------------------------------------- |
| `--partition`                       | The queue: `common` for CPU jobs, `gpu-common` for GPU jobs ([all partitions](https://dcc.duke.edu/dcc/partitions/)) |
| `--cpus-per-task`, `--mem`, `--time` | What you request. Larger requests wait longer in the queue                                           |
| `--output`                          | Where your code's printed output goes. Create the folder first with `mkdir logs`                     |
| `module load`                       | The software to use. `module avail R` lists the versions                                              |

### Connect and submit

Open Terminal (macOS) or MobaXterm (Windows) and log in with your NetID:

```bash
ssh <netid>@dcc-login.oit.duke.edu
```

Type your Duke password (nothing appears as you type) and approve the Duo prompt. Then submit:

```bash
cd /hpc/group/wenhaolab/Proseminar/Codes
sbatch demo.sh
```

Slurm replies with a job ID. The job runs as soon as resources are free, whether or not you stay logged in.

> ##### Do not compute on the login node
>
> The machine you land on after `ssh` is shared by everyone. Use it to move around, edit files, and submit jobs. Heavy processes started there are stopped automatically.
{: .block-danger }

## Monitor and manage

| Command             | What it does                              |
| :------------------ | :---------------------------------------- |
| `squeue -u <netid>` | List your queued and running jobs         |
| `scancel <jobid>`   | Cancel a job                              |
| `cat <file>`        | Print a file, such as a log in `logs/`    |
| `nano <file>`       | Edit a file in the terminal               |
| `du -h`             | Show how much space folders use           |
| `module avail`      | List the software available on the DCC    |
| `module purge`      | Unload everything before loading modules  |

## Work interactively

To try things line by line, for example testing a model on a GPU, request an interactive session instead of a batch job:

```bash
srun -p gpu-common --gres=gpu:1 --mem=80G --time=02:00:00 --pty bash
```

When the prompt changes, you are on a compute node and can start R or Python as usual. Type `exit` when done so the GPU goes back to the pool. For short CPU tests, use `-p interactive`.

> ##### Prefer a browser?
>
> [Open OnDemand](https://dcc-ondemand-01.oit.duke.edu) runs RStudio, Jupyter, and a Linux desktop on the DCC in your web browser, no terminal needed.
{: .block-tip }

## Get help

- Duke's [DCC user guide](https://dcc.duke.edu) covers all of this in more depth, including SSH keys and VS Code.
- Research Computing answers questions at [rescomputing@duke.edu](mailto:rescomputing@duke.edu).
- Students in my group can reach me at [wenhao.jiang@duke.edu](mailto:wenhao.jiang@duke.edu).
