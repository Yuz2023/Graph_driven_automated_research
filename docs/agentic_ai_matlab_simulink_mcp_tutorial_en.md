# Let AI Operate MATLAB/Simulink for You: A Beginner-Friendly Tutorial

## What is this tutorial for?

Once set up, you can talk to an AI (like Claude Code) in plain language:

> "Build a PI controller model for me and run a step response."

The AI will actually build the model, wire up the blocks, and run the simulation in Simulink on your computer — you can watch it happen live in your MATLAB window.

## First, understand one thing: how does the AI reach your MATLAB?

The AI itself is like a **very smart intern with no hands** — it can think and write code, but it cannot touch the MATLAB running on your computer. So we need a **messenger** in the middle.

The whole system has just three players:

```
   AI (smart, no hands)        Messenger (small program)      MATLAB (does the work)
  ┌───────────────┐           ┌───────────────┐           ┌───────────────┐
  │  Claude Code  │ ←───────→ │  MCP server   │ ←───────→ │ MATLAB desktop │
  │               │   talks   │               │  relays   │  + Simulink   │
  └───────────────┘           └───────────────┘           └───────────────┘
```

So what is **MCP**, the term you keep hearing? It's simply the **agreed-upon language format** between the AI and the messenger — short for Model Context Protocol. You don't need to understand its internals, just like you don't need to understand network protocols to use WhatsApp. "MCP server = the messenger program" is all you need to know.

One more key point — **this is where most people trip up**:

> The messenger **will not open MATLAB for you**. You must open MATLAB yourself, and have MATLAB "raise its hand" to announce "I'm here" before the messenger can find it. How to do that is covered in Step 3.

## Four things to install

| Item | What it is | How often |
|------|-----------|-----------|
| ① The manual | A code repository (simulink-agentic-toolkit) that teaches the AI how to work with Simulink properly | Once |
| ② The messenger | A small program (matlab-mcp-core-server) | Once |
| ③ MATLAB's "ears" | A MATLAB add-on (.mltbx file) that lets MATLAB hear the messenger | Once per MATLAB version |
| ④ The AI's "contact card" | A config entry telling the AI "where the messenger is and how to start it" | Once |

Good news: ②③④ can all be installed by the AI itself (Step 2). You only need to handle ① and the second half of ③ by hand.

---

## Before you start, make sure you have

- [ ] **MATLAB R2023a or newer**, with **Simulink** installed (to check your version: type `ver` in the MATLAB command window)
- [ ] **Claude Code** installed and working (typing `claude` in a terminal should launch it)
- [ ] **Git** (typing `git --version` in a terminal should print something)

---

## Step 1: Download the "manual"

