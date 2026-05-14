# MBSE Analysis Reference (Phase 6)

Analysis is optional — only relevant when the project needs quantitative
roll-up, trade studies, sensitivity analysis, or margin reporting. Runnable
templates live alongside this file:

- `code/myRollupAnalysis.m` — analysis function template (sum + min + mean blocks)
- `code/runMyAnalysis.m` — driver skeleton (instantiate → iterate → report → save)

**File placement.** The analysis function file (e.g. `myRollupAnalysis.m`) belongs in
the project's `analysis/` folder, not `scripts/`. It's an analysis artifact (consumed
by the driver and persisted alongside the `.mat` output), not a phase build step. The
project path includes `analysis/`, so the function resolves by name. The driver
script itself (`runAnalysis.m`) stays in `scripts/` like the other build steps.

---

## The canonical roll-up pattern: analysis function + iterate(PostOrder)

Always prefer this pattern over flat-loop aggregation in MATLAB. It matches
the MathWorks `CostAndWeightRollupAnalysis` example and writes rolled-up
values to **every** parent in the hierarchy, so the Analysis / Instance
Viewer is useful at every level — not just at the top.

The analysis function is a single file, one per model, with the fixed
signature `function myRollupAnalysis(instance, varargin)` containing one
block per aggregated property. The driver invokes it via:

```matlab
instance = instantiate(arch, profileName, 'MyAnalysis');
iterate(instance, 'PostOrder', @myRollupAnalysis);
```

`'PostOrder'` visits **children before parents** — that is what makes the
roll-up work.

See `code/myRollupAnalysis.m` and `code/runMyAnalysis.m` for the full
templates; the notes below explain the non-obvious parts.

---

## The three-part guard

Every block in the analysis function starts with the same guard:

```matlab
if instance.isComponent() && ~isempty(instance.Components)...
 && instance.hasValue('MyProfile.Stereotype.prop')
```

Each check is load-bearing:

- `isComponent()` — skip ports, connectors, and the root architecture
  element (they don't have the same property surface)
- `~isempty(Components)` — skip leaves; their estimates come from profile
  defaults and should not be overwritten
- `hasValue(path)` — skip components whose stereotype doesn't include this
  property

Also guard each child read with `child.hasValue(path)` — a child can be
missing the stereotype even when the parent has it.

---

## Leaves-only stereotype: recursive sum as an alternative

When the physical architecture has composite assemblies, you have a choice: apply the stereotype to every component (leaves AND composites), or to leaves only. The canonical `iterate + PostOrder` pattern above assumes the former — composites need the stereotype for the guarded block to fire on them.

If you chose **leaves only** (composites are purely structural, and you want `prop == 0` review-dashboard views like `ZeroedEstimate_Flag` to stay meaningful without false-positives), `PostOrder` will skip every composite — their `hasValue` guard returns false — so parent-level aggregation never fires. Do the rollup in the driver with recursive descent instead:

```matlab
function s = sumLeaves(instance, prop)
    s = 0;
    for child = instance.Components
        if ~isempty(child.Components)
            s = s + sumLeaves(child, prop);    % composite — descend
        elseif child.hasValue(prop)
            s = s + child.getValue(prop);       % leaf with value
        end
    end
end
```

**Drive the recursion on `~isempty(child.Components)`, not on `~child.hasValue(prop)`.** An instance whose design component has no stereotype applied still reports `hasValue == true` — the profile's property defaults (e.g. `0`) leak through every instance — so a "has no value → recurse" condition stops at composites and silently drops all of their sub-components from the rollup.

### Which pattern to pick

| Prefer leaves-only when | Prefer stereotype-on-composites when |
|---|---|
| A `prop == 0` dashboard view is in the view set — applying stereotype to composites would false-positive on their default-0 values, and rollup results live on the analysis instance (not the design model) so the view never clears | You want the Analysis Viewer to display rolled-up values at every hierarchy level, not just leaves |
| Composites are purely structural containers with no own-attributes worth recording | The composite has meaningful own-attributes (e.g. an assembly-level enclosure mass the child sum would miss) |
| You want the simplest design model | You prefer the canonical `iterate + PostOrder` pattern and the richer Analysis Viewer display it produces |

Either way the driver's top-level totalling call is the same shape: `sumLeaves(instance, prop)` for the recursive case, `sumTop(instance.Components, prop)` for the canonical case (which relies on composites already holding aggregated values by that point).

---

## What PostOrder overwriting implies about the design model

PostOrder **overwrites** a parent's profile estimate with the sum (or min,
mean, …) of its children. If the children are an incomplete breakdown of the
parent — e.g. a `CookingStation` decomposed into `Pot`, `Stirrer`, `Heater`
while the station also contains unmodelled chassis/plumbing/wiring — the
rolled-up total will be **lower** than the parent's original estimate.

Treat this as a signal, not a bug. Either complete the decomposition, add a
"balance" sub-part, or deliberately leave the parent a leaf by giving it no
subcomponents. Do **not** try to protect the parent estimate by skipping
aggregation — that defeats the purpose.

---

## API notes

- `getValue(instance, 'Profile.Stereotype.prop')` returns a **double**. No
  `str2double` wrapper needed (differs from `getPropertyValue` on the design
  model).
