# Environment Discovery (Silent)

Run this phase silently at the start of every session. Do NOT prompt the user.

## Step 1: Detect Toolboxes

Use `detect_matlab_toolboxes` MCP tool to enumerate installed toolboxes and MATLAB version.

Record availability of:
- Deep Learning Toolbox (DLT)
- Statistics and Machine Learning Toolbox (Stats/ML)
- MATLAB Coder
- Simulink Coder
- Embedded Coder
- GPU Coder
- HDL Coder
- Deep Learning HDL Toolbox
- Fixed-Point Designer
- Simulink
- Signal Processing Toolbox
- Image Processing Toolbox
- Reinforcement Learning Toolbox

**Gate:** STOP if **both** Deep Learning Toolbox and Statistics/ML Toolbox are missing.

## Step 2: Detect Support Packages

Support packages are **NOT** returned by `detect_matlab_toolboxes`. Query separately:

```matlab
pkgs = matlabshared.supportpkg.getInstalled;
if ~isempty(pkgs)
    disp({pkgs.Name}');
end
```

Check for these support packages:

| Support Package | Needed For |
|----------------|-----------|
| Deep Learning Toolbox Converter for PyTorch Models | Pattern 1 import from PyTorch |
| Deep Learning Toolbox Converter for ONNX Model Format | Pattern 1 import from ONNX |
| Deep Learning Toolbox Converter for TensorFlow Models | Pattern 1 import from TensorFlow |
| Deep Learning Toolbox Model Compression Library | Pattern 1 compression (pruning, projection) |
| AI Verification Library for Deep Learning Toolbox | AI verification (OOD detection) |
| Deep Learning Support from MATLAB Coder | Pattern 1 code generation (`coder.loadDeepLearningNetwork`) |
| MATLAB Coder Support Package for PyTorch and LiteRT Models | Pattern 2 (direct PyTorch/LiteRT to C) |
| Embedded Coder Support Package for ARM Cortex-M Processors | CMSIS/CMSIS-NN optimized code for Cortex-M targets |

**Detection pattern:**
```matlab
pkgs = matlabshared.supportpkg.getInstalled;
hasPyTorchConverter = ~isempty(pkgs) && any(contains({pkgs.Name}, "Converter for PyTorch"));
hasONNXConverter    = ~isempty(pkgs) && any(contains({pkgs.Name}, "ONNX"));
hasPyTorchSPKG     = ~isempty(pkgs) && any(contains({pkgs.Name}, "PyTorch and LiteRT"));
hasCompLib         = ~isempty(pkgs) && any(contains({pkgs.Name}, "Model Compression"));
hasAIVerif         = ~isempty(pkgs) && any(contains({pkgs.Name}, "AI Verification"));
hasArmCortexM      = ~isempty(pkgs) && any(contains({pkgs.Name}, "ARM Cortex-M"));
```

## Step 3: Check Python Environment (if PyTorch workflows possible)

```matlab
pe = pyenv;
disp(pe.Version);    % Should be 3.9+
disp(pe.Executable); % Path to Python
```

If Python is not configured, set it with the path to your Python executable:
- Windows: `pyenv('Version', 'C:\Users\<user>\AppData\Local\Programs\Python\Python311\python.exe')`
- macOS/Linux: `pyenv('Version', '/usr/local/bin/python3')`

For Pattern 2: Python environment must have `torch >= 2.0`.

### Python/MATLAB Interop Pitfall: Numpy Array Dimensions

When loading numpy `.npy` files into MATLAB via `py.numpy.load` or `single(npArray)`:
- A 1-D numpy array of shape `(N,)` becomes a MATLAB **row vector** `[1 × N]`
- This causes implicit expansion bugs when subtracted from column vectors `[N × 1]`

**Always force column vectors after loading numpy data:**
```matlab
refOutputs = single(py.numpy.load("outputs.npy"));
refOutputs = refOutputs(:);  % Force column vector
```

## Step 4: Present Environment Summary

Present a concise summary to the user:

```
Environment Summary:
- MATLAB R20XXx
- Toolboxes: [list available]
- Support packages: [list available]
- Missing for your workflow: [list if any]
- Python: [version] at [path] (or "not configured")
```

If a required support package is missing, inform the user:
"[Package name] is not installed. Please download it from the Add-On Explorer
(Home > Add-Ons > Get Add-Ons) and let me know when it's ready."

**Do NOT install on the user's behalf. Wait for confirmation.**
