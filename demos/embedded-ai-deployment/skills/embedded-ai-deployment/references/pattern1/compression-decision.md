# Compression and Code Generation Decision Flow

Before applying any compression technique or generating code, ask the user a short
set of questions to choose the right path. Different deployment goals favor
different combinations of pruning, projection, quantization, and code replacement
libraries — there is no single optimal recipe.

Ask each question one at a time. For each option, present the resulting pathway
and what is supported in R2026a so the user can make an informed choice.

---

## Question 1 — Hardware target and Simulink availability

Combine hardware and toolchain into one question because they jointly determine
the available code-replacement libraries.

| Option | Pathway | What's supported (R2026a) |
|---|---|---|
| **ARM Cortex-M with Simulink** | `exportNetworkToSimulink` → `slbuild` with ARM Cortex-M CRL | CMSIS-NN INT8 block replacement: **Conv2D and FC only** (`arm_convolve_wrapper_s8`, `arm_fully_connected_s8`). CMSIS-DSP float32 matrix-multiply replacement (`mw_arm_mat_mult_f32`): FC, LSTM, GRU, BiLSTM. **No INT8 CMSIS kernel for LSTM/GRU** — those generate as plain fixed-point C when quantized. |
| **ARM Cortex-M without Simulink** | MATLAB Coder + `coder.DeepLearningConfig('cmsis-nn')` | INT8 via CMSIS-NN for FC; LSTM supported but computed in float32. ~1.3x speedup typical (vs ~2.8x for the Simulink path). |
| **ARM Cortex-A** | MATLAB Coder + ARM Compute Library | Conv2D, FC, LSTM, GRU, BiLSTM all supported. Broader layer coverage than Cortex-M. |
| **Generic CPU / no acceleration library** | MATLAB Coder, generic C/C++ | All codegen-compatible layers supported, but no kernel-level acceleration. |
| **GPU / FPGA / DSP / NPU** | Out of scope for this skill | Refer to GPU Coder, Deep Learning HDL Toolbox, or vendor-specific tools. |

Auto-detect when possible: if Simulink is not on the toolbox list from
`detect_matlab_toolboxes`, present only the Cortex-M-without-Simulink option.

---

## Question 2 — Primary deployment goal

| Option | Recommended techniques | Caveats |
|---|---|---|
| **Reduce flash / ROM footprint** | Pruning + projection + quantization (combined) | Projection requires retraining. Up to ~77% combined savings. |
| **Reduce SRAM / runtime memory** | Pruning + quantization (skip projection) | Projection does not reduce activation memory. |
| **Lowest latency on target** | Hardware-dependent. **Cortex-M + CNN/FC**: INT8 + CMSIS-NN. **Cortex-M + LSTM/GRU**: float32 + CMSIS-DSP. | Quantizing an LSTM for Cortex-M shrinks flash but does **not** speed up inference — there is no INT8 CMSIS kernel for recurrent layers. |
| **Pure integer arithmetic required** (no FPU, MISRA-int) | Quantization is mandatory | LSTM + integer-only on Cortex-M generates plain fixed-point code; expect slower runtime than the float32+CMSIS-DSP path. |
| **Maximize accuracy (no compression)** | Skip compression, deploy float32 baseline | Use this when accuracy budget is tighter than the size budget. |

---

## Question 3 — Retraining tolerance

Skip this question when the agent already knows the dataset is unavailable
(MATLAB-trained workflows: training data is in scope; 3P import workflows:
already covered in Project Discovery).

| Option | Available techniques | Reason |
|---|---|---|
| **Yes — full retraining** | Pruning, projection, quantization | Pruning and projection both call `trainnet` after compression. |
| **Limited — light fine-tuning only** | Projection at conservative goal (≤ 10%) + quantization | Projection at 10% reduction often recovers accuracy with a few epochs; pruning typically needs more. |
| **No — post-training only** | Quantization only (calibration, no training) | Pruning and projection are off the table. |

