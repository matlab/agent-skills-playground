# Embedded AI Deployment

A demo showing how a coding agent deploys AI models to embedded hardware using MATLAB&reg;, Simulink&reg;, and Embedded Coder&trade;. The agent walks the full lifecycle: model creation or import, verification, compression, system-level simulation, and C/C++ code generation for resource-constrained targets.

## What you'll do

You'll describe your embedded AI task to the agent. It detects your installed toolboxes, gathers requirements (model, hardware target, constraints), selects a workflow pattern, and guides you step by step through deployment.

## Workflow patterns

The skill routes to one of two patterns based on model size and target hardware:

| Pattern | Model origin | Target hardware | Use when |
|---|---|---|---|
| **1** | MATLAB-native or 3P imported as `dlnetwork` | Cortex-M, Cortex-A/R, DSP | Small models (< 500 KB) on lean hardware. Adds MathWorks compression (pruning, projection, quantization), Simulink integration, weight inspection, fixed-point codegen. |
| **2** | PyTorch (`.pt2`) or LiteRT (`.tflite`) | Cortex-A/R, x86, GPU | Large models (> 1 MB) on high-performance hardware. Generates C directly from a PyTorch model without the Deep Learning Toolbox layer system. |

## Skills included

| Skill | Role |
|---|---|
| [`embedded-ai-deployment`](skills/embedded-ai-deployment/SKILL.md) | Router and decision tree. Detects the environment, gathers requirements, picks a pattern, and dispatches to the per-phase references under `references/`. |

The skill body is the router. The detailed per-phase instructions live in `references/shared/`, `references/pattern1/`, and `references/pattern2/`, loaded only when a phase needs them.

## Prerequisites

Requires **MATLAB R2026a or newer** with:

- MATLAB&reg;, Simulink&reg;
- Deep Learning Toolbox&trade;
- Statistics and Machine Learning Toolbox&trade;
- MATLAB Coder&trade;, Embedded Coder&trade;
- Fixed-Point Designer&trade; (for quantization)

Support packages, installed via Add-On Explorer as needed: Deep Learning Toolbox Converters for PyTorch&reg; / ONNX / TensorFlow&trade; models, Model Compression Library, Deep Learning Support from MATLAB Coder, MATLAB Coder Support Package for PyTorch and LiteRT Models (Pattern 2), Embedded Coder Support Package for ARM&reg; Cortex&reg;-M Processors (CMSIS-NN).

Third-party, for the PyTorch import/export workflows: Python&trade; 3.9+ with PyTorch&reg; 2.0 or newer.

Also install the [MATLAB Agentic Toolkit](https://github.com/matlab/matlab-agentic-toolkit) and [Simulink Agentic Toolkit](https://github.com/matlab/simulink-agentic-toolkit) so the agent can drive a live MATLAB and Simulink session.

## Setup

1. **Clone this repo** if you haven't already:
   ```bash
   git clone https://github.com/matlab/agent-skills-playground.git
   ```
2. **Open the demo folder** in your agent:
   - **Claude Code**: from a terminal, `cd` into `demos/embedded-ai-deployment/` and run `claude`. The agent picks up the `embedded-ai-deployment` skill in this folder's `skills/` directory.
   - **Codex**: install the repo-level copy from `skills/embedded-ai-deployment/` into your Codex user skills directory, then open this demo folder in Codex. The skill includes `agents/openai.yaml` metadata for Codex.
   - **Other agents**: point the agent at `demos/embedded-ai-deployment/skills/` per the agent's instructions for user-defined skills.

## Walkthrough

Start the conversation with the task you want to deploy:

> *I want to deploy a small keyword-spotting CNN to a Cortex-M4 and generate C code.*

The skill detects your toolboxes, asks about your model and hardware target, selects Pattern 1, and walks the phases: data preparation, training or import, compression, Simulink integration, and embedded code generation. For a larger model on a Cortex-A target, it routes to Pattern 2 and the direct PyTorch-to-C path instead.
