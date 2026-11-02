---
layout: post
title: Getting Started with the Duke Compute Cluster
date: 2026-11-01
description: How students in my group get access to the DCC, move their files, and run a first job.
tags: dcc computing
categories: guides
related_posts: false
toc:
  sidebar: left
---

This guide is for students working with me, and for anyone else at Duke who is new to the Duke Compute Cluster (DCC). It follows the slides from my Fall 2025 sociology pro-seminar talk, *Duke Compute Cluster and Cloud Computing*. The idea is simple: the DCC lets you do what you already do on your laptop, only on a much more powerful remote machine.

## Why use the DCC

Modern social science data often outgrow a personal computer. A cluster gives you more CPUs, GPUs, memory, and storage, and it keeps running for hours or days after you close your laptop.

- **Mobility and networks.** Nilforoshan et al. (2023) built mobility networks from 1.6 billion co-location events among 9.6 million people.
- **Images.** Ludwig and Mullainathan (2024) trained a neural network on mugshots to study judges' detention decisions; Müller et al. (2022) measured neighborhood perceptions from street-level images. Both need GPUs.
- **Everyday work.** Bootstrapping a regression 100 times on 10 million ACS records can take more than a day on a laptop. On the DCC you submit it and get on with your day.

## Getting access

You need a Duke NetID and a working Duo (multifactor) login. The Duke VPN is not required.

### Students working with me

1. Send me your NetID.
2. I add you to my research group, `wenhaolab`, in [Research Toolkits](https://rtoolkits.web.duke.edu).
3. Once your access is provisioned, you can log in and use the shared group folder `/hpc/group/wenhaolab`, where our project data live.

Access lasts while you work on a project with me. When the project ends, I remove you from the group, so copy anything you want to keep before then.

### PhD students: your own allocation

Duke PhD students can also claim a personal DCC allocation, independent of any lab. It comes with compute hours and 500 GB of dedicated storage.

1. Log in to [Research Toolkits](https://rtoolkits.web.duke.edu).
2. Click **Claim Doctoral Resources**.
3. Open the new project, choose **Add a service**, and select **DCC Grant**. This step is easy to miss: without it the project does not give you cluster access.

The project page shows the status while access is provisioned. See Duke's [PhD allocation guide](https://dcc.duke.edu/help/Phdstudentaccess/) for details. If you claim your own allocation and also work with me, I still add you to `wenhaolab` so you can reach the shared project data.

> ##### If you cannot log in
>
> Check that you appear on the group's member list (ask me), give provisioning some time after being added, and make sure your Duo devices work at [Duke MFA help](https://idms-mfa.oit.duke.edu/mfa/help). If it still fails, email [rescomputing@duke.edu](mailto:rescomputing@duke.edu) with the command you ran and the full output.
{: .block-warning }

## The workflow in one picture

Every DCC job has three ingredients:

1. **Data**, the files you want to analyze.
2. **Code**, your R, Stata, or Python script.
3. **A job script**, a short text file that tells the cluster what resources you need and which code to run.

You move the first two to the cluster, write the third, and submit it.

## Moving files with Globus

[Globus](https://app.globus.org) is the easiest way to move files between your computer and the DCC.

1. Install **Globus Connect Personal** on your computer and log in at [app.globus.org](https://app.globus.org) with your Duke account.
2. In the File Manager, set one panel to the collection **Duke Compute Cluster (DCC) Data Transfer Node** and the path `/hpc/group/wenhaolab/`.
3. Set the other panel to your own computer.
4. Select files and click **Start** to transfer them.

{% include figure.liquid path="assets/img/posts/dcc/globus.png" class="img-fluid rounded z-depth-1" zoomable=true caption="The Globus File Manager. The DCC is on the left; a laptop folder is on the right." %}

### Where to put things

| Location                  | What it is for                                    |
| :------------------------ | :------------------------------------------------ |
| `/hpc/home/<netid>`       | Your small home directory: settings and scripts   |
| `/hpc/group/wenhaolab`    | Shared lab storage: project data and code         |
| `/work/<netid>`           | Large scratch space for temporary, bulky files    |

Treat `/work` as temporary. Keep anything you cannot afford to lose in the group folder.

## Pointing your code at the cluster

Your code usually runs unchanged. The one thing to update is file paths, which must point to the DCC rather than your laptop:

```r
acs <- read.csv("/hpc/group/wenhaolab/Proseminar/Data/demoACS.csv")
```

## Writing a job script

A job script is a shell script with a header of `#SBATCH` lines that request resources from Slurm, the scheduler. Save this as `demo.sh` next to your code:

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

- `--partition` picks the queue. `common` is the default for CPU jobs and `gpu-common` is for GPU jobs. See Duke's [partition list](https://dcc.duke.edu/dcc/partitions/) for the others and their time limits.
- `--cpus-per-task`, `--mem`, and `--time` are your requests. Ask for what you need; larger requests wait longer in the queue.
- `--output` is where everything your code prints goes. Create the `logs` folder first with `mkdir logs`.
- The `module` lines load the software. Run `module avail R` to see which versions exist and load a specific one if your code needs it.

## Connecting and submitting

Open Terminal (macOS) or MobaXterm (Windows) and log in, replacing `<netid>` with your own:

```bash
ssh <netid>@dcc-login.oit.duke.edu
```

Type your Duke password (nothing appears as you type; that is normal) and approve the Duo prompt. Then go to your code and submit:

```bash
cd /hpc/group/wenhaolab/Proseminar/Codes
ls
sbatch demo.sh
```

That's it. Slurm replies with a job ID, and the job runs as soon as resources are free, whether or not you stay logged in.

> ##### Do not compute on the login node
>
> The machine you land on after `ssh` is shared by everyone. Use it to move around, edit files, and submit jobs. Heavy processes started there are terminated automatically.
{: .block-danger }

## Keeping an eye on your jobs

| Command               | What it does                                 |
| :-------------------- | :------------------------------------------- |
| `squeue -u <netid>`   | List your queued and running jobs            |
| `scancel <jobid>`     | Cancel a job                                 |
| `cat <file>`          | Print a file, such as a log in `logs/`       |
| `nano <file>`         | Edit a file in the terminal                  |
| `du -h`               | Show how much space files and folders use    |

## Software modules

The DCC provides software through modules. Loading a module makes a program available in your session without version conflicts.

```bash
module avail          # list available software
module purge          # clear anything already loaded
module load <name>    # load what you need
```

## Interactive sessions and GPUs

Sometimes you want to try things out line by line, for example when testing a model on a GPU. Request an interactive session instead of a batch job:

```bash
srun -p gpu-common --gres=gpu:1 --mem=80G --time=02:00:00 --pty bash
```

When the prompt changes, you are on a compute node with a GPU and can start Python or R as usual. Type `exit` when you are done so the GPU goes back to the pool. For short CPU tests, use `-p interactive` instead.

> ##### Prefer a browser?
>
> [Open OnDemand](https://dcc-ondemand-01.oit.duke.edu) runs RStudio, Jupyter, and a Linux desktop on the DCC in your web browser, with no terminal needed. It is a gentle way to start.
{: .block-tip }

## Getting help

- Duke's [DCC user guide](https://dcc.duke.edu) covers everything here in more depth, including SSH keys, VS Code, and storage.
- Research Computing answers questions at [rescomputing@duke.edu](mailto:rescomputing@duke.edu).
- Students in my group can always reach me at [wenhao.jiang@duke.edu](mailto:wenhao.jiang@duke.edu).