---

## Optional follow-up — PIL hardware available?

Ask only if the user picked Cortex-M and has chosen quantization. Use this to
decide whether to offer a side-by-side library-free vs CMSIS comparison.

| Option | Agent's offer |
|---|---|
| **Yes — dev board on hand** | Generate both CMSIS and library-free versions; PIL on the target; compare latency and code size. |
| **No** | Default to CMSIS path. Library-free comparison without hardware would only show static code-size delta — published CMSIS-NN INT8 speedup is well established for Conv2D/FC, so on host alone there is no fair latency comparison. |

If the network is LSTM-heavy on Cortex-M with quantization chosen, flag the
specific tradeoff: CMSIS-NN provides no LSTM acceleration in the quantized path,
so library-free may be competitive there. PIL-only conclusion.

---

## Recipe matrix

After collecting answers, recommend one recipe and confirm before running. The
recipe should always be presented as a recommendation the user can override.

| Hardware | Goal | Retrain? | LSTM in net? | Recommended path |
|---|---|---|---|---|
| Cortex-M + Simulink | Flash | Yes | Yes | Project (LSTM+FC) → quantize → `exportNetworkToSimulink(qNet)` → `slbuild` with ARM Cortex-M CRL |
| Cortex-M + Simulink | Flash | No | Yes | Quantize → `exportNetworkToSimulink(qNet)` → `slbuild` (FC INT8 via CMSIS-NN, LSTM as plain fixed-point) |
| Cortex-M + Simulink | Latency | Any | Yes | **Skip quantization** for LSTM → float32 export → `slbuild` (LSTM gets `mw_arm_mat_mult_f32`) |
| Cortex-M + Simulink | Latency | Yes | No (CNN/FC only) | Quantize → export → `slbuild` (CMSIS-NN INT8, ~2.8x speedup) |
| Cortex-M + Simulink | Integer-only | Any | Any | Quantize → export → `slbuild` (FC INT8, LSTM fixed-point) |
| Cortex-M + Simulink | Max accuracy | Any | Any | No compression → float32 export → `slbuild` |
| Cortex-M, no Simulink | Latency | Any | No | Calibrate (no `quantize()`) → `coder.DeepLearningConfig('cmsis-nn')` → `codegen` (~1.3x) |
| Cortex-A | Flash | Yes | Any | Project → quantize → MATLAB Coder + ARM Compute Library |
| Generic CPU | Flash | Yes | Any | Project → quantize → MATLAB Coder |

---

## Caveats the agent should always state

- **CMSIS-NN does not provide INT8 kernels for LSTM, GRU, or BiLSTM in R2026a.**
  Quantizing a recurrent layer for Cortex-M reduces flash but generates plain
  fixed-point C, not an accelerated kernel. The float32 path with CMSIS-DSP
  matrix-multiply replacement (`mw_arm_mat_mult_f32`) is the documented
  acceleration for recurrent layers.
- **Pruning and projection require retraining**, so both are unavailable to
  users who answered "No" to retraining.
- **`exportNetworkToSimulink` accepts projected networks directly in R2026a.**
  Calling `unpackProjectedLayers` before export is no longer required.
- **For the direct MATLAB Coder path**, projected networks (`ProjectedLayer`,
  `lstmProjectedLayer`, `gruProjectedLayer`) are still NOT supported by
  `coder.loadDeepLearningNetwork` — call `unpackProjectedLayers` first for that
  path.
- **Try multiple paths and compare** when retraining is acceptable. For an
  LSTM-heavy flash-bound model, generate both project+quantize and quantize-only
  variants, measure flash and MAE, and let the user choose.

---

## When to load this file

Load `compression-decision.md` at the start of Phase 5 (Model Compression and
Quantization), before loading `compression.md`. Walk the user through the
questions, present the recommended path, and only then load `compression.md`
for the technique-level details.
