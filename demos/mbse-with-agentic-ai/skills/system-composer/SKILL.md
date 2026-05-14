---
name: system-composer
description: >
  Use this skill when authoring reusable, idempotent MATLAB scripts that build System Composer
  architecture models via the architecture-modeling API — `systemcomposer.createModel`,
  `addComponent`, `addPort`, `setInterface`, `connect(srcPort, dstPort)`, interface dictionaries
  (.sldd) with `addInterface`/`addElement`, profiles/stereotypes with `Profile.createProfile`
  and `addStereotype`, or `systemcomposer.allocation.createAllocationSet`. Also trigger when
  debugging these APIs (connections that don't appear, interfaces that don't resolve, profile
  save errors, `createAllocationSet` signature-mismatch errors). Do NOT trigger for ad-hoc
  structural edits to an already-built model (adding one SubSystem, rewiring a port) — use
  `building-simulink-models` with `model_edit` for that.
---

# MATLAB System Composer — Programmatic Authoring Guide

System Composer lets you model multi-domain architectures in MATLAB. This skill captures the
correct API patterns, common gotchas, and a proven script structure for building models reliably.

---

## When to use this skill vs. `building-simulink-models` (SATK)

Both skills can edit System Composer `.slx` files. They work at **different API layers** — don't mix them in one script.

| Concern | This skill (architecture-modeling API) | `building-simulink-models` with `model_edit` (block-diagram API) |
|---|---|---|
| Component creation | `addComponent(arch, "Name")` — returns `systemcomposer.Component` | `add_block` with `type: "SubSystem"` — returns a `blk_id` |
| Ports | `addPort(arch, "Name", "in", iface)` — typed, interface-aware | Bus Element blocks (`In Bus Element` / `Out Bus Element`) inside the SubSystem |
| Connections | `connect(srcPort, dstPort)` — port objects | `{"op": "connect", "target": "blk_X.y1 -> blk_Y.PortName"}` |
| Interface dictionaries (`.sldd`) | First-class (`createDictionary`, `addInterface`, `setInterface`) | Not addressed |
| Profiles / stereotypes | First-class (`Profile.createProfile`, `addStereotype`, `applyStereotype`) | Not addressed |
| Allocation sets (`.mldatx`) | First-class (`systemcomposer.allocation.createAllocationSet`) | Not addressed |
| Auto-layout | **Call `Simulink.BlockDiagram.arrangeSystem` explicitly** before `save` — programmatic adds all land at (0,0) | `model_edit` runs autolayout automatically; its guardrail forbids manual `arrangeSystem` |

**Use this skill when:**
- Writing an idempotent `buildMyModel.m` / `buildMyArchitecture.m` script that will be re-run from scratch
- The architecture uses interface dictionaries, stereotypes/profiles, or allocation sets — `model_edit` has no primitives for any of these
- Debugging SC-specific API failures (CST `connect` shadow, composite `ArchitecturePort` errors, `dict.save` + re-fetch, `profile.save` path, `createAllocationSet` signature mismatch)

**Defer to `building-simulink-models` with `model_edit` when:**
- Making a one-off structural change to an already-built SC model (add one SubSystem, rewire one port, tweak a parameter)
- The user just wants "add a component called X" and the model has no interface dictionary / profile / allocation set the change needs to stay consistent with
- The MBSE workflow in `mbse-workflow` is not involved

**Do not mix in one script.** `model_edit` adds components via `add_block` with `type: "SubSystem"`; this skill adds them via `addComponent`. The two produce different object types and the architecture-modeling APIs in this skill (`setInterface`, `applyStereotype`, `addPort`) may not work on SubSystem-block-created components. Pick one layer per script.

---

## Recommended Script Structure

Keep profile creation in the same script as the architecture — add it at the end,
after the model and connections are built:

```
buildMySystemModel.m    ← architecture + interface dictionary + profile/stereotypes
```

This keeps both artifacts in sync on every rebuild, and avoids the "profile already
applied" uniqueness error that occurs when a separate profile script re-applies a
profile to an already-profiled model.

The script is idempotent: it deletes and recreates all artifacts on every run.

---

## Phase 1+2: Architecture Model + Interface Dictionary

### Skeleton

