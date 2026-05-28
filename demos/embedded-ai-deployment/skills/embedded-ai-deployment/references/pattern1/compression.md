# Model Compression and Quantization

Patterns for compressing AI models for deployment on resource-constrained embedded hardware.
Compression reduces flash/RAM footprint for flash-constrained targets. Requires a **native
dlnetwork** (rebuilt with standard MATLAB layers) -- imported networks with custom layers
do not support dlquantizer or neuronPCA.

**Choose the compression path before applying techniques.** The right combination of
pruning, projection, and quantization depends on the user's hardware target, deployment
goal (flash vs SRAM vs latency vs accuracy), and retraining tolerance. Load
[`compression-decision.md`](compression-decision.md) at the start of Phase 5 and walk
the user through the question flow before applying any technique. Compression is not
mandatory and is not always optimal — for example, on ARM Cortex-M with a latency-bound
LSTM model, the float32 path with CMSIS-DSP matrix-multiply replacement outperforms a
quantized path because CMSIS-NN provides no INT8 kernels for recurrent layers.

**CRITICAL:** Do NOT implement pruning, projection, or quantization in custom MATLAB
code. Always use the official MathWorks functions listed below. These functions are
part of the Deep Learning Toolbox Model Compression Library and are designed for
correctness, code generation compatibility, and integration with the deployment toolchain.

## Official Compression Functions Reference

| Technique    | Key Functions                                                              |
|--------------|---------------------------------------------------------------------------|
| Pruning      | `compressNetworkUsingTaylorPruning`                                       |
| Projection   | `compressNetworkUsingProjection`, `neuronPCA`, `ProjectedLayer`, `lstmProjectedLayer`, `gruProjectedLayer` |
| Quantization | `prepareNetwork`, `dlquantizer`, `dlquantizationOptions`, `calibrate`, `quantize`, `validate`, `quantizationDetails`, `estimateNetworkMetrics`, `equalizeLayers` |

## Compression Techniques Overview

| Technique | Flash Savings | Accuracy Impact | Notes |
|-----------|-------------|-----------------|-------|
| **Combined (proj 10% + INT8)** | **77%+** | MAE ~1e-3 | Maximum flash reduction; requires retraining for projection |
| dlquantizer INT8 alone | ~75% | MAE < 1e-3 | Post-training; no retraining needed |
| neuronPCA projection (10%) | ~10% | MAE < 1e-4 | Conservative but safe; requires fine-tuning |
| Manual INT8 (per-matrix) | ~75% | MAE < 1e-3 | Fallback when dlquantizer fails |

**No single recommended default.** Pick the technique based on the goal collected via
[`compression-decision.md`](compression-decision.md):

- **Flash-bound + retraining OK** → combined projection + quantization
- **Flash-bound + no retraining** → quantization only
- **SRAM-bound** → pruning + quantization (projection does not reduce activation memory)
- **Latency-bound on Cortex-M with recurrent layers** → no quantization for the LSTM/GRU
  portion (CMSIS-NN has no INT8 recurrent kernels; float32 + CMSIS-DSP is faster)
- **Accuracy-first** → no compression

## Compression Paths by Model Type

| Model Type              | Compression Toolbox                            | Primary Techniques         |
|--------------------------|------------------------------------------------|----------------------------|
| `dlnetwork`             | Deep Learning Toolbox Model Compression Library | Quantization, Pruning, Projection |
| `fitcnet` / `fitrnet`  | Fixed-Point Designer                           | Fixed-point conversion     |

## Compression Order (Combined Pipeline)

For maximum compression, apply techniques in this order:

1. **Prune first** -- Remove unnecessary weights (structured weight removal)
2. **Project second** -- Reduce layer dimensions (neuronPCA)
3. **Quantize last** -- Convert to lower precision (INT8)

### When to Include Projection

`compressNetworkUsingProjection` and `neuronPCA` support `convolution1dLayer`
(since R2024b), `convolution2dLayer`, `fullyConnectedLayer`, `lstmLayer`, and
`gruLayer`. Include projection when:

- The user's goal is **flash reduction** (projection shrinks weight matrices), AND
- The user can tolerate **retraining / fine-tuning** (projection always requires it), AND
- The model contains at least one supported layer type, AND
- No projectable layer shares learnable parameters via weight tying (unsupported).