- `setValue(...)` writes into the analysis instance only — the design model
  is unchanged.
- Save the instance to `analysis/`, not `architecture/`. `save(instance, path)`
  writes a `.mat`.
- Open the Analysis Viewer with the **instance object**, not a name string:
  `systemcomposer.analysis.openViewer('Source', instance)`. The shorter form
  `openViewer('MyAnalysis')` from older MathWorks examples **does not work in
  R2025b** — it errors with "A name is expected". The driver script should
  call `openViewer('Source', instance)` directly after `save(instance, ...)`
  so the user sees the rolled-up values immediately. A separately-saved `.mat`
  can be reloaded via `load` + re-iterate, or by re-running the driver.

---

## Declaring computed properties on the stereotype

For pure roll-ups over an existing property (mass, power, …) no extra
declaration is needed — the analysis just overwrites the parent's value.
For **derived** values (computed margin, figure of merit, utilization ratio)
add a separate property in the build script so the Analysis Viewer can show
it:

```matlab
addProperty(st, 'power',          Type="double", Units="W", DefaultValue="0");
addProperty(st, 'computedMargin', Type="double", Units="W", DefaultValue="0");
```

---

## Caps belong in requirements, not the analysis script

Store system-level limits in the requirements set:

```
SR-SYS-010: "The system shall not exceed 35 kg total mass."
SR-SYS-011: "The system shall not exceed 450 W total power consumption."
```

The `parseBudgetValue` helper in `code/runMyAnalysis.m` reads these
automatically using the phrase **"not exceed X \<unit\>"**. As long as
requirements follow that pattern, the script stays in sync.

---

## Common analysis types

| Type | Approach |
|---|---|
| Hierarchical roll-up | Analysis function + `iterate(..., 'PostOrder', @fn)` — the primary pattern here |
| Per-component margin | Derived-property block in the analysis function; `setValue(margin, cap_i - estimate_i)` per leaf |
| Sensitivity | Call `instantiate` in a loop with varied estimates; replot system-level margin |
| Design alternatives | Two `instantiate` calls with different property sets; compare `.mat` outputs |
| Pareto / scatter | Read arrays of per-component values in one pass, `plot(mass, power)` |
| Monte Carlo | Perturb leaf estimates with `randn` across iterations; histogram the rolled-up top-level value |
| **Variant trade study** | Enumerate variant choices on a `VariantComponent`; `setActiveChoice` + `instantiate` + rollup per variant; compare. Template at [`system-composer/code/tradeStudy.m`](../../system-composer/code/tradeStudy.m). |

---

## Topology-dependent rollup

Some rollups can't use one aggregator uniformly. **Throughput** is the canonical case:

- A serial pipeline's sustained rate is the **MIN** over its stages (the bottleneck).
- Parallel branches working on the same stream combine via **SUM**.

The composite where the rollup runs can't know which rule applies without a hint. The clean pattern is a **per-composite stereotype flag** the rollup callback reads:

```matlab
% On the stereotype definition:
addProperty(st, "UseParallelThroughput", Type="double", DefaultValue="0");

% In the rollup callback (analysis/myRollup.m):
p    = [prefix, 'Throughput'];
pPar = [prefix, 'UseParallelThroughput'];
if instance.hasValue(p)
    useParallel = false;
    if instance.hasValue(pPar)
        useParallel = instance.getValue(pPar) >= 1;
    end
    if useParallel
        total = 0; anyPos = false;
        for child = instance.Components
            if child.hasValue(p)
                v = child.getValue(p);
                if v > 0, total = total + v; anyPos = true; end
            end
        end
        if anyPos, instance.setValue(p, total); end
    else
        bottleneck = inf;
        for child = instance.Components
            if child.hasValue(p)
                v = child.getValue(p);
                if v > 0 && v < bottleneck, bottleneck = v; end
            end
        end
        if isfinite(bottleneck), instance.setValue(p, bottleneck); end
    end
end
```

**Why numeric and not a string-enum like `"MIN"` / `"SUM"`.** For variant-component trade studies the flag value has to flip per active choice. System Composer R2025b propagates numeric stereotype properties from the active choice to the wrapper's instance at `instantiate` time, but does NOT propagate string properties — the wrapper instance will report `hasValue == false` for a string property set on the choice. Encoding the flag as 0/1 (numeric) makes it survive the choice→wrapper-instance hop. See the [`system-composer` skill's Variant Components section](../../system-composer/SKILL.md#variant-components) for details.

Reliability has the same topology dependency (series vs. parallel). Add a sibling flag (`UseParallelReliability`) with matching branch logic when needed. Don't try to infer topology from port connectivity in the callback — an explicit flag keeps the design intent legible.

---

## When *not* to use the analysis-function pattern

Bypass it only when the computation doesn't fit a child→parent aggregation:
cross-component constraints (e.g. "port A's datarate must be ≥ port B's"),
graph traversals, or analyses that need all leaf values at once (Monte Carlo,
Pareto plots). In those cases, either iterate with a custom visitor that
collects into arrays, or do a PostOrder pass to roll up what can be rolled
up, then a flat pass for the cross-cutting logic.
