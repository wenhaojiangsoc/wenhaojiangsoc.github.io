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
<text x="360" y="90" class="s">/hpc/dctrl/&lt;netid&gt;</text>
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

Every Duke PhD student can claim a personal allocation with compute hours and 500 GB of storage at `/hpc/dctrl/<netid>`. It is yours, independent of any lab, and it is what we use in the Pro-Seminar.

1. Log in to [Research Toolkits](https://rtoolkits.web.duke.edu) and click **Claim Doctoral Resources**.
2. Open the new project, choose **Add a service**, and select **DCC Grant**.
3. Once it is ready, check that you can log in: `ssh <netid>@dcc-login.oit.duke.edu`.

The second step is easy to miss: without it the project does not give you cluster access. See Duke's [PhD allocation guide](https://dcc.duke.edu/help/Phdstudentaccess/).

> ##### Before November 20
>
> Claim your allocation by **November 13** and test your login, so there is time to fix problems before the session. Please bring a laptop with Globus Connect Personal installed (see below).
{: .block-tip }

> ##### If you cannot log in
>
> Allow some time for provisioning after adding the DCC Grant, and make sure Duo works at [Duke MFA help](https://idms-mfa.oit.duke.edu/mfa/help). If it still fails, email [rescomputing@duke.edu](mailto:rescomputing@duke.edu) with the command you ran and its full output.
{: .block-warning }

## Move your files

[Globus](https://app.globus.org) is the easiest way to move files between your computer and the DCC.

1. Install **Globus Connect Personal** and log in at [app.globus.org](https://app.globus.org) with your Duke account.
2. In the File Manager, set one panel to **Duke Compute Cluster (DCC) Data Transfer Node** at `/hpc/dctrl/<netid>/`.
3. Set the other panel to your own computer.
4. Select files and click **Start**.

For the Pro-Seminar, download the demo folder `proseminar` (linked in the session email) and transfer it this way, so it sits at `/hpc/dctrl/<netid>/proseminar` with `Data/` and `Codes/` inside.

### Where things live

| Location               | Size              | Use it for                                     | Kept                         |
| :--------------------- | :---------------- | :--------------------------------------------- | :--------------------------- |
| `/hpc/home/<netid>`    | 25 GB             | Scripts, settings, environment setup           | While your NetID is active   |
| `/hpc/dctrl/<netid>`   | 500 GB            | Your PhD allocation: data and code             | Persistent, no backups       |
| `/hpc/group/<lab>`     | 1 TB, shared      | A lab's shared data, if your advisor has a group | Persistent, 7-day snapshots  |
| `/work/<netid>`        | Large, shared     | Big data sets and intermediate results         | **Purged after 75 days**     |

Treat `/work` as scratch: anything older than 75 days is deleted automatically. Keep code and anything you cannot afford to lose elsewhere. See Duke's [storage guide](https://dcc.duke.edu/storage/) for details.

## Run your first job

### Point your code at the cluster

Your code usually runs unchanged. Only the file paths need to point to the DCC instead of your laptop:

```r
acs <- read.csv("/hpc/dctrl/<netid>/proseminar/Data/demoACS.csv")
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
cd /hpc/dctrl/<netid>/proseminar/Codes
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
acs  <- read.csv("/hpc/dctrl/<netid>/proseminar/Data/demoACS.csv")
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

## Work with an AI agent

Coding agents such as [Claude Code](https://www.claude.com/product/claude-code) run on your laptop and can run commands on the DCC for you over SSH: check your queue, read a log, draft a job script, submit it once you approve. Duke supports this with a special SSH route that sends the agent's commands to a small job on a compute node instead of the shared login node. This section follows Duke's [AI agent guide](https://dcc.duke.edu/dcc/ai-access/).

<figure class="flow">
<svg viewBox="0 0 720 130" role="img" aria-label="The agent on your laptop connects with ssh dcc-agent; the login node only passes the connection through to a small Slurm job on a compute node, where commands run.">
<rect x="1" y="25" width="190" height="76" rx="8"/>
<text x="96" y="58" class="t">Your laptop</text>
<text x="96" y="80" class="s">Claude Code</text>
<rect x="265" y="25" width="190" height="76" rx="8"/>
<text x="360" y="58" class="t">Login node</text>
<text x="360" y="80" class="s">passes through only</text>
<rect x="529" y="25" width="190" height="76" rx="8"/>
<text x="624" y="58" class="t">Compute node</text>
<text x="624" y="80" class="s">job agent-&lt;netid&gt;</text>
<line x1="195" y1="52" x2="259" y2="52" class="a" marker-end="url(#flow-arrow)"/>
<text x="228" y="42" class="l">ssh</text>
<line x1="459" y1="52" x2="523" y2="52" class="a" marker-end="url(#flow-arrow)"/>
<text x="492" y="42" class="l">proxy</text>
<text x="360" y="125" class="s">Your commands run on the compute node, never on the shared login node.</text>
</svg>
</figure>

> ##### Read the rules first
>
> You are responsible for everything an agent does under your NetID. Duke's [AI use policy](https://dcc.duke.edu/about/ai-policy/) asks you to keep a human in the loop:
>
> - Keep approval prompts on. Do not use `--dangerously-skip-permissions` or any "approve everything" mode.
> - Never give an agent your password, Duo codes, or SSH private key.
> - Do not let an agent read restricted data, such as health records, student records, or anything under a data use agreement, unless that agreement allows it.
{: .block-danger }

### Step 1: Set up an SSH key

An SSH key lets your laptop log in without typing your password each time. On your laptop, create one and protect it with a passphrase:

```bash
ssh-keygen -t ed25519 -C "<netid>@duke.edu"
cat ~/.ssh/id_ed25519.pub
```

Copy the line that `cat` prints, which is your public key. Paste it at Duke's [account self-service](https://idms-web-selfservice.oit.duke.edu/advanced) under **Manage Your Public SSH Keys**. Then check that `ssh <netid>@dcc-login.oit.duke.edu` asks for your key's passphrase instead of your Duke password.

### Step 2: Add a `dcc-agent` connection

Create a folder for shared connections:

```bash
mkdir -p ~/.ssh/sockets && chmod 700 ~/.ssh/sockets
```

Then add this block to `~/.ssh/config` on your laptop, with your NetID in place of `<netid>`:

```
Host dcc-agent
    User <netid>
    ProxyCommand ssh -o StrictHostKeyChecking=accept-new %r@dcc-login.oit.duke.edu bash /usr/local/bin/dcc-ssh-proxy.sh --name agent
    StrictHostKeyChecking accept-new
    ServerAliveInterval 30
    ControlMaster auto
    ControlPersist 30m
    ControlPath ~/.ssh/sockets/%r@%h-%p
```

| Line             | Meaning                                                                                                       |
| :--------------- | :------------------------------------------------------------------------------------------------------------ |
| `ProxyCommand`   | Duke's script starts a small job (2 CPUs, 4 GB, up to 8 hours) and forwards the connection to it              |
| `--name agent`   | The job's name. All sessions that use `dcc-agent` share this one job                                         |
| `ControlMaster`, `ControlPersist` | Reuse one login for 30 minutes, so you are not asked to authenticate for every command       |

Test it. The answer should be a compute node's name, not `dcc-login`:

```bash
ssh dcc-agent hostname
```

The first connection can take a minute while the job starts. For GPU work, add a second block named `dcc-agent-gpu` with `--name agent-gpu --partition gpu-common --gres gpu:1` at the end of its `ProxyCommand` line. On Windows, set this up inside [WSL](https://learn.microsoft.com/en-us/windows/wsl/install), since Windows' own SSH does not support shared connections.

### Step 3: Tell the agent the rules

Agents read a plain-text instruction file before they start. For Claude Code, create `CLAUDE.md` in your project folder on your laptop:

```markdown
# Duke Compute Cluster

- Run every DCC command as `ssh dcc-agent '<command>'`
  (`ssh dcc-agent-gpu` for GPU work). Never connect to the login node directly.
- My code and data are in /hpc/dctrl/<netid>. Scratch files go in /work/<netid>.
- Heavy or long work goes in a job script submitted with sbatch, not in this session.
- Show me any job script before submitting it.
- Ask before deleting files, cancelling jobs with scancel, or submitting more than 10 jobs.
```

### Step 4: Work with it

Open Claude Code in your project folder and ask in plain language:

- "Check my jobs on the DCC and tell me why the pending ones are waiting."
- "Write a job array script that runs `boot.R` 100 times, at most 20 at once. Show it to me before submitting."
- "Read the logs in `logs/` and tell me which tasks failed and why."

Each time the agent wants to run a command, it shows you the exact `ssh dcc-agent ...` line and waits for approval. Read it before you say yes. This is also a good way to learn: the agent's commands are the same ones in this guide.

The agent's job appears in `squeue --me` as `agent-<netid>`. It ends on its own about 15 minutes after you stop using it, and a new one starts when you reconnect.

Duke also allows a second setup: start an [interactive session](#gpus-and-interactive-work) and launch the agent there. Only do this after the prompt shows a compute node's name, never on the login node.

## Get help

- Duke's [DCC user guide](https://dcc.duke.edu) covers everything here in more depth, including SSH keys, VS Code, and containers.
- Research Computing answers questions at [rescomputing@duke.edu](mailto:rescomputing@duke.edu).
- Pro-Seminar participants can reach me at [wenhao.jiang@duke.edu](mailto:wenhao.jiang@duke.edu).