**Skip projection when:**

- The user's goal is latency (projection doesn't help; for Cortex-M LSTM/GRU,
  un-quantized float32 with CMSIS-DSP is the latency winner)
- The user's goal is SRAM reduction only (projection does not shrink activation memory)
- Retraining is not acceptable
- The model has no supported layer types
- The user is targeting maximum accuracy with no compression budget

### Explicit Accuracy Loss Reporting

After each compression step (and after the combined pipeline), **explicitly state the
accuracy lost**. Present a summary like:

```
Compression Results Summary
============================
Technique applied:     [Pruning / Projection / Quantization / Combined]
Mean Absolute Error:   X.XXe-Y (vs. uncompressed baseline)
Max Absolute Error:    X.XXe-Y
Accuracy drop:         X.XX% (for classification)
Flash savings:         XX.X%
Recommendation:        [PASS: within budget / FAIL: exceeds budget, iterate]
```

This report must appear after every compression step so the user can make an informed
go/no-go decision before proceeding.

---

## dlnetwork Compression: Deep Learning Toolbox Model Compression Library

This library is a **support package**, not a toolbox. It is NOT detected by
`detect_matlab_toolboxes`. To check availability, use:

```matlab
pkgs = matlabshared.supportpkg.getInstalled;
hasCompLib = false;
if ~isempty(pkgs)
    hasCompLib = any(contains({pkgs.Name}, "Model Compression"));
end
```

If not installed, **do not install on the user's behalf**. Direct the user to the
MATLAB Add-On Explorer to download it, then wait for confirmation before proceeding.

---

## Pruning (Structured Weight Removal)

Pruning removes the least important convolutional filters to reduce model size and
computation. Use `compressNetworkUsingTaylorPruning` — it handles the full iterative
workflow (score calculation, filter removal, fine-tuning) in a single call.

```matlab
% Define fine-tuning options for the pruning loop
options = trainingOptions("adam", ...
    MaxEpochs=10, ...
    MiniBatchSize=32, ...
    InitialLearnRate=1e-4, ...
    Verbose=false);

% Prune: remove 30% of learnable parameters
[prunedNet, info] = compressNetworkUsingTaylorPruning(net, XTrain, YTrain, ...
    "crossentropy", options, ...
    LearnablesReductionGoal=0.3, ...
    LearnablesReductionIncrement=0.05, ...
    Plots="pruning-progress");

% Inspect results
fprintf("Achieved reduction: %.1f%%\n", info.LearnablesReduction * 100);
fprintf("Pruned layers: %s\n", strjoin(info.PrunedLayerNames, ", "));
fprintf("Stop reason: %s\n", info.StopReason);
```

**Key parameters:**

| Parameter | Default | Description |
|-----------|---------|-------------|
| `LearnablesReductionGoal` | 1.0 | Target proportion of parameters to remove (0.3 = 30%) |
| `LearnablesReductionIncrement` | 0.05 | Proportion removed per iteration |
| `ValidationThreshold` | — | Stop early if validation metric exceeds threshold |
| `LayerNames` | all prunable | Restrict pruning to specific layers |
| `Plots` | "pruning-progress" | Visualization ("pruning-progress" or "none") |

**Notes:**
- Requires Deep Learning Toolbox Model Compression Library (support package)
- Operates on convolutional layers only; for FC/LSTM/GRU reduction (or for additional conv-layer reduction), use projection
- Output is a standard `dlnetwork` — no conversion step needed
- The function iteratively scores filters, removes lowest-scoring, and fine-tunes

---

## Projection (Layer Dimension Reduction)

Projection reduces the dimensionality of supported layers using principal component
analysis of neuron activations. Supported layers: `convolution1dLayer` (since R2024b),
`convolution2dLayer`, `fullyConnectedLayer`, `lstmLayer`, `gruLayer`. Layers that share
learnable parameters via weight tying are not supported.

```matlab
% Analyze neuron activations to determine projection ranks
stats = neuronPCA(net, XTrain);

% Compress the network using projection
projectedNet = compressNetworkUsingProjection(net, stats);
% Result contains ProjectedLayer, lstmProjectedLayer, or gruProjectedLayer
% depending on the original layer types

% Fine-tune after projection
options = trainingOptions("adam", ...
    MaxEpochs=20, ...
    MiniBatchSize=32, ...
    InitialLearnRate=1e-4, ...
    Verbose=false);

projectedNet = trainnet(XTrain, YTrain, projectedNet, "crossentropy", options);
```

