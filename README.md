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

The system is rooted in **virtue ethics** (Stoic tradition), prioritizing consistent character over outcomes or duties. 

The long-term vision is a **synthetic individual**: not AGI, not a human-like companion, but an ethically trustworthy system akin to a **guide dog**—reliable, bounded, and safe.  

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