See [`code/buildMySystemModel.m`](code/buildMySystemModel.m) for the full parameterized function:

```
buildMySystemModel(modelName, dictFile, archDir)
```

---

## Phase 3: Profile & Stereotypes

See [`code/buildMySystemProfile.m`](code/buildMySystemProfile.m) for the full parameterized function:

```
buildMySystemProfile(profileName, modelName, archDir)
```

---

## Critical API Gotchas

These will silently fail or throw cryptic errors without warning:

| What you want | Correct API | Wrong / common mistake |
|---|---|---|
| Connect two component ports | `connect(srcPort, dstPort)` | `connect(arch, srcPort, dstPort)` — silently fails; dispatches to Control System Toolbox |
| Wire a composite boundary port to a sub-component port | `connect(boundaryArchPort, subComp.getPort("Name"))` — boundary is the saved `ArchitecturePort` ref; sub-component is its `ComponentPort` via `getPort` | Connecting two `ArchitecturePort`s across the boundary, or using the boundary's `ComponentPort` — both throw "incompatible directions" |
| Assign interface to port | `port.setInterface(iface)` | `port.Interface = iface` — read-only property error |
| Add interface element | `addElement(iface, "Name", Type="double")` | `Type="MyValueTypeName"` — value type names resolve to `Simulink.ValueType` objects which the bus compiler cannot use; always use a Simulink base type directly |
| Create model | `systemcomposer.createModel(name)` | `systemcomposer.createModel(name, true)` — invalid 2nd arg |
| Set string stereotype property | `setProperty(comp, path, '"value"')` | `setProperty(comp, path, 'value')` — evaluates as MATLAB variable |
| Set string default in addProperty | `DefaultValue='"standard"'` | `DefaultValue="standard"` — evaluates, throws error |
| Apply stereotype property | `setProperty(comp, ...)` | `setPropertyValue(comp, ...)` — wrong function name |
| Close all profiles | `systemcomposer.profile.Profile.closeAll()` | `...closeAll("-discard")` — too many arguments |
| Create profile | `createProfile(name)` | `createProfile(name, "file.xml")` — invalid 2nd arg |
| Look up a component by path | Keep component vars when adding, or use `resolveComponent(arch, 'Parent/Child')` helper | `arch.lookup('Path', ...)` — does not exist |
| Create allocation set | `createAllocationSet(name, srcModelName, dstModelName)` — model **names** | `createAllocationSet(name, srcModelObj, dstModelObj)` — model objects fail on R2025b with unhelpful AllocationAppCatalog signature error |

---

## Why `connect(srcPort, dstPort)` Must Have No Architecture Argument

`connect` is shadowed by Control System Toolbox's `connect.m`. When you write
`connect(arch, srcPort, dstPort)`, MATLAB dispatches to the CST version (which connects
LTI models) instead of System Composer — it returns an empty 0×0 Connector silently.

The two-argument form `connect(srcPort, dstPort)` dispatches correctly via the port object's
class method. Always use this form for explicit port-to-port connections.

For component-to-component auto-wiring by matching port names, the form
`connect(arch, [srcComp,...], [dstComp,...])` is also safe since `arch` dispatches correctly.

---

## Port Multiplicity: Fan-Out Works, Fan-In Needs Separate Ports

A single **output port** can be connected to any number of input ports — just call
`connect(out, in1); connect(out, in2); ...`. This is clean 1→N fan-out; use it for
broadcast buses (e.g. `Supervisory.Schedule` feeding every production unit).

A single **input port** cannot receive connections from multiple sources. SC is a
structural modelling tool with no merge semantics — attempting to hook two
outputs into one input either errors or silently fails. Give the destination
component **separate named input ports** for each source (e.g.
`Status_Cook`, `Status_Pack`, `Status_Load`) and wire 1:1. This pattern is
verbose but unambiguous and matches how an MBSE diagram will render for review.

---

## Composite Components: Mix ArchitecturePort and ComponentPort for Internal Wiring

When a component has sub-components (a composite), its boundary ports have two views:

| View | Accessed via | Class | Used for |
|---|---|---|---|
| External | `comp.Ports` / `comp.getPort(name)` | `ComponentPort` | Connections in the **parent** arch |
| Internal | return value of `addPort(comp.Architecture, ...)` | `ArchitecturePort` | Connections **inside** the composite, to sub-component ports |

