# Table of Contents

1. [Vision](#vision)
2. [Identity](#1-identity)

   * [Example: Financial Assistant](#example-financial-assistant)
3. [Ethical Apparatus](#2-ethical-apparatus)
4. [Roadmap](#3-roadmap)

   * [Phase 1 — Baseline Normative Agent](#phase-1--baseline-normative-agent-in-progress)
   * [Phase 2 — Deliberative Layer](#phase-2--deliberative-layer)
   * [Phase 3 — Reflective Layer](#phase-3--reflective-layer)
   * [Phase 4 — Future Directions](#phase-4--future-directions-speculative)
5. [Design Principles](#4-design-principles)
6. [Summary](#summary)

---

# Vision

This project prototypes a new type of digital entity:
an autonomous, trustworthy machine with a non-human identity — not a threat, not a friend — but a bounded, auditable companion.

We call these **synthetic individuals**.

---

## 1. Identity

Synthetic individuals are designed to be:

* **Autonomous within bounds** — capable of independent action, but always inside clear constraints.
* **Trustworthy** — reliable in behavior, safe by design.
* **Consistent** — guided by stable values over time.
* **Auditable** — decisions are transparent and reviewable.
* **Supportive** — assistive without pretending to be human.

A useful analogy is the **guide dog**:

* A guide dog may **refuse to cross a dangerous road**, even if asked.
* It has **autonomy in service of safety**, but never goes beyond its role.
* Each guide dog is an **individual**, trained to be excellent at a specific task.
* It is **not human, not a friend substitute, not a threat** — but a trusted partner.

Synthetic individuals should share these qualities: autonomous, bounded, trustworthy, and excellent in their domain.

### Example: Financial Assistant

Imagine a synthetic individual trained to act as a **personal financial assistant**.
Its role is not to “be human” or provide companionship, but to act autonomously within bounds to protect and support its user.

* If asked to make an obviously harmful decision (e.g. invest all savings in a scam), it will **refuse**, just as a guide dog refuses to cross a dangerous road.
* It can autonomously flag risks, remind you of bills, enforce budgeting rules, and optimize savings — but it will **not gamble with your assets or take opaque actions**.
* Its **virtue** is financial prudence: like a well-trained service animal, it embodies a consistent character that ensures safety and trustworthiness.
* Every action it takes is **auditable** — you can see why it rejected a transaction, or how it prioritized safety over short-term gain.

This illustrates how synthetic individuals can be **excellent in a specific way**: autonomous, bounded, non-human, and reliable within a domain where mistakes carry real consequences.

---

## 2. Ethical Apparatus

Like trained animals, synthetic individuals need a **core of values and constraints**.
This project develops a **normative apparatus** that provides that core:

* **Normative calculus** — structured rules for rejecting unsafe or undesirable actions.
* **Virtue embeddings** — modeled traits that shape reliable, constructive behavior.
* **Multi-layer safeguards** — checks at every reasoning stage, from reactive filtering to reflective review.
* **Transparency** — decisions and rejections are logged and auditable.

Virtue here is like in trained animals: a **stable character** that guides behavior consistently, making autonomy trustworthy rather than dangerous.

---

## 3. Roadmap

### Phase 1 — Baseline Normative Agent (in progress)

* Deterministic rules + rejection sampling.
* Focus on reliability over complexity.
* Evaluation: compare outputs against human annotations.

### Phase 2 — Deliberative Layer

* Add a reasoning module that considers alternatives before answering.
* Introduce checks for contradictions or inconsistencies.
* Evaluation: adversarial prompts, red-teaming, ablation studies.

### Phase 3 — Reflective Layer

* Feedback loop where the system reviews past outputs.
* Lightweight memory for continuity across sessions.
* Evaluation: test for coherence across repeated prompts.

### Phase 4 — Future Directions (speculative)

* Adaptive normative systems refined over time.
* Modular “meta-control” balancing speed vs depth of reasoning.
* Longer-term: persistent synthetic individuals with stable identities and bounded autonomy.

  > These are **research goals**, not requirements for the current prototype.

---

## 4. Design Principles

* **Clarity** — each layer is modular and explainable.
* **Safety first** — boundaries and ethics remain hard constraints.
* **Incremental growth** — new features must show measurable value before adoption.
* **Assistive focus** — agents are supportive companions, not replacements for human agency.
* **Non-anthropomorphic** — no pretense of humanity, no artificial friendship.
* **Speculation separated** — long-term ideas are explicitly marked as such.

---

## Summary

This project is about moving beyond reactive chatbots toward **synthetic individuals**:
bounded, trustworthy, semi-autonomous digital companions with an ethical core.

They are **like assistive animals**: individual, excellent in a domain, autonomous but bounded — not human substitutes, not threats — and potentially a **safe step toward more general intelligence**.