**Projected layer types:**
- `ProjectedLayer` -- replaces fully connected and convolution (1D/2D) layers; the
  internal network contains either two `fullyConnectedLayer` objects, or two/three
  `convolution1dLayer` / `convolution2dLayer` objects, depending on the original
- `lstmProjectedLayer` -- for LSTM layers (common in time-series models)
- `gruProjectedLayer` -- for GRU layers

### neuronPCA Projection with minibatchqueue (Sequence Models)

For sequence models (LSTM/GRU), use minibatchqueue to feed calibration data.

**IMPORTANT:** When calibration data is a cell array of `[seqLen × features]` matrices
stored in an `arrayDatastore`, the `MiniBatchFcn` must produce a properly shaped dlarray.
For a network expecting `"CBT"` format (Channels × Batch × Time), each sequence must be
reshaped to `[C, 1, T]`:

```matlab
% Calibration data: cell array of [seqLen x numFeatures] single matrices
calibData = cell(numCalib, 1);
for i = 1:numCalib
    calibData{i} = single(randn(seqLen, numFeatures));
end
calibDs = arrayDatastore(calibData, OutputType="same");

% Create minibatchqueue — reshape each cell to [C, 1, T] with "CBT" format
numFeatures = 5;  % C
seqLen = 10;      % T
mbq = minibatchqueue(calibDs, ...
    MiniBatchSize=1, ...
    MiniBatchFormat="CBT", ...
    MiniBatchFcn=@(X) dlarray(reshape(X{1}', [numFeatures, 1, seqLen]), "CBT"));

% Create neuronPCA object
npca = neuronPCA(baseNet, mbq);

% Compress -- start conservative at 10%
[projNet, info] = compressNetworkUsingProjection(baseNet, npca, ...
    LearnablesReductionGoal=0.10);

% info struct fields: LearnablesReduction, ExplainedVariance, LayerNames
fprintf('Actual reduction: %.1f%%\n', info.LearnablesReduction * 100);
fprintf('Compressed layers: %s\n', strjoin(info.LayerNames, ', '));
```

**NOTE:** The older pattern `@(X) cat(3, X{:})` with `'MiniBatchFormat', 'TCB'` works
for batched sequences but NOT for single-sequence-per-minibatch with cell array datastores.
Always verify the dlarray shape matches what the network's input layer expects.

### Projection Limitations

- **10% is often the safe maximum.** Higher goals (70%, 90%) frequently fail accuracy budgets,
  especially for models with narrow output distributions.
- **Data distribution matters.** Models trained on narrow-range data (e.g., sensor readings
  clustered around a small range) are more sensitive to projection.
- **No synthetic fine-tuning shortcuts.** If the real data distribution is narrow, generating
  synthetic N(0,1) data for fine-tuning does not help -- it introduces out-of-distribution noise.
- **Test on real data.** Projection accuracy must be validated on the actual expected input
  distribution, not random data.

### Preparing Projected Networks for Code Generation

**CRITICAL:** `ProjectedLayer`, `lstmProjectedLayer`, and `gruProjectedLayer` are NOT supported
for code generation. Before saving a projected network for `coder.loadDeepLearningNetwork`,
call `unpackProjectedLayers` to replace projected layers with their equivalent standard layers:

```matlab
% Unpack projected layers for codegen compatibility
unpackedNet = unpackProjectedLayers(projectedNet);
save("deployableNet.mat", "unpackedNet");

% Alternative: set UnpackProjectedLayers=true during projection
projectedNet = compressNetworkUsingProjection(net, stats, ...
    UnpackProjectedLayers=true);
```

---

## Quantization (Float32 to Int8)

### Why Quantize?

Quantization reduces model size (4x for float32 → int8). On ARM Cortex-M targets with
the Embedded Coder Support Package for ARM Cortex-M Processors, INT8 quantized models
can use CMSIS-NN kernels for **`convolution2dLayer` and `fullyConnectedLayer` only**
(~2.8–3x speedup). LSTM, GRU, and BiLSTM layers in R2026a have **no INT8 CMSIS-NN
kernel** — they generate as plain fixed-point C when quantized, which can be slower
than the float32 + CMSIS-DSP `mw_arm_mat_mult_f32` path for recurrent layers. Choose
quantization based on the goal collected via [`compression-decision.md`](compression-decision.md).

