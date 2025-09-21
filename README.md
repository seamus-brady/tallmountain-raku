# TallMountain-Raku

TallMountain-Raku is an **AI agent framework in Raku** designed around a formal **machine ethics system**. At its core is a **normative calculus** inspired by Lawrence C. Becker’s *A New Stoicism*, adapted into a computable decision procedure. The framework integrates with a **Large Language Model (LLM)** to provide natural language understanding and generation, while ensuring that all outputs are filtered through its ethical reasoning system.

The name **TallMountain** comes from **TalLLMounttain**, symbolizing layered ethical reasoning and high-level guidance.

---

## Table of Contents

* [Philosophical Foundations](#philosophical-foundations)
* [Architecture](#architecture)

  * [Core Components](#core-components)
* [Running TallMountain-Raku](#running-tallmountain-raku)

  * [With Docker](#with-docker)
  * [Direct (without Docker)](#direct-without-docker)
* [Configuration](#configuration)
* [Status](#status)
* [License](#license)

---

## Philosophical Foundations

The framework implements a **Stoic-inspired ethical decision system**:

* **Three-tier normative hierarchy**

  1. **Virtue-level propositions** (non-negotiable moral requirements)
  2. **Norm-level obligations** (rules, duties, codes of conduct derived from virtues)
  3. **External-level preferences** (preferred outcomes or "indifferents" such as health, wealth, safety)

* **Deontic logic operators**: OUGHT, OUGHT\_NOT, PERMITTED.

* **Lexical ordering** ensures virtue always overrides norms and externals.

* **Conflict resolution** among norms and externals uses ranking and context-sensitive evaluation.

For details, see [Simplified Normative Calculus (PDF)](docs/Simplified_Normative_Calculus.pdf).

---

## Architecture

The system runs on a **cognitive cycle** with three processing stages:

1. **Reactive** — immediate threat and risk scanning (e.g. prompt injection, unsafe content).
2. **Deliberative** — reasoning and planning across possible actions.
3. **Normative** — applying the normative calculus to ensure ethical compliance and resolve trade-offs.

### Core Components

* **Normative Calculus Engine** (`lib/Normative/`): evaluates virtue, norms, externals.
* **Cognitive Cycle** (`lib/Cycle/`): orchestrates reactive → deliberative → normative phases.
* **Threat Scanners**: modules for prompt leakage, user vulnerability, inappropriate content.
* **LLM Integration**: provides language understanding and generation, constrained by the ethical engine.
* **Interfaces**: REPL, web chat UI, REST API endpoints.
* **Configuration**: `config/system-endeavours.json` defines normative propositions and ethical rules.

---

## Running TallMountain-Raku

### With Docker

```bash
git clone https://github.com/seamus-brady/tallmountain-raku.git
cd tallmountain-raku

# Build the Docker image
docker build -t tallmountain .

# Run the container with environment variables and port mapping
docker run --rm --env-file .env -p 10000:10000 tallmountain
```

The web chat UI will be available at [http://localhost:10000](http://localhost:10000).

### Direct (without Docker)

```bash
git clone https://github.com/seamus-brady/tallmountain-raku.git
cd tallmountain-raku

# Install dependencies
zef install --deps-only .

# Run the REPL
raku bin/repl.raku

# Or run the web server
raku bin/server.raku
```

---

## Configuration

* **Normative Propositions** are defined in JSON files under `config/`.
* Modify `system-endeavours.json` to add or adjust ethical rules.
* Threat scanner thresholds and risk scoring can also be configured.

---

## Status

This project is under active development. Contributions and feedback are welcome, especially regarding:

* Expanding the normative calculus with richer examples.
* Adding tests for conflict resolution across propositions.
* Improving UI/UX for the web chat interface.

---

## License

MIT License