A boundary "in" port acts as a *source* from inside the composite's sub-architecture (it delivers data to the sub-components), but its external `ComponentPort` still reports direction `in`. Using the wrong view throws:

```
Unable to connect ports because they have incompatible directions.
```

### The exact rule (verified on R2025b)

Internal connections inside a composite require **specific port classes on each side** — verified empirically; mixing them wrong fails every time:

| Connection inside the composite | Source port | Destination port | `connect` call |
|---|---|---|---|
| Boundary → sub-component | Saved boundary `ArchitecturePort` | Sub-component `ComponentPort` (via `getPort`) | `connect(boundaryRef, sub.getPort("Name"))` |
| Sub-component → boundary | Sub-component `ComponentPort` (via `getPort`) | Saved boundary `ArchitecturePort` | `connect(sub.getPort("Name"), boundaryRef)` |
| Sub-component → sub-component | `ComponentPort` (via `getPort`) | `ComponentPort` (via `getPort`) | `connect(a.getPort("Out"), b.getPort("In"))` — same as top-level |

**Two `ArchitecturePort`s on opposite sides of the boundary fail** with "incompatible directions." That means the `motorPow` pattern — passing the return value of `addPort(sub.Architecture, ...)` to `connect` alongside a boundary `ArchitecturePort` — does **not** work. Use `sub.getPort(name)` instead for the sub-component side.

### Pattern

```matlab
function port = addTypedPort(comp, name, direction, iface)
    port = addPort(comp.Architecture, name, direction);
    port.setInterface(iface);
end

% Composite creation — keep the boundary refs
conv = addComponent(arch, "ConveyorSystem");
convPowerIn = addTypedPort(conv, "PowerIn", "in", ifPower);   % ArchitecturePort
convDiagOut = addTypedPort(conv, "DiagOut", "out", ifDiag);   % ArchitecturePort

% Sub-components — no need to save their port refs
motor = addComponent(conv.Architecture, "Motor");
addTypedPort(motor, "PowerIn",  "in",  ifPower);
addTypedPort(motor, "DiagOut", "out", ifDiag);

% Boundary -> sub: saved ArchitecturePort + sub's ComponentPort
connect(convPowerIn, motor.getPort("PowerIn"));        % ✓ correct

% Sub -> boundary: sub's ComponentPort + saved ArchitecturePort
connect(motor.getPort("DiagOut"), convDiagOut);        % ✓ correct

% DO NOT: two ArchitecturePorts across the boundary
% motorPow = addTypedPort(motor, "PowerIn", "in", ifPower);
% connect(convPowerIn, motorPow);                      % ✗ incompatible directions
```

External connections from the parent arch continue to use `conv.getPort(name)` (ComponentPort) as normal, the same as top-level connections between non-composite components.

### Why `addTypedPort(comp, ...)` takes the Component (not its Architecture)

The helper called with a Component does `addPort(comp.Architecture, ...)` internally, so either calling convention works. Passing the Component is slightly cleaner for the common case and matches how non-composite components add ports. For a composite, the *return value* is still the internal `ArchitecturePort` — save it when you'll need it for boundary-to-sub wiring.

---

## Variant Components

A **variant component** is a sibling concept to a composite: one wrapper with N alternative internal architectures (*choices*), only one of which is active at a time. Use this for architecture-options studies where you want to compare candidate topologies without duplicating the whole model file.

See [`code/buildMyVariantComposite.m`](code/buildMyVariantComposite.m) for a working build template and [`code/tradeStudy.m`](code/tradeStudy.m) for the driver that enumerates variants and emits a markdown comparison report.

### Canonical build sequence

