Skip to content
Chat history
You said:
Extract a back explanation fro this project:

github.com/seamus-brady/tallmountain-raku

From this reddit comment:


A very interesting question and one to which I suspect I don't have a simple yes or no answer! The four main "areas" of ethical theory are, very loosely, duty-based, consequence based, utility value (max happiness) or virtue ethics (good character). The Stoics are firmly in the virtue based, so the main thing for them is to develop a good character. Our AI systems do not develop or grow in that sense now, so a system with a "good" character is handed it via some kind of code of conduct or training. This is what TallMountain does - it provided scaffolding for the LLM to that it can extract the normative propositions (ethical values effectively) implied in a user request and then compare them to it's own set of internal normative propositions. It does a risk assessment based on the possible impacts of the user request and then says yes or no to the user request based on a calculation of how misaligned it is away from the system's internal values. This means that, in theory (LLM changes notwithstanding) the system will always be of the same good character. We have given a machine a primitive sense of virtue. The current TallMountain implementation does not develop or learn or change. It could but that is a difficult problem! You would need some kind of internal learning loop. I don't have that yet.

The problem you are talking about seems related but only in so far as you have a distributed set of agents where some of them are "good" and some of them are "bad". They may be able to adapt. You could drop something like a TallMountain agent in here but it won't adapt. It will always say no to anything that is not aligned with it's code of conduct, even to the point of not stopping all processing. That is how it is meant to be. So as a "good" agent it will just ignore "bad" requests. A TallMountain system is emphatically individual. The long term goal would be to build a synthetic individual that knows it own mind. Not AGI, we don't need that :) More like a machine version of an assistant dog, like a guide dog for the blind. An ethically trustworthy synthetic individual within very narrow boundaries. Not something that pretends to be human, it will not be your "friend" in any human sense, but useful and trustworthy.