Open a terminal (on Mac, that's the "Terminal" app) and paste these lines one by one:

```bash
mkdir -p ~/Projects/Tools
cd ~/Projects/Tools
git clone https://github.com/matlab/simulink-agentic-toolkit.git
```

What these three lines do: create a folder for tools → go into it → download the official manual.

> ⚠️ Any location works, but **once it's there, don't move it** — the configuration created later remembers this path, and moving it means reinstalling. So don't put it on your Desktop or in your Downloads folder.

## Step 2: Let the AI install the rest

Go into the folder you just downloaded and launch Claude Code:

```bash
cd ~/Projects/Tools/simulink-agentic-toolkit
claude
```

Then type this sentence into the chat, exactly as is:

```
Set up the Simulink Agentic Toolkit
```

The AI will take it from there: find MATLAB on your computer → download the messenger program → download MATLAB's "ears" add-on → add the messenger to its own contact list. Before touching anything it will show you its plan (e.g., "I found R2026a — use this one?"). Just read and confirm; usually you simply agree.

When it's done, the AI will remind you to do one thing inside MATLAB — that's Step 3 below.

## Step 3: Two things on the MATLAB side (the step people miss most!)

**Thing ①: Give MATLAB its "ears" (only needed once)**

Open MATLAB and run this in the command window (replace `<your-username>` with yours, e.g. `/Users/johnsmith/...`):

```matlab
matlab.addons.install("/Users/<your-username>/.local/share/MATLABMCPCoreServerToolkit.mltbx")
```

This installs a MATLAB add-on that makes MATLAB "findable" by the messenger. Once installed, it sticks permanently (unless you upgrade to a new MATLAB release later — then install it once more).

**Thing ②: Have MATLAB "raise its hand" (every time you open MATLAB)**

Still in the MATLAB command window, run:

```matlab
addpath("/Users/<your-username>/Projects/Tools/simulink-agentic-toolkit")
satk_initialize
```

Meaning: tell MATLAB where the manual is → raise its hand and announce "I'm online, ready to relay messages."

> 💡 **Tired of typing this every time?** Put those two lines into MATLAB's `startup.m` file (a script MATLAB runs automatically at every launch), and MATLAB will report in by itself from then on. If the file doesn't exist, create it — see the [MATLAB documentation](https://www.mathworks.com/help/matlab/ref/startup.html).

> ⚠️ **Order matters**: the AI checks "has MATLAB reported in?" only **once, at the moment it starts**. So the correct order is — open MATLAB and report in **first**, open the AI **second**. If you did it backwards (AI first), no panic: just close the AI session and open a new one.

## Step 4: Test the connection

With MATLAB open (and reported in), start a new Claude Code session in any folder and ask:

```
What version of Simulink is running?
```

If the AI answers with a Simulink version number — congratulations, the whole chain works! 🎉

Now a more realistic test. Open a built-in aircraft model in MATLAB:

```matlab
open_system("f14")
```

Then ask the AI: "Give me an overview of the currently open Simulink model." It should read the model structure and explain it to you.

## Step 5: Put the AI to work

You can now just say what you want, for example:

- "Read the f14 model and explain how the pitch control loop works"
- "Build a first-order plant with a PI controller and run a step response"
- "Add a saturation block after the controller output, limits ±10"
- "List the parameters of every Gain block in this model"

The AI will call its tools to read models, edit them, and run simulations — changes appear live in your Simulink window.

---

## Something went wrong? Look it up here

**Q: The AI says it can't connect to MATLAB / connection error?**
Most common cause: MATLAB isn't open, or it's open but forgot to "report in." Run Thing ② from Step 3 inside MATLAB, then **start a fresh AI session** and try again.

**Q: MATLAB says `satk_initialize` or `shareMATLABSession` is an undefined function?**
The former: the `addpath` line wasn't run or has a wrong path. The latter: the "ears" add-on isn't installed — go back to Thing ① of Step 3.

**Q: The AI doesn't show any Simulink tools at all?**
The config was just written; the AI needs a **session restart** to see it. Run `claude mcp list` in a terminal — if `simulink` is in the list, the config is fine; just open a new session.

**Q: Mac pops up saying the downloaded program is untrusted and refuses to run it?**
Run this in a terminal to unblock it:
```bash
xattr -d com.apple.quarantine ~/.local/bin/matlab-mcp-core-server
```

**Q: It worked fine at install, then broke months later?**
The tooling probably updated. Go back to Step 2 and tell the AI "Set up the Simulink Agentic Toolkit" again — the setup is safe to re-run and will update everything and repair the config.

**Q: Want to fully inspect the installation state?**
Installation details are recorded in `~/.simulink-agentic-toolkit/config.json` — open it and check the paths.

---

## The daily routine, in one picture

```
After booting up:
  1. Open MATLAB (startup.m reports in automatically ✋)
  2. Open Claude Code
  3. Just say what you need: "Help me..."

That's it. Installing is one-time; using is every day.
```

---

# Advanced Section (optional reading)

> The following is for readers who want a manual installation or need deeper troubleshooting. If you just want to use the toolkit, you can stop reading here.

## Advanced A: Manual installation (without the automated setup)

Example: macOS Apple Silicon + Claude Code (for other platforms, swap in the matching binary name):

```bash
# 1. Download the MCP server binary (pick the asset for your platform:
#    maca64 / maci64 / glnxa64 / win64.exe)
mkdir -p ~/.local/bin ~/.local/share
TAG=$(curl -sL https://api.github.com/repos/matlab/matlab-mcp-core-server/releases/latest \
      | grep '"tag_name"' | head -1 | sed 's/.*"\(v[^"]*\)".*/\1/')
curl -sL -o ~/.local/bin/matlab-mcp-core-server \
  "https://github.com/matlab/matlab-mcp-core-server/releases/download/${TAG}/matlab-mcp-core-server-maca64"
chmod +x ~/.local/bin/matlab-mcp-core-server
xattr -d com.apple.quarantine ~/.local/bin/matlab-mcp-core-server 2>/dev/null

# 2. Download the MATLAB toolbox
curl -sL -o ~/.local/share/MATLABMCPCoreServerToolkit.mltbx \
  "https://github.com/matlab/matlab-mcp-core-server/releases/download/${TAG}/MATLABMCPCoreServerToolkit.mltbx"

# 3. Verify the binary
~/.local/bin/matlab-mcp-core-server --version
```

Then register it with Claude Code (globally, `-s user`):

```bash
claude mcp add simulink -s user -- \
  ~/.local/bin/matlab-mcp-core-server \
  --matlab-session-mode=existing \
  --extension-file=$HOME/Projects/Tools/simulink-agentic-toolkit/tools/tools.json \
  --matlab-root=/Applications/MATLAB_R2026a.app
```

What the three arguments mean:

- `--matlab-session-mode=existing`: connect to an already-running shared MATLAB session (SATK always uses this mode)
- `--extension-file`: points to `tools/tools.json` inside the toolkit repo, which provides the Simulink-specific tools (the file stays in the repo — it is referenced, not copied)
- `--matlab-root`: the root directory of your MATLAB installation

The MATLAB-side configuration is exactly the same as Step 3 in the main tutorial.

## Advanced B: Technical troubleshooting table

| Symptom | Cause and fix |
|---------|---------------|
| No simulink tools visible in the agent | A **new agent session** is required after the config is written; run `claude mcp list` to confirm `simulink` is registered |
| Connection error / server can't reach MATLAB | MATLAB isn't running, or `satk_initialize` wasn't run. Run it in MATLAB first, then restart the agent |
| `shareMATLABSession` undefined | The mltbx toolbox isn't installed (or wasn't reinstalled after switching MATLAB versions). Re-run `matlab.addons.install(...)` |
| macOS says the binary is untrusted | Run `xattr -d com.apple.quarantine ~/.local/bin/matlab-mcp-core-server` |
| Diagnosing the server itself | Run it by hand: `~/.local/bin/matlab-mcp-core-server --matlab-session-mode=existing --extension-file=<toolkit>/tools/tools.json --matlab-root=<MATLAB_ROOT>` and read the first ~20 lines of output |
| Odd behavior after updating the toolkit | After `git pull`, re-run "Set up the Simulink Agentic Toolkit" — setup is re-runnable and will update the binary and config |

Installation state is recorded in `~/.simulink-agentic-toolkit/config.json` — check this file first when troubleshooting.

*Written against Simulink Agentic Toolkit 0.4.x + matlab-mcp-core-server v0.8.1 (July 2026).*