```matlab
% 1. Build a regular composite with its boundary ports + the baseline content
comp = addComponent(arch, 'CookingLine');
addPort(comp.Architecture, 'RecipeData', 'in');
% ... add sub-components for the baseline ...

% 2. Convert to a variant wrapper. The baseline content becomes the first
%    auto-created choice (named the same as the wrapper).
vc = comp.makeVariant();

% 3. Re-fetch the wrapper -- the old `comp` reference is STALE (see below).
cookingLine = arch.getComponent('CookingLine');

% 4. Rename the auto-choice AND sync its variant condition to match.
ch = vc.getChoices();
ch(1).Name = 'V0_Baseline';
vc.setCondition(ch(1), 'V0_Baseline');

% 5. Add additional choices; each choice is a regular Component with its own
%    Architecture. Wire internal content inside each choice.
v1 = vc.addChoice({'V1_Parallel'});
addPort(v1.Architecture, 'RecipeData', 'in');
addComponent(v1.Architecture, 'ParallelA');
addComponent(v1.Architecture, 'ParallelB');

% 6. Choose the default active variant.
vc.setActiveChoice('V0_Baseline');
```

### Gotcha — the original `Component` reference is stale after `makeVariant`

Once `makeVariant` returns, port lookups on the original variable fail with `"not in same architecture scope"`. External connections placed *before* `makeVariant` survive the conversion (verified empirically), but any subsequent `comp.getPort(...)` or `connect(...)` calls must use a fresh reference:

```matlab
vc = comp.makeVariant();
freshComp = arch.getComponent('CookingLine');   % returns VariantComponent

% Wrong -- stale scope:
connect(other.getPort('Out'), comp.getPort('RecipeData'));   % ✗

% Right:
connect(other.getPort('Out'), freshComp.getPort('RecipeData'));   % ✓
```

### Gotcha — rename + `setCondition` must stay in sync

`ch.Name = 'V0_Baseline'` does *not* update the variant condition. `setActiveChoice` matches the given string against conditions, so without re-syncing:

```matlab
ch(1).Name = 'V0_Baseline';
vc.setActiveChoice('V0_Baseline');
%   Error: Setting active choice for variant block '...' with variant control
%          'V0_Baseline' is not supported.
```

Fix by calling `vc.setCondition(ch(1), 'V0_Baseline')` immediately after the rename.

### Gotcha — `applyStereotype` on the wrapper throws

```
Unable to apply stereotype 'Profile.Stereotype' on variant architecture '.../Wrapper'.
```

Apply the stereotype to each *choice* instead. Numeric property values set on the active choice propagate to the wrapper's instance at `instantiate` time, so the rollup callback sees the right value when it visits the wrapper. This is the mechanism that makes per-variant rollup estimates work.

### Gotcha — **string** stereotype properties do NOT propagate choice → wrapper instance

Verified empirically on R2025b. A `Type="double"` property set on the active choice shows up on the wrapper's instance (`instance.hasValue(...) == true`, `getValue(...)` returns the choice's number). A `Type="string"` property shows up as `hasValue == false` on the wrapper's instance.

This matters when you want the rollup callback to branch on variant-specific behavior (e.g. MIN aggregation for serial, SUM for parallel). **Encode the flag as a number, not a string:**

```matlab
% Works across the choice → wrapper instance boundary:
addProperty(st, "UseParallelThroughput", Type="double", DefaultValue="0");
setProperty(parallelChoice, stPath + ".UseParallelThroughput", "1");

% Does NOT work:
addProperty(st, "ThroughputAggregation", Type="string", DefaultValue='"MIN"');
setProperty(parallelChoice, stPath + ".ThroughputAggregation", '"SUM"');
%   -> wrapper's instance reports hasValue == false for this property
```

