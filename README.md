# Pi Devcontainer

A devcontainer with a small, **pre-configured [Pi](https://pi.dev) agent** that lets you talk to **Claude, Gemini, or Grok** by exporting a single API key. It mirrors the layout of [`hello-codex`](https://github.com/forjor/hello-codex) and [`hello-open-code`](https://github.com/forjor/hello-open-code): launch the container, export a provider key, and run `make hello` to have the agent introduce itself — read-only.

## What's inside

| Tool | Version |
|------|---------|
| Ubuntu | 24.04 |
| Node.js | LTS (Pi needs ≥ 22.19) |
| Git | latest |
| Zsh | latest |
| make | latest |
| Pi (`@earendil-works/pi-coding-agent`) | latest |

Pi is installed from npm (`npm install -g --ignore-scripts @earendil-works/pi-coding-agent`). Your host `~/.pi` is bind-mounted into the container, so any `pi` credentials or config carry in. The three provider keys are also passed through from your host environment if they're already exported there.

## The pre-configured agent

This repo ships a project-level Pi configuration under [`.pi/`](.pi/):

- **`.pi/SYSTEM.md`** — defines the agent persona, **Pi-Hello**: a friendly, read-only hello-world agent that knows how to identify itself.
- **`.pi/settings.json`** — sets the default toolset to read-only (`read`, `grep`, `find`, `ls`), a low thinking level, and a quiet startup.

Because project config is trust-gated, `make hello` passes `--approve` so the agent loads in non-interactive mode. (When you run `pi` interactively the first time, Pi will ask you to trust the project.)

## Quick start

Inside the container, export **one** provider key and run `make hello`:

```bash
export ANTHROPIC_API_KEY=sk-ant-...   # Claude
# or
export GEMINI_API_KEY=...             # Gemini
# or
export XAI_API_KEY=...                # Grok

make hello
```

`make hello` runs:

```bash
pi --print --approve --no-session --provider <provider> --model <model> \
   --tools read,grep,find,ls "identify yourself and say hello"
```

- `--print` runs once and exits (non-interactive).
- `--tools read,grep,find,ls` makes the run **read-only** — no write, edit, or shell tools.
- `--approve` trusts the `.pi/` agent config for this run; `--no-session` keeps it ephemeral.
- The provider and a default model are auto-selected from whichever key you exported (first match wins: Claude → Gemini → Grok).

### Provider keys and default models

| Provider | Environment variable | `--provider` | Default model pattern (override with `MODEL=`) |
|----------|----------------------|--------------|-----------------------------------------------|
| Anthropic (Claude) | `ANTHROPIC_API_KEY` | `anthropic` | `sonnet` |
| Google (Gemini) | `GEMINI_API_KEY` | `google` | `gemini` |
| xAI (Grok) | `XAI_API_KEY` | `xai` | `grok` |

Model patterns are fuzzy — Pi resolves them against the live model catalog for the authenticated provider, so they keep working as model names change. Pin an exact one any time with `MODEL=`.

### Overrides

```bash
# Pin a specific model within the detected provider
make hello MODEL=claude-sonnet-4-5

# Use a different provider entirely (clear PROVIDER; that provider's key must be set)
make hello MODEL=openai/gpt-5 PROVIDER=

# Change the prompt
make hello PROMPT="who are you and what can you do?"
```

---

## Option A — VSCode

1. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
2. Open this folder in VSCode.
3. When prompted, click **Reopen in Container** (or run `Dev Containers: Reopen in Container` from the Command Palette).

Then export a key and run `make hello`.

---

## Option B — One-shot CLI script (macOS)

Make the script executable once:

```bash
chmod +x start.sh
```

Then run it from the project root any time:

```bash
./start.sh
```

The script will:
1. Verify Docker is installed and running.
2. Install the `devcontainer` CLI via npm if missing.
3. Create `~/.pi` on your host if it doesn't already exist.
4. Run `devcontainer up` to build and start the container.
5. Drop you into a `zsh` shell inside the container.

### Prerequisites

- [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/)
- [Node.js](https://nodejs.org) (only needed if the devcontainer CLI isn't already installed)

---

## Option C — devcontainer CLI directly

```bash
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . zsh
```

---

## Cleaning up

```bash
./clean.sh            # remove this project's devcontainer containers + image
./clean.sh --rebuild  # remove, then rebuild and reconnect
```