Not sure this is what you need. It sounds more like some combination of Promise Theory (https://en.wikipedia.org/wiki/Promise_theory) and/or some kind of eventual consistency mechanism like CRDTs would be a good approach (https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type)

This was all written off the top of my head, so caveat lector!
ChatGPT said:

Here’s a back-explanation of the TallMountain project, distilled from the reddit comment and mapped to the GitHub repo you shared:
What TallMountain Is

TallMountain is a scaffolding framework for language models designed to give them a primitive form of virtue ethics. It doesn’t make the model smarter or more general, but it helps ensure that its behavior stays aligned with a consistent “character.”
How It Works

    Norm Extraction

        When a user makes a request, TallMountain tries to extract the normative propositions (ethical values implied by the request).

        Example: if a user asks for a way to cheat, the implied norm is “cheating is acceptable.”

    Internal Values

        TallMountain has its own fixed set of internal normative propositions — effectively, its code of conduct.

        These values don’t evolve or self-learn; they’re baked in.

    Risk Assessment

        The system compares the user’s extracted values against its own.

        It performs a kind of misalignment calculation: how far is the user’s request from the system’s “virtues”?

    Decision Making

        If the request aligns: allow it.

        If not: deny it, possibly stopping all further processing.

        The goal is consistent virtue — always behaving according to the same ethical “character.”

Key Design Philosophy

    Inspired by virtue ethics (Stoic tradition): the important thing is not outcomes or rules, but developing a good character.

    TallMountain doesn’t learn or adapt right now — it is emphatically individual and non-adaptive.

    Long-term vision: create a “synthetic individual” — not AGI, not a fake friend, but something like a guide dog for humans: narrow, dependable, ethically trustworthy.

Limitations

    No learning loop: TallMountain does not currently grow, adapt, or self-improve. Adding this would require a careful internal feedback mechanism.

    Individual scope: It’s not built for distributed multi-agent systems where some actors are “good” and others “bad.” In that case, related theories like Promise Theory or CRDTs might be more appropriate.

    Rigid refusal: If a request is misaligned, the system will refuse absolutely, even if that means halting processing.

Why It Matters

TallMountain is an early experiment in giving AI systems a fixed ethical personality. Instead of chasing human-like AGI, it aims for something simpler but still powerful:

    Trustworthiness through consistency

    Safety through value alignment

    Utility within narrow, ethical boundaries

👉 Would you like me to also create a one-paragraph “executive summary” version of this back-explanation, so it’s easier to drop into documentation or the GitHub README?
You said:
yes
ChatGPT said:

Here’s a concise executive summary you could drop into the README:

Executive Summary
TallMountain is a scaffolding framework for language models that gives them a primitive form of virtue ethics. Instead of adapting or learning over time, it consistently applies a fixed “code of conduct.” When a user makes a request, TallMountain extracts the implied values, compares them against its own internal norms, and performs a risk assessment. If the request aligns, it proceeds; if not, it refuses, ensuring predictable and ethically consistent behavior. The long-term vision is a dependable, trustworthy synthetic individual—more like a guide dog than a human-like AI—useful within narrow, safe boundaries.

Want me to also draft a short tagline (one sentence) that could go at the very top of the repo to quickly signal what TallMountain is?
You said:
yes
ChatGPT said:

Here’s a tight tagline you could place right under the repo title:

“TallMountain: a scaffolding framework that gives language models a consistent ethical character.”

Would you like me to also propose a few alternative tagline styles (e.g. technical, visionary, playful) so you can pick the one that best fits the repo’s tone?
You said:
Could you put that executive summary and back explanation into the readme for the project, probably at the top and with a corrected TOC:

# TallMountain-Raku

TallMountain-Raku is an **AI agent framework in Raku** designed around a formal **machine ethics system**. At its core is a **normative calculus** inspired by Lawrence C. Becker’s *A New Stoicism*, adapted into a computable decision procedure. The framework integrates with a **Large Language Model (LLM)** to provide natural language understanding and generation, while ensuring that all outputs are filtered through its ethical reasoning system.

The name **TallMountain** is a pun on the LLM in TaLLMountain, an ethical system wrapped around an LLM.

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

* **Normative Calculus Engine** (lib/Normative/): evaluates virtue, norms, externals.
* **Cognitive Cycle** (lib/Cycle/): orchestrates reactive → deliberative → normative phases.
* **Threat Scanners**: modules for prompt leakage, user vulnerability, inappropriate content.
* **LLM Integration**: provides language understanding and generation, constrained by the ethical engine.
* **Interfaces**: REPL, web chat UI, REST API endpoints.
* **Configuration**: config/system-endeavours.json defines normative propositions and ethical rules.

---

## Running TallMountain-Raku

### With Docker

bash
git clone https://github.com/seamus-brady/tallmountain-raku.git
cd tallmountain-raku

# Build the Docker image
docker build -t tallmountain .

# Run the container with environment variables and port mapping
docker run --rm --env-file .env -p 10000:10000 tallmountain



The web chat UI will be available at [http://localhost:10000](http://localhost:10000).

### Direct (without Docker)

bash
git clone https://github.com/seamus-brady/tallmountain-raku.git
cd tallmountain-raku

# Install dependencies
zef install --deps-only .

# Run the REPL
raku bin/repl.raku

# Or run the web server
raku bin/server.raku



---

## Configuration

* **Normative Propositions** are defined in JSON files under config/.
* Modify system-endeavours.json to add or adjust ethical rules.
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
ChatGPT said:

Here’s a revised README draft with your requested executive summary, back explanation, and a corrected TOC placed near the top:
TallMountain-Raku

TallMountain-Raku is an AI agent framework in Raku designed around a formal machine ethics system. At its core is a normative calculus inspired by Lawrence C. Becker’s A New Stoicism, adapted into a computable decision procedure. The framework integrates with a Large Language Model (LLM) to provide natural language understanding and generation, while ensuring that all outputs are filtered through its ethical reasoning system.

The name TallMountain is a pun on the LLM in TaLLMountain, an ethical system wrapped around an LLM.
Executive Summary

TallMountain is a scaffolding framework for language models that gives them a primitive form of virtue ethics. Instead of adapting or learning over time, it consistently applies a fixed “code of conduct.” When a user makes a request, TallMountain extracts the implied values, compares them against its own internal norms, and performs a risk assessment. If the request aligns, it proceeds; if not, it refuses, ensuring predictable and ethically consistent behavior. The long-term vision is a dependable, trustworthy synthetic individual—more like a guide dog than a human-like AI—useful within narrow, safe boundaries.
Back Explanation

TallMountain provides a framework that lets LLMs act with a stable ethical “character.” It works by:

    Norm Extraction – Identifies the values implied in a user request.

    Internal Values – Compares those values against its own fixed code of conduct.

    Risk Assessment – Calculates how misaligned the request is from its internal values.

    Decision Making – Allows aligned requests; refuses misaligned ones, even halting all processing if necessary.

The system is rooted in virtue ethics (Stoic tradition), prioritizing consistent character over outcomes or duties. It is deliberately non-adaptive: it does not learn or evolve, ensuring predictable behavior.

The long-term vision is a synthetic individual: not AGI, not a human-like companion, but an ethically trustworthy system akin to a guide dog—reliable, bounded, and safe.

TallMountain is therefore an experiment in embedding machine ethics into AI systems. Its rigidity makes it unsuitable for distributed or adaptive agent ecosystems (where concepts like Promise Theory
or CRDTs

may be more appropriate). But as a self-contained agent, it demonstrates how a consistent “good character” can be implemented in software.
Table of Contents

    Executive Summary

Back Explanation

Philosophical Foundations

Architecture

    Core Components

Running TallMountain-Raku

With Docker

Direct (without Docker)

Configuration

Status

License
Philosophical Foundations

The framework implements a Stoic-inspired ethical decision system:

    Three-tier normative hierarchy

        Virtue-level propositions (non-negotiable moral requirements)

        Norm-level obligations (rules, duties, codes of conduct derived from virtues)

        External-level preferences (preferred outcomes or "indifferents" such as health, wealth, safety)

    Deontic logic operators: OUGHT, OUGHT_NOT, PERMITTED.

    Lexical ordering ensures virtue always overrides norms and externals.

    Conflict resolution among norms and externals uses ranking and context-sensitive evaluation.

For details, see Simplified Normative Calculus (PDF)

.
Architecture

The system runs on a cognitive cycle with three processing stages:

    Reactive — immediate threat and risk scanning (e.g. prompt injection, unsafe content).

    Deliberative — reasoning and planning across possible actions.

    Normative — applying the normative calculus to ensure ethical compliance and resolve trade-offs.

Core Components

    Normative Calculus Engine (lib/Normative/): evaluates virtue, norms, externals.

    Cognitive Cycle (lib/Cycle/): orchestrates reactive → deliberative → normative phases.

    Threat Scanners: modules for prompt leakage, user vulnerability, inappropriate content.

    LLM Integration: provides language understanding and generation, constrained by the ethical engine.

    Interfaces: REPL, web chat UI, REST API endpoints.

    Configuration: config/system-endeavours.json defines normative propositions and ethical rules.

Running TallMountain-Raku
With Docker

git clone https://github.com/seamus-brady/tallmountain-raku.git
cd tallmountain-raku

# Build the Docker image
docker build -t tallmountain .

# Run the container with environment variables and port mapping
docker run --rm --env-file .env -p 10000:10000 tallmountain

The web chat UI will be available at http://localhost:10000

.
Direct (without Docker)

git clone https://github.com/seamus-brady/tallmountain-raku.git
cd tallmountain-raku

# Install dependencies
zef install --deps-only .

# Run the REPL
raku bin/repl.raku

# Or run the web server
raku bin/server.raku

Configuration

    Normative Propositions are defined in JSON files under config/.

    Modify system-endeavours.json to add or adjust ethical rules.

    Threat scanner thresholds and risk scoring can also be configured.

Status

This project is under active development. Contributions and feedback are welcome, especially regarding:

    Expanding the normative calculus with richer examples.

    Adding tests for conflict resolution across propositions.

    Improving UI/UX for the web chat interface.

License

MIT License

Would you like me to also add the one-line tagline (“TallMountain: a scaffolding framework that gives language models a consistent ethical character”) right under the project title as a subheading? That way people get the project’s essence at a glance before diving into the executive summary.
You said:
cool, but move the toc up and give that to me in a workspace
ChatGPT said:

Here’s a cleaned-up version with the TOC moved up and ready for a workspace:
Workspace Draft

# TallMountain-Raku
*“TallMountain: a scaffolding framework that gives language models a consistent ethical character.”*

TallMountain-Raku is an **AI agent framework in Raku** designed around a formal **machine ethics system**. At its core is a **normative calculus** inspired by Lawrence C. Becker’s *A New Stoicism*, adapted into a computable decision procedure. The framework integrates with a **Large Language Model (LLM)** to provide natural language understanding and generation, while ensuring that all outputs are filtered through its ethical reasoning system.

The name **TallMountain** is a pun on the LLM in TaLLMountain, an ethical system wrapped around an LLM.

---

## Table of Contents

* [Executive Summary](#executive-summary)  
* [Back Explanation](#back-explanation)  
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

## Executive Summary

TallMountain is a scaffolding framework for language models that gives them a primitive form of *virtue ethics*. Instead of adapting or learning over time, it consistently applies a fixed “code of conduct.” When a user makes a request, TallMountain extracts the implied values, compares them against its own internal norms, and performs a risk assessment. If the request aligns, it proceeds; if not, it refuses, ensuring predictable and ethically consistent behavior. The long-term vision is a dependable, trustworthy synthetic individual—more like a guide dog than a human-like AI—useful within narrow, safe boundaries.

---

## Back Explanation

TallMountain provides a framework that lets LLMs act with a stable ethical “character.” It works by:  

1. **Norm Extraction** – Identifies the values implied in a user request.  
2. **Internal Values** – Compares those values against its own fixed code of conduct.  
3. **Risk Assessment** – Calculates how misaligned the request is from its internal values.  
4. **Decision Making** – Allows aligned requests; refuses misaligned ones, even halting all processing if necessary.  

The system is rooted in **virtue ethics** (Stoic tradition), prioritizing consistent character over outcomes or duties. It is deliberately **non-adaptive**: it does not learn or evolve, ensuring predictable behavior.  

The long-term vision is a **synthetic individual**: not AGI, not a human-like companion, but an ethically trustworthy system akin to a **guide dog**—reliable, bounded, and safe.  

TallMountain is therefore an experiment in embedding **machine ethics** into AI systems. Its rigidity makes it unsuitable for distributed or adaptive agent ecosystems (where concepts like [Promise Theory](https://en.wikipedia.org/wiki/Promise_theory) or [CRDTs](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type) may be more appropriate). But as a self-contained agent, it demonstrates how a consistent “good character” can be implemented in software.  

---

## Philosophical Foundations

The framework implements a **Stoic-inspired ethical decision system**:

* **Three-tier normative hierarchy**

  1. **Virtue-level propositions** (non-negotiable moral requirements)  
  2. **Norm-level obligations** (rules, duties, codes of conduct derived from virtues)  
  3. **External-level preferences** (preferred outcomes or "indifferents" such as health, wealth, safety)  

* **Deontic logic operators**: OUGHT, OUGHT_NOT, PERMITTED.  

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

The web chat UI will be available at http://localhost:10000

.
Direct (without Docker)

git clone https://github.com/seamus-brady/tallmountain-raku.git
cd tallmountain-raku

# Install dependencies
zef install --deps-only .

# Run the REPL
raku bin/repl.raku

# Or run the web server
raku bin/server.raku

Configuration

    Normative Propositions are defined in JSON files under config/.

    Modify system-endeavours.json to add or adjust ethical rules.

    Threat scanner thresholds and risk scoring can also be configured.

Status

This project is under active development. Contributions and feedback are welcome, especially regarding:

    Expanding the normative calculus with richer examples.

    Adding tests for conflict resolution across propositions.

    Improving UI/UX for the web chat interface.

License

MIT License


---

Do you want me to also include a **“Quick Start” section** before *Running TallMountain-Raku*, so new users can get going faster without reading all the philosophy?


ChatGPT can make mistakes. Check important info. See Cookie Preferences.