**Two consumers of quantization data (do not confuse):**

| | Simulink path | MATLAB Coder CMSIS-NN path |
|---|---|---|
| Calls `quantize()`? | **Yes** — produces quantized dlnetwork for `exportNetworkToSimulink` | **No** — only `calibrate()`, calibration data passed to code generator |
| Requires Simulink? | Yes | No |
| Code gen mechanism | `slbuild` with CRL "ARM Cortex-M" | `codegen` with `coder.DeepLearningConfig('cmsis-nn')` |

See `codegen-embedded.md` for full CMSIS-NN deployment details.

### dlquantizer Supported Layer Types (R2026a, MATLAB execution environment)

Per the [Supported Layers for Quantization](https://www.mathworks.com/help/deeplearning/ug/supported-layers-for-quantization.html) doc:

| Layer Type | INT8 Quantization | Notes |
|-----------|------------------|-------|
| `fullyConnectedLayer` | **Supported** | Weights + activations quantized |
| `convolution1dLayer` | **Supported** | Weights + activations quantized |
| `convolution2dLayer` | **Supported** | Weights + activations quantized |
| `lstmLayer` | **Supported** | Quantized in MATLAB execution environment |
| `gruLayer` | **Supported** | Quantized in MATLAB execution environment |
| `lstmProjectedLayer` | **Supported** | Quantized in MATLAB execution environment |
| `gruProjectedLayer` | Not listed in support table | Treat as not supported until verified |
| `reluLayer` | **Supported** | Activation ranges quantized |
| `batchNormalizationLayer` | **Supported** | Folded into preceding layer |
| `selfAttentionLayer` | Not listed | Verify before assuming support |

**LSTM/GRU implication for Cortex-M deployment:** Although `dlquantizer` quantizes
LSTM/GRU layers in the MATLAB execution environment and `exportNetworkToSimulink`
preserves them as fixed-point blocks, **the ARM Cortex-M code replacement library
in R2026a does not provide INT8 CMSIS kernels for recurrent layers** (Conv2D and FC
have CMSIS-NN INT8 wrappers; LSTM/GRU/BiLSTM only have float32 CMSIS-DSP
matrix-multiply replacement). Quantizing an LSTM saves flash but does NOT speed up
inference on Cortex-M. If latency is the priority, keep recurrent layers in float32
and rely on CMSIS-DSP. See [`codegen-embedded.md`](codegen-embedded.md) for the
CMSIS support tables.

### INT8 Suitability Check

Before quantizing, check whether the model's output range is suitable for INT8.
INT8 quantization works well when the model's output range is narrow. It fails when
the output range is too wide for 256 INT8 levels.

| Output Range | INT8 Suitability | Example |
|-------------|-----------------|---------|
| 0 to 1 | Excellent | Probabilities, SOC estimation |
| 0 to 5 | Good | Advisory scores, small classifications |
| -10 to 10 | Acceptable | Bounded regression |
| 100 to 500 | **Poor** (~50%+ error) | Wide-range regression |

**Rule:** If `(max_output - min_output) / 256 > acceptable_error`, INT8 is inadequate.
Use FP32 or FP16 instead.

### Step 1: Prepare Calibration Data

```matlab
% Create calibration dataset of representative inputs
numCalibSamples = 100;

% For sequence models (LSTM): cell array of [T x F] sequences
calibData = cell(numCalibSamples, 1);
for i = 1:numCalibSamples
    calibData{i} = single(randn(seqLen, numFeatures));
end
ds = arrayDatastore(calibData, 'OutputType', 'same');

% For image models (CNN): 4D array [H x W x C x N]
calibImages = single(randn(224, 224, 3, numCalibSamples));
ds = arrayDatastore(calibImages, 'IterationDimension', 4);

% For feature models (MLP): 2D array [features x N]
calibFeatures = single(randn(numFeatures, numCalibSamples));
ds = arrayDatastore(calibFeatures, 'IterationDimension', 2);
```

### Step 2: Quantize

```matlab
% Step 2a: Prepare the network for quantization
% NOTE: prepareNetwork() works on standard dlnetwork objects only.
% Do NOT call prepareNetwork() on projected networks (containing
% ProjectedLayer, lstmProjectedLayer, or gruProjectedLayer) — it will fail.
% For projected networks, skip directly to creating the quantizer.
net = prepareNetwork(net);  % Only for non-projected networks

% Step 2b (optional): Equalize layer parameters for better quantization quality
net = equalizeLayers(net);

% Step 2c: Create quantizer object with options
qOpts = dlquantizationOptions(MetricFcn={@(x) myMetric(x)});  % Optional
quantObj = dlquantizer(net, ExecutionEnvironment="MATLAB");

% Step 2d: Calibrate with representative data
% For tabular data:
calData = arrayDatastore(XCal, IterationDimension=1);
calibrate(quantObj, calData);
% For sequence models: use formatted dlarray
% dlXCal = dlarray(cat(3, XCal{:}), "TCB");
% calibrate(quantObj, dlXCal);

% Step 2e: Quantize the network
quantizedNet = quantize(quantObj);

% CRITICAL: Save IMMEDIATELY after quantize() returns
% macOS R2026a has a background thread crash after quantize()
save('quantized_net.mat', 'quantizedNet', '-v7.3');
```

**Code generation from quantized networks — two paths:**

1. **Simulink path (SUPPORTED):** Pass the quantized network to
   `exportNetworkToSimulink(qNet)`. This creates a Simulink model with
   fixed-point data types (embedded.fi) pre-configured in block parameters.
   Embedded Coder then generates integer C code (int8/int16/int32) via `slbuild`.
   This is the recommended path for fixed-point embedded deployment.
   See: https://www.mathworks.com/help/deeplearning/ug/export-quantized-network-to-simulink.html

   For Cortex-M targets: configure the ARM Cortex-M CRL before `slbuild` to enable
   CMSIS-NN INT8 block replacement for **Conv2D and FC layers only**. LSTM/GRU/BiLSTM
   in the quantized model generate as plain fixed-point C — there is no CMSIS-NN
   recurrent-layer kernel in R2026a. See [`codegen-embedded.md`](codegen-embedded.md).

2. **Direct MATLAB Coder path (NOT SUPPORTED):** `coder.loadDeepLearningNetwork`
   does NOT accept the output of `quantize()`. For the direct codegen path
   (without Simulink), use the uncompressed, pruned, or unpacked projected
   network instead.

### Step 3: Validate

```matlab
% Validate using dlquantizer's built-in validation
valData = arrayDatastore(XVal, IterationDimension=1);
valResults = validate(quantObj, valData);
disp(valResults);

% Manual error comparison
errors = zeros(numTests, 1);
for i = 1:numTests
    x = dlarray(single(testInputs{i}), formatString);
    yBase = predict(baseNet, x);
    yQuant = predict(quantizedNet, x);
    errors(i) = max(abs(extractdata(yBase(:)) - extractdata(yQuant(:))));
end

mae = mean(errors);
fprintf('INT8 quantization: MAE=%.4e, MaxErr=%.4e\n', mae, max(errors));
assert(mae < 1e-3, 'Quantization error exceeds budget');
```

### Understanding Quantization Results

After calibration and validation:
- Compare accuracy/error before and after quantization
- Check per-layer quantization parameters (scale, zero-point)
- Identify layers with high quantization error

```matlab
% Get detailed quantization information from the quantized network (not quantObj)
qDetails = quantizationDetails(quantizedNet);
% qDetails struct fields:
%   IsQuantized          - logical
%   TargetLibrary        - string ("none" for MATLAB execution)
%   QuantizedLayerNames  - string array of quantized layer names
%   QuantizedLearnables  - table (Layer, Parameter, Value as embedded.fi)
fprintf('Quantized: %d, Layers: %s\n', qDetails.IsQuantized, ...
    strjoin(qDetails.QuantizedLayerNames, ', '));

% Estimate inference metrics for the quantized network
metrics = estimateNetworkMetrics(quantObj);
disp(metrics);
```

---

## Manual INT8 Quantization (Fallback)

When dlquantizer does not work (e.g., on networks with residual custom layers),
use per-matrix min-max scaling:

```matlab
learnables = net.Learnables;
for i = 1:height(learnables)
    W = learnables.Value{i};
    if isfloat(W) && numel(W) > 1
        absMax = max(abs(W(:)));
        scale = absMax / 127.0;
        Wq = int8(round(W / scale));
        % Dequantize back for inference (keeps the network runnable)
        learnables.Value{i} = single(Wq) * single(scale);
    end
end
net.Learnables = learnables;
```

---

## Combined Pipeline (Best Results: 77%+ Flash Savings)

Use the combined pipeline only when the user's goal is flash reduction AND retraining
is acceptable. Confirm via [`compression-decision.md`](compression-decision.md) before
applying it. The pipeline applies projection first (modest parameter reduction), then
INT8 quantization (aggressive bit-width reduction). Together they achieve 77%+ flash
savings.

### Full Combined Workflow: Prune -> Project -> Quantize

```matlab
%% Step 1: Prune (optional, if model has convolutional layers)
options = trainingOptions("adam", MaxEpochs=10, MiniBatchSize=32, ...
    InitialLearnRate=1e-4, Verbose=false);
[prunedNet, pruneInfo] = compressNetworkUsingTaylorPruning(net, ...
    XTrain, YTrain, "crossentropy", options, ...
    LearnablesReductionGoal=0.3);

%% Step 2: neuronPCA projection (conservative 10%)
mbq = minibatchqueue(calibDs, 'MiniBatchSize', 1, ...
    'MiniBatchFormat', 'TCB', 'MiniBatchFcn', @(X) cat(3, X{:}));
npca = neuronPCA(prunedNet, mbq, 'VerbosityLevel', 'off');
[projNet, projInfo] = compressNetworkUsingProjection(prunedNet, npca, ...
    'LearnablesReductionGoal', 0.10);

%% Step 3: INT8 quantization on the projected network
% NOTE: Do NOT call prepareNetwork() on projected networks — it fails.
% Create the quantizer directly on the projected network.
qObj = dlquantizer(projNet, 'ExecutionEnvironment', 'MATLAB');
calibrate(qObj, calibDs);
combinedNet = quantize(qObj);
save('combined_compressed.mat', 'combinedNet', '-v7.3');

% Deployment via Simulink (R2026a):
%   exportNetworkToSimulink(combinedNet, ...)  → slbuild with ARM Cortex-M CRL
% In R2026a, exportNetworkToSimulink accepts projected networks directly
% (unpackProjectedLayers is no longer required for the Simulink path).
%
% Deployment via direct MATLAB Coder:
%   NOT supported — coder.loadDeepLearningNetwork does not accept quantize() output.
%   For that path, use the uncompressed/pruned/unpacked-projected float32 network.

%% Verify combined accuracy
errors = [];
for i = 1:numTests
    x = dlarray(single(testInputs{i}), formatString);
    yBase = predict(net, x);
    yComp = predict(combinedNet, x);
    errors(end+1) = max(abs(extractdata(yBase(:)) - extractdata(yComp(:))));
end
fprintf('Combined: MAE=%.4e (budget: 1e-3)\n', mean(errors));

%% Calculate flash savings
baselineBytes = 0;
for i = 1:height(net.Learnables)
    baselineBytes = baselineBytes + numel(net.Learnables.Value{i}) * 4;  % float32 = 4 bytes
end
compressedBytes = 0;
for i = 1:height(combinedNet.Learnables)
    v = combinedNet.Learnables.Value{i};
    if isa(v, 'int8'), bpw = 1; else, bpw = 4; end
    compressedBytes = compressedBytes + numel(v) * bpw;
end
fprintf('Flash: %.1f KB -> %.1f KB (%.1f%% savings)\n', ...
    baselineBytes/1024, compressedBytes/1024, ...
    (1 - compressedBytes/baselineBytes) * 100);
```

---

## fitcnet / fitrnet Compression: Fixed-Point Designer

### Fixed-Point Conversion

```matlab
% Generate a predict function for the trained model
function y = predictFromModel(mdl, x)
    y = predict(mdl, x);
end

% Use the Fixed-Point Tool to convert
% 1. Open the Fixed-Point Tool
fixedPointDesigner

% 2. Or use programmatic conversion with fxpopt
% Define input types
inputTypes = {coder.typeof(single(0), [1 numFeatures])};

% Create fixed-point configuration
fxpCfg = coder.config("fixpt");
fxpCfg.TestBenchName = "testBench";  % Function that exercises the code
fxpCfg.DefaultWordLength = 16;
fxpCfg.DefaultFractionLength = 8;

% Generate fixed-point code
codegen -float2fixed fxpCfg predictFunction -args inputTypes
```

### Fixed-Point Considerations for Lean Hardware

| Target Hardware         | Typical Word Length | Notes                           |
|-------------------------|--------------------|---------------------------------|
| Cortex-M0/M0+           | 8 or 16 bit        | Very constrained, aggressive quantization |
| Cortex-M4/M4F           | 16 or 32 bit       | Has FPU, but fixed-point still faster |
| Cortex-M7               | 16 or 32 bit       | Double-precision FPU available   |
| DSP (e.g., C2000)       | 16 or 32 bit       | Native fixed-point support      |
| Custom ASIC / NPU       | 8 bit              | Often int8-only inference       |

---

## Compression Validation

After any compression step, always validate:

```matlab
% Compare original vs. compressed model
YOriginal   = minibatchpredict(net, XTest);
YCompressed = minibatchpredict(compressedNet, XTest);

% Classification accuracy comparison
[~, origLabels] = max(YOriginal, [], 2);
[~, compLabels] = max(YCompressed, [], 2);
origAcc = mean(origLabels == YTest);
compAcc = mean(compLabels == YTest);

fprintf("Original accuracy:   %.2f%%\n", origAcc * 100);
fprintf("Compressed accuracy: %.2f%%\n", compAcc * 100);
fprintf("Accuracy drop:       %.2f%%\n", (origAcc - compAcc) * 100);

% Model size comparison
origInfo = whos("net");
compInfo = whos("compressedNet");
fprintf("Original size:   %.1f KB\n", origInfo.bytes / 1024);
fprintf("Compressed size: %.1f KB\n", compInfo.bytes / 1024);
fprintf("Compression ratio: %.1fx\n", origInfo.bytes / compInfo.bytes);
```

---

## CRITICAL Rules Summary

1. **prepareNetwork() before calibrate() for non-projected networks** -- Networks with unfused
   batch normalization or certain LSTM state configurations need `prepareNetwork()` before
   `calibrate()`, or calibration fails with fi() type errors. Skip for projected networks
   (containing `ProjectedLayer`, `lstmProjectedLayer`, `gruProjectedLayer`) — it will error.

2. **Save immediately after quantize()** -- macOS R2026a has a background thread crash after
   quantize(). Save the quantized network to disk immediately after `quantize()` returns.

3. **unpackProjectedLayers before direct MATLAB Coder codegen** -- `ProjectedLayer`,
   `lstmProjectedLayer`, and `gruProjectedLayer` are NOT supported by
   `coder.loadDeepLearningNetwork`. Always call `unpackProjectedLayers()` before saving
   for the direct MATLAB Coder path. **Not required for the Simulink path in R2026a:**
   `exportNetworkToSimulink` accepts projected networks directly.

4. **quantize() output is deployable via Simulink, NOT via direct MATLAB Coder** --
   `coder.loadDeepLearningNetwork` does not accept the output of `quantize()`. For
   embedded deployment of a quantized network, use `exportNetworkToSimulink(qNet)`
   followed by `slbuild`. For the direct MATLAB Coder path, use the uncompressed,
   pruned, or unpacked projected float32 network.

5. **Use ExecutionEnvironment="MATLAB"** -- For target-agnostic C/C++ code generation, always
   set `ExecutionEnvironment` to `"MATLAB"` when creating the dlquantizer.

6. **Compression Library is a support package** -- It is NOT detected by
   `detect_matlab_toolboxes`. Use `matlabshared.supportpkg.getInstalled` to check.

---

## Workflow Pattern 1 Compression Targets

For lean hardware deployment (Cortex-M, DSPs):

| Metric             | Target                  | Notes                              |
|--------------------|-------------------------|------------------------------------|
| Model size         | < 500 KB (ideally < 100 KB) | Flash/ROM constraint          |
| RAM usage          | < 64 KB                 | SRAM constraint for inference      |
| Inference time     | < 10 ms (application-dependent) | Real-time constraint        |
| Data type          | int8 or fixed-point     | No FPU on some targets             |
| Accuracy drop      | < 2% relative           | Application-dependent tolerance    |