See [`mbse-architecture/references/analysis.md#topology-dependent-rollup`](../mbse-architecture/references/analysis.md#topology-dependent-rollup) for the rollup callback pattern that reads the numeric flag.

### Gotcha — auto-layout skips inactive choices

`comp.Architecture.Components` on a `VariantComponent` returns only the *active* choice's sub-components, so a generic recursive `arrangeComposites` walker that follows `.Architecture` never lays out the inactive variants. Iterate `vc.getChoices()` explicitly:

```matlab
function arrangeComposites(arch, pathPrefix)
    for comp = arch.Components
        subPath = [pathPrefix, '/', comp.Name];
        if isa(comp, 'systemcomposer.arch.VariantComponent')
            Simulink.BlockDiagram.arrangeSystem(subPath);
            for ch = comp.getChoices()
                choicePath = [subPath, '/', ch.Name];
                Simulink.BlockDiagram.arrangeSystem(choicePath);
                arrangeComposites(ch.Architecture, choicePath);
            end
        elseif ~isempty(comp.Architecture) && ~isempty(comp.Architecture.Components)
            Simulink.BlockDiagram.arrangeSystem(subPath);
            arrangeComposites(comp.Architecture, subPath);
        end
    end
end
```

Each choice's Simulink path is `Model/Wrapper/ChoiceName` — regular `arrangeSystem` works on them.

### Minor — `updatePortsFromChoices` requires the `'Mode'` kwarg

```matlab
vc.updatePortsFromChoices();                    % error: 'Mode' must be specified
vc.updatePortsFromChoices('Mode','addPorts');   % ✓ adds missing wrapper ports from choices
```

Use this when choices define their own boundary ports and you want the wrapper to pick them up. If instead you add ports on the wrapper's `Architecture` *before* `makeVariant` and mirror them on each choice manually, you don't need this call.

---

## Sequence Diagrams

A **sequence diagram** (SC calls these "Interactions") is a behavioral view layered on top of an architecture model. It shows how components collaborate over time for a specific scenario: which messages pass between them, in what order, under what guards. Unlike a Mermaid/PlantUML sequence diagram, every SC message is **bound to real ports on real components** — rename a port upstream and the sequence-diagram build errors, which is the feature not a bug.

See [`code/buildMySequenceDiagram.m`](code/buildMySequenceDiagram.m) for a working template.

### Mental model

```
Model
 └── Interaction                      (one per scenario)
      ├── Lifelines                   (one per participant, bound to a Component)
      └── RootFragment
           └── Operands(1)            (pre-created default operand; messages live here)
                ├── addMessage(...)
                └── addFragment('Alt' | 'Loop' | 'Opt' | 'Par')
                     └── Operands(1..N) → more messages, recursively
```

Messages hang off *operands*, not directly off fragments or the interaction. `Interaction.RootFragment.Operands(1)` is where the straight-line message sequence goes. `Alt` creates a fragment with two operands; each has its own `Guard` string and its own `addMessage`.

### Canonical build sequence

```matlab
model = systemcomposer.openModel('MyModel');
destroyInteractionIfPresent(model, 'MyScenario');   % idempotent rebuild
diagram = model.addInteraction('MyScenario');

L1 = diagram.addLifeline('MyModel/CompA');          % path OR Component object
L2 = diagram.addLifeline('MyModel/CompB');

op = diagram.RootFragment.Operands(1);
op.addMessage(L1, 'OutPort', L2, 'InPort', 'request');
op.addMessage(L2, 'ReplyOut', L1, 'ReplyIn', 'reply');

save_system('MyModel');                              % interactions live INSIDE the .slx
open(diagram);                                       % show in Sequence Viewer
```

### Gotcha — `addMessage` is 5 arguments, not 3

```matlab
op.addMessage(L1, L2, 'request')                     % ✗ "Function requires 3 more input(s)"
op.addMessage('request', L1, L2, 1)                  % ✗ various complaints
op.addMessage(L1, 'OutPort', L2, 'InPort', 'request')% ✓ (src, srcPort, dst, dstPort, guard)
```

The 2nd and 4th args are **port names that must exist on the components underlying the lifelines**. If you pass a name that doesn't match a port on the source component, you get `"Name must match a port on the component corresponding to the lifeline"`. This ties every message to the structural model and is the main reason to prefer programmatic SC sequence diagrams over free-form Mermaid.

### Gotcha — messages do NOT live on Fragments directly

```matlab
diagram.RootFragment.addMessage(...)                 % ✗ no such method
diagram.RootFragment.Operands(1).addMessage(...)     % ✓
```

Same for `Alt`/`Loop`/`Opt` fragments: get `.Operands(i).addMessage(...)`. `Alt.Operands` has length 2 after `addFragment('Alt')`; set `op1.Guard = "cond1"` / `op2.Guard = "cond2"`.

### Gotcha — idempotent rebuild requires explicit `destroy()`

`model.addInteraction(name)` errors on duplicate name. Always delete the existing one first:

```matlab
function destroyInteractionIfPresent(model, name)
    try, ixns = model.getInteractions(); catch, ixns = []; end
    for i = 1:numel(ixns)
        if strcmp(ixns(i).Name, name), ixns(i).destroy(); return; end
    end
end
```

Put the build step AFTER the architecture-model build step in `buildAll` — a rebuild of the architecture model wipes interactions along with everything else, so the sequence diagram must be re-created each time.

### Guard syntax

Guards accept trigger names, boolean expressions in braces, or both:

```
'cookComplete'                           event name
'{Accepted==1}'                          boolean on interface fields
'rocketDocked{RocketPresent==1}'         event + condition
'rising(sw-1){sw==1}'                    signal transition + condition
```

Use interface-element names (from the dictionary — e.g., `Accepted` on `QCVerdict`) so the guard text stays consistent with the rest of the model.

### Duration constraints

`message.Start` and `message.End` return `MessageEvent` objects that can be passed to `addDurationConstraint`:

```matlab
t0 = msg1.End;
t1 = msg2.End;
diagram.addDurationConstraint(t0, t1, 't < 10sec');   % assertion on the render + runtime check
```

### Persistence + viewing

- Interactions are serialized *inside* the model's `.slx` — `save_system(modelName)` commits them; no separate file to track.
- `open(diagram)` opens the SC Sequence Viewer canvas. `diagram.open()` also works.

### Requirement traceability — see the slreq skill

slreq does not accept an `Interaction` object as a `createLink` source on R2025b, and the struct-based workaround (`domain='linktype_sc_interaction'`) fails to persist when the containing `.slx` already hosts `linktype_rmi_simulink` Implement links. See [`simulink-requirements/SKILL.md`](../simulink-requirements/SKILL.md) — search for "Interaction"; it covers the recommended convention-based trace pattern.

---

## Why dict.save() + Re-fetch Is Required

`systemcomposer.createDictionary()` creates the file but interface objects in memory aren't
fully resolved until after `dict.save()`. If you call `port.setInterface(iface)` before saving,
the model links the port to an unresolvable interface name — connections will silently fail and
reopening the model shows "Unable to resolve interface" errors.

Pattern to always follow:
```matlab
% 1. Add all value types and interfaces
thermalIface = addInterface(dict, "ThermalFluid");
addElement(thermalIface, "Temperature", Type="Temperature");

% 2. Save
dict.save();

% 3. Re-fetch — now safe to pass to setInterface
thermalIface = dict.getInterface("ThermalFluid");
```

---

## Auto-layout

Always call `Simulink.BlockDiagram.arrangeSystem` before `save(model)` — programmatically
added components all start at position (0,0) and stack on top of each other without it.

**For hierarchical models, arrange every decomposed sub-architecture as well as the top level.**
Use the Simulink subsystem path `modelName + "/ComponentName"` for each level:

```matlab
%% Layout and Save
Simulink.BlockDiagram.arrangeSystem(modelName + "/Powertrain");   % sub-levels first
Simulink.BlockDiagram.arrangeSystem(modelName + "/Drivetrain");
Simulink.BlockDiagram.arrangeSystem(modelName);                   % top level last
save(model);
```

Arrange sub-levels before the top level so the top-level layout has accurate size information
for each component block. A sub-architecture that was never arranged remains a collapsed pile,
and the top-level arrange won't fix it.

---

## Re-run Safety for Profile Scripts

Calling `applyProfile` on a model that already has the profile throws a "uniqueness constraint"
error. The cleanest solution is to rebuild the model from scratch at the top of the profile
script — this guarantees a clean slate and makes both scripts independently idempotent.
`buildMySystemProfile` already does this: its first call is always `buildMySystemModel(...)`.

---

## Multi-Domain Interface Patterns

Use `Type="double"` for all elements and document physical units in comments.
Do not use `addValueType` for physical quantities — it creates `Simulink.ValueType`
objects the bus compiler cannot resolve (breaks "update diagram").

See [`code/addCommonInterfaces.m`](code/addCommonInterfaces.m) for an illustrative starting
point covering Thermal, Electrical, Mechanical, and UserCommand interfaces:

```
ifaces = addCommonInterfaces(dict)
```

Returns a struct (`ifaces.ThermalFluid`, `ifaces.ElectricalPower`, etc.). Remember to call
`dict.save()` and re-fetch interfaces before passing them to `setInterface()` — see the
re-fetch pattern above.

---

## Architecture Views — filtered lenses on a large model

Once a model grows beyond a couple of dozen components, navigating it becomes a drag. System Composer's **view architectures** are named, saved lenses that filter the architecture by a stereotype-property query. A view appears in the model canvas dropdown and in the Views Gallery (`openViews(model)`), and matching components glow in the color you gave the view. This is how Gulfstream's eSAM method routinely surfaces cost drivers, high-power components, per-supplier subsets, etc. without hand-drawn diagrams that rot.

Two mechanisms:

**Query-driven views** — a single stereotype-property constraint picks members automatically:

```matlab
import systemcomposer.query.*;
q = PropertyValue("MyProfile.ComponentProperties.Cost_credits") > 150000;
v = createView(model, "CostDrivers", Select=q, Color="#D62728");
```

**Color gotcha:** `Color` accepts hex strings universally (`"#D62728"`) and some but not all named colors — `"red"` and `"blue"` work, `"magenta"` errors with *"The value of 'Color' is invalid. The color must be a hex color or RGB value."* Prefer hex.

`PropertyValue(path)` returns an object that overloads `>`, `<`, `>=`, `<=`, `==`, `~=` to build a query constraint — so the `pv > 150000` expression builds a `systemcomposer.query.Compare` object. Pass it as `Select=`. The view refreshes automatically as stereotype properties change.

To check ad-hoc what a query matches without committing to a view:

```matlab
matches = find(model, q);   % returns a cell array of qualified-name STRINGS,
                            % not Component objects (easy mistake)
for i = 1:numel(matches), disp(string(matches{i})); end
```

**Explicit-element views** — for anything a single property query can't express (allocation-driven groupings, hand-picked subsets, per-supplier partitions), create an empty view and add elements by hand:

```matlab
v = createView(model, "ControlRealization", Color="blue");
v.Root.addElement(arch.getComponent('ControlCabinet'));
for sub = arch.getComponent('ControlCabinet').Architecture.Components
    v.Root.addElement(sub);
end
```

Both mechanisms are additive — you can start with a query and then `addElement` to include extras that didn't match.

### Idempotency when rebuilding

Views are saved *inside* the `.slx`. Our build scripts recreate the `.slx` from scratch on every run, which wipes views along with everything else. So a view-creation script has to run **after** the relevant `buildXxx.m` and be idempotent itself:

```matlab
try, deleteView(model, "CostDrivers"); end %#ok<TRYNC>   % guard against first-run-missing
v = createView(model, "CostDrivers", Select=q, Color="red");
```

See [`code/buildMyViews.m`](code/buildMyViews.m) for a parameterised helper that takes a list of view specs and creates them all.

### `find()` returns strings, not components

A recurring mistake: `find(model, constraint)` returns a `cell` of qualified-name *strings* like `"MyModel/Parent/Sub"`, not `systemcomposer.arch.Component` objects. If you need the component object to, e.g., call `getPropertyValue`, use `model.lookup("Path", pathString)` to resolve it.

---

## Verifying Your Model

Run these checks after every build. They catch real problems that the build step itself
won't flag.

### 1. Check for unconnected ports

Ports that were added but never wired are silently valid at build time but represent
incomplete or inconsistent architecture. See [`code/checkUnconnectedPorts.m`](code/checkUnconnectedPorts.m):

```
checkUnconnectedPorts(modelName)
```

### 2. Update diagram

`set_param` update catches any remaining type resolution issues (e.g. a bad interface
element type that slipped through):

```matlab
set_param("MySystem", "SimulationCommand", "update");
```

**Expected warning for pure architecture models:** `Architecture model contains no
components or all components are virtual.` This is normal — architecture components
have no simulation behaviour. It does not indicate a problem with your model.

If you see a type resolution error instead (e.g. `DataType 'X' did not resolve`), the
cause is almost always an `addElement` call using a value type name instead of a
Simulink base type — see the gotchas table above.

### 3. Check stereotype properties (if using profiles)

```matlab
comp  = arch.getComponent("ComponentA");
props = comp.getStereotypeProperties();
for i = 1:numel(props)
    fprintf("  %s = %s\n", props(i), comp.getPropertyValue(props(i)));
end
```
