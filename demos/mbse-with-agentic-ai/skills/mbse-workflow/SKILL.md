---
name: mbse-workflow
description: >
  Use this skill for guided MBSE work in MATLAB — starting a new project,
  resuming work mid-workflow on an existing project, or answering orientation
  questions about how the MBSE skills fit together. Trigger when the user says
  they want to create, start, or set up a new MBSE project; work on a
  model-based systems engineering / RFLPV project; or asks which skill covers
  which phase. Walks through phases one at a time: propose → approve →
  generate → run → confirm. Use proactively whenever someone mentions starting
  or continuing an MBSE project.
---

# MBSE Workflow — Guided Project Setup and Phase Orchestration

This skill walks through an MBSE project one phase at a time — for greenfield
setup *and* for resuming an existing project mid-workflow. At each phase:
propose → get approval → generate script → run it → checkpoint. If the user
rejects or wants changes, revise and regenerate — scripts are idempotent so
this is always safe.

## Skills by phase (at-a-glance routing)

| Phase | Domain skill | What it covers |
|---|---|---|
| 0 | `matlab-project` | `.prj` setup, folder layout, file tracking, build-script conventions, `runChecks` |
| 1, 9 | `simulink-requirements` | `slreq` API — SNs, SRs, TCs; Derive / Implement / Verify links; coverage |
| 2–4 | `mbse-architecture` (+ `system-composer`) | F / L / P models, three-level interface dictionaries |
| 4b–c | `mbse-architecture` / `system-composer` | Stereotype profile, architecture views (review dashboards) |
| 5–7 | `mbse-architecture` | F→L and L→P allocation sets, SR Implement links per layer |
| 8 | `mbse-architecture` | Quantitative roll-up analysis, margins (optional) |
| 10 | this skill | `buildAll.m`, project health check |

**Builds on `matlab-project`** for the generic `.prj` mechanics: project
creation, file tracking, path management, `removeFile`-before-`delete`,
build-script idempotency conventions, and `runChecks` health checks. This
skill generates the MBSE phase content; the project plumbing follows the
patterns in [`../matlab-project/SKILL.md`](../matlab-project/SKILL.md).

Use the other `mbse-*` skills for technical API patterns at each phase. This
skill manages the conversation flow and script generation.

---

## Project folder layout

The MBSE project layout follows the standard `setupProject` shape from
`matlab-project`, with these subfolders:

```
my-system/
├── my-system.prj          MATLAB Project file
├── plan.md / decisions.md (living docs — see below)
├── requirements/          .slreqx files (StakeholderNeeds, SystemRequirements, TestCases)
├── architecture/          .slx, .sldd, .xml, .mldatx (model, dictionary, profile, allocation)
├── analysis/              .mat (analysis instances)
├── verification/          (reserved — TC artifacts currently live in requirements/)
├── scripts/               buildAll.m, all phase build scripts, setupProject + setupMBSEProject
└── derived/               build outputs — NOT tracked in the project
    ├── cache/
    └── codegen/
```

---

## Cross-Phase Dependencies

- **Architecture rebuilds break allocation links.** `slreq.createLink` stores
  component references by Simulink SID. If you rebuild the model, SIDs change
  and Implement allocation links become stale. Always rebuild allocation after
  rebuilding the architecture model.

- **Profile setup belongs in the architecture script.** Create and apply the
  stereotype profile at the end of `buildPhysical()` so estimates travel with the
  model and survive every rebuild.

- **`slreq.saveAll()` saves cross-set links.** Call it after any session that
  creates links between different `.slreqx` files or between requirements and
  architecture artifacts.

- **`slreq.clear()` unloads all sets from memory** but does not delete files.
  Call it at the top of each script for a clean slate, then `slreq.load()` the
  files you need.

- **Delete `.slmx` link files alongside `.slreqx` files** when rebuilding
  requirement sets. Stale `.slmx` files store cross-artifact links and will
  auto-open old model files on load, causing conflicts.

---

## How to conduct this session

Work through the phases in order. Never jump ahead. At each checkpoint, present
what you are about to create in plain language and wait for explicit approval
("looks good", "yes", "proceed") before generating the script. If the user
asks for changes, make them and re-present — do not generate until approved.

After running each script, show the MATLAB output and ask the user to confirm
it looks right before moving to the next phase. Keep proposed content concise
and specific — avoid vague placeholders.

---

## Living documentation: `plan.md` and `decisions.md`

This skill **overrides** the generic living-doc framework from `matlab-project`
with MBSE-flavored templates. The framework, cadence guidance, and
when-to-append rules live in [`../matlab-project/SKILL.md`](../matlab-project/SKILL.md);
this skill ships its own templates with RFLPV phase rows and MBSE-specific
sections (Engineering concerns, Analysis scope, Decision context).

Use the templates at
[`templates/plan.md`](templates/plan.md) and
[`templates/decisions.md`](templates/decisions.md) — **not** the generic ones
under `matlab-project/templates/`. Phase 0 copies both into the project root,
fills placeholders from the interview answers, and registers them with the
MATLAB project so they travel with the repo. Subsequent phases edit them per
the cadence in `matlab-project`.

---

## Phase 0: Interview and Project Setup

Ask the following questions (can be in one message):

1. **System name** — what is the system called? (Used for file and model names, e.g. `SatComSystem`)
2. **Project location** — full path to the folder where the project should be created
3. **System description** — one paragraph: what does it do, what problem does it solve?
4. **Requirements source** — do you already have system requirements in an Excel/xlsx file, or should we develop them together in the interview? (determines Phase 1 Path A vs. Path B below)
5. **Key engineering concerns and review views** — two linked sub-questions, ask together:
   - (a) What *properties* of components matter for design decisions? (e.g. mass, power, cost, reliability, latency, data rate, supplier, safety level — these become stereotype properties applied to every physical component.)
   - (b) What *filtered views* of the architecture would help during review? (e.g. "components costing more than 10% of the cost budget", "all safety-critical components", "components supplied by vendor X", "components consuming > 20 kW", "any component with a zeroed estimate — a forgotten-input flag".) Each view is either a stereotype-property query (`Cost > 150000`, `SafetyLevel == 'DAL-A'`, `Supplier == 'VendorX'`) or an allocation-driven hand-picked list ("all components realizing ControlUnit").
   - **(a) and (b) are linked.** A view filters on a property, so every property the user wants to view by must appear on the stereotype. If they want a by-supplier view, add a `Supplier` property. If they want a safety-critical view, add `SafetyLevel`. Ask (b) before finalising (a); the answers together determine the stereotype scope.
6. **Analysis needs** — is any quantitative roll-up or trade study analysis needed? If so, what kind?
7. **Decision context** — anything about the decision context here that isn't obvious from the SRs? Past incidents that shape risk tolerance, organizational constraints, dependent programs, stakeholder or political considerations. This answer seeds `decisions.md` with meaningful backstory so later design choices have the "why" captured alongside the "what".

**Do not ask the user for physical subsystems up front.** The physical
architecture is *derived* from the functional architecture, the logical
architecture, and the SRs — not specified a priori. If the user volunteers a
physical decomposition, note it but do not commit to it; the Phase 4 proposal
must still be driven by what the L→P mapping and hardware-specific SRs require.

After gathering answers, create the MATLAB Project inline (not as a saved
script — the `scripts/` folder doesn't exist yet). Use the MBSE wrapper
[`code/setupMBSEProject.m`](code/setupMBSEProject.m), which pins the RFLPV
folder set on top of `setupProject` from `matlab-project`:

```
setupMBSEProject(projectName, projectFolder)
```

The wrapper expands to:

```matlab
setupProject(projectName, projectFolder, ...
    {'requirements','architecture','analysis','verification','scripts'}, ...
    {fullfile('derived','cache'), fullfile('derived','codegen')});
```

**Generate three files into `scripts/`** so they are on the project path
together: `setupMBSEProject.m`, the generic `setupProject.m` (copy from
[`../matlab-project/code/setupProject.m`](../matlab-project/code/setupProject.m)),
and `registerWithProject.m` (copy from
[`../matlab-project/code/registerWithProject.m`](../matlab-project/code/registerWithProject.m)).
Run `setupMBSEProject(name, folder)`, confirm the project opens correctly, then
proceed.

For the project mechanics that follow — `addShortcut`, `removeFile` before
`delete`, build-script idempotency conventions, `runChecks` interpretation —
see [`../matlab-project/SKILL.md`](../matlab-project/SKILL.md).

### Seed the living documentation

Copy this skill's MBSE templates into the project root and fill placeholders
from the interview answers:

- `plan.md` — substitute `{{SystemName}}`, `{{OnePargraphDescription}}`,
  `{{RequirementsSource}}`, `{{ProjectFolder}}`, `{{EngineeringConcernsList}}`
  (Q5), `{{AnalysisScopeList}}` (Q6), `{{DecisionContext}}` (Q7). Leave Open
  questions / Known risks as starter bullets ("(none identified yet)") or carry
  any concerns raised during the interview.
- `decisions.md` — substitute `{{Date}}` (absolute date, e.g. `2026-04-18`),
  `{{SystemName}}`, and the same Phase 0 answers in the seeded first entry.

Templates: [`templates/plan.md`](templates/plan.md) and
[`templates/decisions.md`](templates/decisions.md) — these MBSE versions
override the generic ones in `matlab-project/templates/`. Register both with
the project (`addFile`) so they ship with the repo.

**MBSE-specific decisions to log in `decisions.md`** during the workflow:
- "shortened artifact prefix from full system name to make filenames manageable"
- "decomposed `CoordinateOperations` into 4 sub-functions per user preference"
- "added `PowerEstimate_W` to stereotype mid-project after initial scope explicitly excluded it"

Skip entries for SR-forced decisions, mechanical steps ("created the .prj file",
"imported 27 SRs from xlsx"), bug fixes, or API-level iteration.

---

## Phase 1: Requirements

Phase 1 has two entry modes. Use **Path A** when the user is developing
requirements from scratch in the interview, and **Path B** when the user
already has system requirements in an Excel file (Phase 0 question 4).

---

### Path A — Draft requirements from the interview

#### Propose

Based on the interview, draft:
- **Stakeholder Needs (SNs)** — 4–8 operational-perspective statements. Format: `SN-XXX-NNN`. Focus on what users/operators need, not how the system works.
- **System Requirements (SRs)** — 1–3 testable shall-statements per SN, each with a measurable acceptance criterion. Format: `SR-XXX-NNN`. Include at least 2 SRs for any budget/property cap identified in Phase 0.

Present these as a table for the user to review. Wait for approval or changes.

#### Generate

After approval, generate `scripts/buildRequirements.m` using patterns from the `simulink-requirements` skill. The script must:
- Delete and recreate both `.slreqx` files and their `.slmx` link files on every run
- Create all SNs, all SRs, and Derive links from each parent SN to its derived child SR(s) — `slreq.createLink(sn, sr); lnk.Type = 'Derive';` (SN is the source, SR is the destination)
- Use `slreq.clear()` at the top

#### Checkpoint

Show: requirement counts, derivation link count. Ask the user to confirm counts match what was approved.

---

### Path B — Import requirements from Excel

#### Clarify

Ask the user:
- **xlsx file path(s)** — one SR file, or separate SN and SR files? Full path to each.
- **Column mapping** — which columns correspond to Id, Summary, Description, Rationale? Default is 1–4 in that order. Read the header row with `readtable(..., 'VariableNamingRule','preserve')` and show it back before confirming.
- **Derive links** — if the xlsx has a parent-reference column (e.g. `DerivedFrom`), ask whether to rebuild Derive links from it. If yes, the SR import uses `attributeColumn` to preserve it as a custom attribute, and `buildRequirements.m` reads that attribute post-import to create `slreq.createLink(snId, srId); lnk.Type='Derive'` for each listed parent.
- **SN handling** — if the user only has SRs in Excel and no SN file, note that the downstream workflow will trace at the SR layer only (no upstream Derive links). Offer to synthesize placeholder SNs from SR summaries later if wanted.

#### Propose

Present a brief plan, e.g.:
> Import `SystemRequirements.xlsx` (16 rows) as editable set `SystemRequirements`, columns 1–4 mapped to Id/Summary/Description/Rationale, `DerivedFrom` (column 5) kept as a custom attribute. No SN file supplied — downstream traceability starts at SR.

Wait for approval.

#### Generate

Generate `scripts/buildRequirements.m` using the `importMyRequirements` helper from the `simulink-requirements` skill (see [`simulink-requirements/code/importMyRequirements.m`](../simulink-requirements/code/importMyRequirements.m)). The script must:
- Use `AsReference=false` so requirements are editable (imported copies, not read-only references to the xlsx)
- Pass `rows=[2 lastRow]` to skip the header row — otherwise the header becomes a requirement
- Explicitly call `reqSet.save()` — `slreq.import` does not save to disk on its own
- Register the `.slreqx` and its `~slreqx.slmx` with the project
- Be idempotent: delete the `.slreqx` and `.slmx` before re-importing

Note that `slreq.import` auto-creates a wrapping `Container` node named
`"<File>!<Sheet>"`, which would push every real requirement down to index
`1.1, 1.2, ...` in the Requirements Editor. The `importMyRequirements`
helper **unwraps this wrapper by default** (`flatten=true`), forward-promoting
each direct child to top level and removing the empty Container. Real nested
hierarchy (actual parent-child relationships in the source) is preserved —
only the auto-import wrapper is removed. Pass `flatten=false` to keep the
Container if you have a reason to (e.g. matching a legacy export).

#### Checkpoint

Show: requirement count (excluding the Container), the set name, any custom attributes preserved, and the first 2–3 requirements as a sanity check (Id, Summary, first part of Description). Ask the user to confirm the import looks right before moving to Phase 2.

---

## Phase 2: Functional Architecture

### Functional Analysis (propose first)

Before drafting any architecture, perform a functional analysis: work through each SR
and ask what the system must *do* to satisfy it. Present a derivation table:

```
SR-ID    Summary                          Function(s)
────────────────────────────────────────────────────────
SR-001   Roll rate command range          SenseAircraftState, ComputeControlLaws
SR-002   Pitch rate command range         SenseAircraftState, ComputeControlLaws
SR-003   Surface actuator response time   CommandControlSurfaces
...
```

Every SR must map to at least one function. If a function has no SRs, flag it —
it is either orphaned or covering an undocumented need. This table becomes the
Function → SR Implement link table in Phase 7.

Wait for approval on the SR → Function mapping before proceeding.

### Propose architecture

After the mapping is approved, propose:
- **Functions** — the unique set from the derivation table. For each: name (verb phrase), one-sentence description
- **Functional interfaces** — abstract information flows between functions. For each: name, semantic fields with types. Keep these at a logical level — no physical units or implementation detail yet
- **Connections** — data flow between functions

Note: functional architecture is independent of physical implementation — functions should reflect operational concepts from the SNs, not implementation decisions.

### Generate

After approval, generate `scripts/buildFunctional.m` using patterns from the `mbse-architecture` skill:
- Creates the functional interface dictionary (`MyFunctionalInterfaces.sldd`) with logical abstractions
- Creates the functional SC model, adds function components, typed ports, and connections
- No dependency on the physical model — this script runs independently
- `modelName` must be a double-quoted MATLAB string for `char(modelName) + ".slx"` to work
- Re-fetch interfaces after `dict.save()` before calling `setInterface`

Immediately after, also generate and run `scripts/buildFunctionalAllocation.m` and the shared helper `scripts/removeImplementLinksToModel.m`:
- `removeImplementLinksToModel(srSet, modelBasename)` iterates SR inLinks (Implement links go arch→req, so from a requirement's perspective they are inLinks) and removes only Implement links whose **source** `lnk.source().artifact` matches the given model basename — used by all three per-phase allocation scripts so each cleans up only its own links
- `buildFunctionalAllocation.m` calls this helper (scoped to the functional model), then creates Function → SR Implement links from the Phase 2 analysis table — `slreq.createLink(funcComp, req); lnk.Type = 'Implement'` (component is the source, requirement is the destination)
- After creating links, register **both** the model `.slx` AND the `{modelName}~mdl.slmx` link store file with the project. slreq creates `~mdl.slmx` automatically the first time you create a link into a Simulink/SC model — it lives next to the `.slx` and stores the link data. Without registering it, project file checks fail and the traceability won't travel with the project
- Calls `slreq.saveAll()` at the end
- Includes a header comment noting: re-run this whenever `buildFunctional.m` is re-run (SIDs change on rebuild); this script is superseded by `buildAllocation.m` in Phase 7

**Apply the same pattern in Phase 3 and Phase 4:** after `buildLogical.m`, generate and run `buildLogicalAllocation.m` (Logical → SR Implement links for non-functional reqs); after `buildPhysical.m`, generate and run `buildPhysicalAllocation.m` (Physical → SR Implement links for hardware-specific reqs and budget caps). Propose the SR → Logical and SR → Physical mapping tables for user approval before each. All three allocation scripts use the same `removeImplementLinksToModel` helper so they can run in any order without wiping each other out.

This gives the user immediate traceability at each architecture layer. Phase 7's `buildAllocation.m` will absorb and replace all three per-phase scripts.

### Checkpoint

Show: function count, interface count, connection count, Function→SR Implement link count. Ask user to confirm the functional model and traceability look right.

---

## Phase 3: Logical Architecture

### Propose

Based on the functional architecture, propose logical elements — design-agnostic solution
principles that answer "what *kind* of element solves this function?" without committing
to specific hardware or software:

- **Logical components** — typically 4–8. For each: name (noun describing the solution role,
  e.g. `SensingUnit`, `ControlUnit`, `ActuationUnit`), one-sentence role, which function(s)
  it realizes. Avoid hardware brand names or part numbers — those belong in Phase 4.
- **Logical interfaces** — intermediate-level signal types: typed fields with semantic meaning,
  but no datasheet-level specifics (no voltage ranges, baud rates, or tolerance values)
- **Connections** — signal flows between logical components

Present as a component list. Make clear to the user that this layer sits between
*what the system does* (Phase 2) and *how it is built* (Phase 4).

### Generate

After approval, generate `scripts/buildLogical.m` using patterns from the `mbse-architecture` skill:
- Creates the logical interface dictionary (`MyLogicalInterfaces.sldd`)
- Creates the logical SC model, adds logical components, typed ports, and connections
- No dependency on functional or physical model — runs independently
- `modelName` must be a double-quoted MATLAB string for `char(modelName) + ".slx"` to work
- Re-fetch interfaces after `dict.save()` before calling `setInterface`

### Checkpoint

Show: logical component count, interface count, connection count. Ask user to confirm the
logical model represents the right solution principles before moving to physical.

---

## Phase 4: Physical Architecture

### Propose

The physical components are **derived from** the logical architecture and the
SRs — they are not supplied by the user. Work out the decomposition by asking:
for each logical element, what concrete hardware/software unit realizes it
within the constraints set by the SRs (budgets, environment, interfaces)? Which
hardware-specific SRs (packaging, EMC, power, environmental) force a component
boundary to exist? Group and split logical elements along those lines.

Then propose:
- **Components** — typically 4–8 top-level physical components. For each: name, one-sentence
  role, which logical element(s) it implements, and which SR(s) force it to exist as a
  distinct unit
- **Physical interfaces** — implementation-level data/signal types with concrete fields,
  types, and units (e.g., `ElectricalPower` with Voltage/Current elements)
- **Connections** — which component ports connect to which

Present as a component list + connection diagram in text. Wait for approval.

If the user volunteered a physical decomposition in Phase 0, still derive the
proposal independently and then reconcile — call out any divergence so the user
can decide whether to override the derived structure or revisit the L→P mapping.

### Generate

After approval, generate `scripts/buildPhysical.m` using patterns from the `mbse-architecture`
and `system-composer` skills:
- Creates the physical interface dictionary (`MyPhysicalInterfaces.sldd`) with implementation-level interfaces
- Creates the SC model, adds components, ports, connections
- Applies auto-layout and saves
- No dependency on the logical or functional model — this script runs independently

### Checkpoint

Show: component count, connection count, any unconnected port warnings. Ask user to confirm the model opened in System Composer looks right.

---

## Phase 4b: Component Properties

### Propose

Based on the engineering concerns *and the view wishlist* identified in Phase 0 Q5, propose one or more stereotypes:

- **Stereotype name** — name it after what you are characterizing, not the analysis activity. e.g. `FlightProperties`, `HardwareProperties`, `ComponentCharacteristics`. Avoid names like `BudgetProperties` — a stereotype often carries mass, power, reliability, and latency together, so a budget-specific name is too narrow.
- **Properties** — for each: name, type (double/string/enum), unit, what it represents. **Cross-check against the view wishlist.** Every property a view needs to filter on must be on the stereotype; every property on the stereotype should serve at least one view or the rollup analysis. An orphan property is a sign the stereotype is over-scoped or the view list is incomplete.
- **Which components each stereotype applies to — leaves, composites, or both.** When the physical architecture contains composite assemblies (sub-components nested inside top-level components), this is a real design choice:
  - **Leaves only** (default, simpler): `prop == 0` review-dashboard views like `ZeroedEstimate_Flag` stay meaningful — composites don't false-positive because they have no stereotype. The analysis driver rolls up with a recursive `sumLeaves(instance, prop)` walker (see [`mbse-architecture/references/analysis.md`](../mbse-architecture/references/analysis.md) §"Leaves-only stereotype"). Composites are treated as structural containers.
  - **Both leaves and composites** (canonical `iterate + PostOrder`): the Analysis Viewer displays rolled-up values at every hierarchy level, not just leaves. Tradeoff: composites carry default-0 initial values in the design model, so any `prop == 0` review-dashboard view will false-positive on them until an analysis runs — and rollup results live on the analysis instance, not the design, so the view never actually clears.

  Pick leaves-only unless the user wants hierarchical display in the Analysis Viewer. The Phase 8 analysis pattern follows from this choice.
- **Initial estimates** — propose plausible starting values per component; user should correct these

Present as a table. Wait for approval.

### Generate

Add stereotype creation and application to `buildPhysical.m` (at the end, after the architecture is built), following the `mbse-architecture` profile patterns:
- Use `systemcomposer.profile.Profile.createProfile`
- Add stereotypes with `addStereotype`, properties with `addProperty`
- Apply to components with `applyStereotype`, set values with `setProperty`
- `profile.save()` requires a char path — not a string type

Re-run `buildPhysical.m` (idempotent — it rebuilds from scratch).

### Checkpoint

Show: stereotype name(s), property names and estimates per component. Ask user to confirm values are reasonable starting points.

---

## Phase 4c: Architecture Views

Views are filtered lenses on the physical model — named dashboards you can flip to in the SC canvas dropdown. Because they live *inside* the `.slx` (as `archViews.xml`), a physical-model rebuild wipes them, so this step runs **after** `buildPhysical.m` and is idempotent itself.

### Propose

Based on the view wishlist from Phase 0 Q5(b), propose a concrete set of view specs. For each:

- **Name** — PascalCase, descriptive (`CostDrivers`, `HighPowerConsumers`, `SafetyCritical`, `VendorXComponents`, `ZeroCost_Flag`).
- **Query** — either a stereotype-property comparison (`Cost_credits > 150000`, `SafetyLevel == 'DAL-A'`) or a note that it's an explicit-element list (allocation-driven).
- **Color** — hex (`#D62728` red, `#FF7F0E` orange, `#2CA02C` green, etc.). Named colors like `red`/`blue` work but only a subset — `magenta` errors out. Prefer hex.
- **What it surfaces** — one-line purpose, e.g. "first targets for trimming when SR-XXX fails".

Suggested starter pack (adjust to the project):

| View | Query | Purpose |
|---|---|---|
| `CostDrivers` | `Cost > 10% of budget` | Trim targets when SR-cost fails |
| `HighPowerConsumers` | `Power > 10% of cap` | Margin-miss contributors |
| `HeavyStructure` | `Mass > threshold` | Chassis / bulk hardware review |
| `ZeroCost_Flag` (or any budget property) | `prop == 0` | Catches forgotten estimates before PostOrder rollup silently treats them as 0 |
| `<ProductionPipeline>` | `Throughput > 0` | Bottleneck-analysis members |

Present as a table. Wait for approval.

### Generate

Generate `scripts/buildViews.m` using the `buildMyViews` helper from the `system-composer` skill (see [`system-composer/code/buildMyViews.m`](../system-composer/code/buildMyViews.m)). The script:
- Takes a cell-array of specs `{name, prop, op, value, color}`
- Calls `createView(model, name, Select=q, Color=color)` for each
- Is idempotent — `deleteView` before `createView` on every run
- Must run *after* `buildPhysical.m`; add it to `buildAll.m` between the Physical step and the F→L allocation step

Re-run and open the Views Gallery: `openViews(systemcomposer.openModel('<Model>'))`.

### Checkpoint

Show: view name, query, color, and match count per view. The `ZeroCost_Flag` view should ideally report 0 matches; if it reports a positive count, those components have un-filled estimates.

### For allocation-driven or hand-picked views

Single-property queries don't cover every useful view (e.g. "all Physical components realizing ControlUnit logicals"). For those, `buildViews.m` can also use the explicit-element pattern:

```matlab
v = createView(model, 'ControlRealization', Color='#1F77B4');
% walk the L->P allocation set and addElement for each Physical target
for ...
    v.Root.addElement(arch.lookup('Path', physPath));
end
```

Use query-driven views where a single property suffices; reach for explicit elements only when the grouping criterion is relational (allocation, supplier partition, certification path).

---

## Phase 5: F→L Allocation Set

### Propose

Map each logical function to the logical element(s) that realize it. Present as a two-column table:

```
Function                    Logical Element(s)
───────────────────────────────────────────────
FunctionA               →   SensingUnit
FunctionB               →   ControlUnit
FunctionC               →   ControlUnit, ActuationUnit
```

Wait for approval or corrections.

### Generate

After approval, generate `scripts/buildFunctionalToLogical.m` using patterns from the
`mbse-architecture` skill:
- `AllocationSet.closeAll()` then delete the `.mldatx` file before recreating
- `createAllocationSet` name must differ from the file base name — append `'Set'` to avoid the "name must be unique" save error
- Use `createScenario(allocSet, 'FunctionalToLogical')`
- Both models must be open: `addpath(archDir)` then `openModel` by name for each

### Checkpoint

Show the F→L allocation table. Ask user to confirm every function is covered.

---

## Phase 6: L→P Allocation Set

### Propose

Map each logical element to the physical component(s) that implement it. Present as a two-column table:

```
Logical Element             Physical Component(s)
─────────────────────────────────────────────────
SensingUnit             →   ComponentX
ControlUnit             →   ComponentY
ActuationUnit           →   ComponentX, ComponentZ
```

Wait for approval or corrections.

### Generate

After approval, generate `scripts/buildLogicalToPhysical.m` — same pattern as Phase 5
but with the logical and physical models as source and destination:
- Use `createScenario(allocSet, 'LogicalToPhysical')`

### Checkpoint

Show the L→P allocation table. Ask user to confirm every logical element maps to at least one physical component.

---

## Phase 7: Requirements Allocation

### Propose

Present three allocation tables for user review:

**Table 1 — SR → Function** (reuse the derivation table from Phase 2 Functional Analysis):
```
SR-ID    Function(s)
────────────────────────────────────
SR-001   SenseAircraftState, ComputeControlLaws
SR-002   ComputeControlLaws
...
```
Every SR must appear here. This is mandatory.

**Table 2 — SR → Logical component** (non-functional requirements):
Use for: timing, performance, safety, security, or requirements specific to a logical role.
```
SR-ID    Logical Component(s)
────────────────────────────────────
SR-005   ControlUnit
SR-008   SensingUnit, ControlUnit
...
```

**Table 3 — SR → Physical component** (hardware-specific requirements):
Use for: hardware specs, environmental constraints, EMC ratings, packaging, installation.
```
SR-ID    Physical Component(s)
────────────────────────────────────
SR-011   PowerSystem
SR-014   ActuatorSystem, PowerSystem
...
```

An SR may appear in multiple tables. Flag any SR with no entry in Table 1 — every SR
must trace to at least one function. Wait for approval before generating.

### Generate

After approval, generate `scripts/buildAllocation.m` using patterns from the `mbse-architecture` skill:
- Remove existing Implement links before recreating (idempotent)
- Open all three models: `MyFunctional`, `MyLogical`, `MySystem`
- Use `fileparts(fileparts(mfilename('fullpath')))` for the project root — never `'..'` in paths passed to System Composer
- `addpath(archDir)` then `openModel` by model name, not full path
- Call `slreq.saveAll()` at the end

### Checkpoint

Show: SR → Function link count, SR → Logical link count, SR → Physical link count. Flag any SR missing from Table 1.

---

## Phase 8: Analysis (Optional)

If the user indicated no analysis is needed in Phase 0, skip this phase entirely.

Otherwise, ask:
- **What to compute** — roll-up sums (mass, power, cost)? Margins against caps? Sensitivity? Pareto?
- **Budget caps** — are any system-level limits defined in SRs? (Parse from requirement descriptions using the `parseBudgetValue` pattern from `mbse-analysis`)
- **What to write back** — computed values (margins, roll-ups) can be written back to the analysis instance via `setValue`

### Generate

Generate `scripts/runAnalysis.m` using patterns from the `mbse-analysis` skill:
- `instantiate(arch, profileName, 'AnalysisName')` creates the instance
- `getValue(ci, [prefix, 'PropertyName'])` returns double — no `str2double` needed
- `save(instance, fullfile(analysisDir, 'AnalysisName.mat'))` for Analysis Viewer — save to `analysis/`, not `architecture/`
- Open with `systemcomposer.analysis.openViewer('AnalysisName')` (instance name, not file path)

### Checkpoint

Show the analysis report output. Flag any margins that are negative (over budget). Ask user to confirm.

---

## Optional: behavioral views (sequence diagrams)

When the structural architecture is stable, a sequence diagram adds the
"how the pieces collaborate over time" story. Typical trigger: a
stakeholder review where reviewers ask "walk me through what happens
during a normal X" — production cycle, fault handling, startup, etc.

Best authored on the **logical** model. The logical layer is stable
across variant trade studies (variants typically only change the
physical layer), so a sequence diagram written there survives
architecture-options work.

Use [System Composer Interactions](../system-composer/SKILL.md#sequence-diagrams)
programmatically — every message is bound to a real port pair on the
underlying components, so a port rename surfaces as a build error
instead of silent drift.

The build step typically runs LAST in `buildAll` because it attaches
an interaction to a model that's already been built by its own build
script — the architecture rebuild wipes interactions, so the sequence
diagram must be re-created after.

**Requirement traceability caveat on R2025b:** a `Verify` link from a
sequence-diagram Interaction to an SR cannot coexist with
`linktype_rmi_simulink` Implement links on the same `.slx` — see the
[`simulink-requirements` Common Pitfalls section](../simulink-requirements/SKILL.md#common-pitfalls)
for details. For now, trace from the diagram to SRs by convention (a
named interaction + a companion TC that references it by name).

Skip this phase entirely if a behavioral view adds no review value;
nothing else in the workflow depends on it.

---

## Phase 9: Test Cases

### Propose

For each SR, propose one test case (TC) with:
- **ID** — `TC-XXX-NNN` matching the SR number
- **Description** — concise test procedure: what stimulus, what measurement, what pass criterion

Present as a table. Wait for approval or edits.

Note: SR-NNN for property/budget caps (e.g. total mass budget) are typically verified by the analysis script, not a test case — it is acceptable for these to show as "NOT COVERED" in the coverage report.

### Generate

After approval, generate `scripts/buildTestCases.m` using patterns from the `simulink-requirements` skill.

**Use the load-or-clear-and-repopulate idempotency pattern**, not delete-and-new.
In long build pipelines (e.g. `buildAll.m` running phases 1–9 back to back),
`slreq.new(tcFile)` intermittently fails with `name conflict with TestCases.slreqx`
even after `slreq.clear()` and a seemingly-successful `delete(tcFile)`. The
robust recipe:

```matlab
slreq.clear();
srSet = slreq.load(srFile);

if isfile(tcFile)
    tcSet = slreq.load(tcFile);

    % Clear the LinkSet first — req.remove() leaves orphan outLinks in the
    % .slmx that produce "unresolved source" warnings on reload.
    lnkSets = slreq.find('type','LinkSet','Artifact', tcFile);
    for i = 1:numel(lnkSets)
        links = lnkSets(i).getLinks();
        for j = 1:numel(links), links(j).remove(); end
    end

    existing = tcSet.find('Type','Requirement');
    for k = numel(existing):-1:1, existing(k).remove(); end
else
    tcSet = slreq.new(tcFile);
end

% ... add TCs and Verify links ...
tcSet.save();
slreq.saveAll();
```

- Create one TC requirement per SR, link with `Verify` type
- Call `slreq.saveAll()` at the end

### Checkpoint

Show: TC count, verification coverage report (SR IDs vs TC IDs). Flag any SRs without a TC other than expected budget-cap SRs.

---

## Phase 10: Build All and Final Summary

Verification in this workflow is a single layer: the `TestCases.slreqx` set
built in Phase 9 contains one prose TC per SR with a `Verify` link to that SR.
That is the full extent of the verification artifact set — no `.mldatx` test
file is generated.

### Generate buildAll.m

Generate `scripts/buildAll.m` that calls all phase scripts in order with timing
output. This is the single entry point for a clean rebuild from scratch.

After all phase scripts complete, `buildAll.m` must:
1. Call `registerWithProject` for **all** script files in `scripts/` (keeps the project in sync — include `setupProject.m`, `setupMBSEProject.m`, `registerWithProject.m`, `removeImplementLinksToModel.m`, every `build*.m`, `runAnalysis.m` if applicable)
2. Append the **project health check block** from [`../matlab-project/SKILL.md`](../matlab-project/SKILL.md) (the `runChecks` loop with PASS/FAIL output) verbatim — that block is generic and lives in the `matlab-project` skill so updates only need to land in one place

### Final summary

Present a complete artifact inventory:

```
Project: <Name>  (<root folder>)
├── <Name>.prj
├── plan.md                            (living project overview)
├── decisions.md                       (append-only decision log)
├── requirements/
│   ├── StakeholderNeeds.slreqx        (N items)
│   ├── SystemRequirements.slreqx      (N items)
│   └── TestCases.slreqx               (N items)
├── architecture/
│   ├── <Name>Functional.slx           (functional model — Phase 2)
│   ├── <Name>FunctionalInterfaces.sldd
│   ├── <Name>Logical.slx              (logical model — Phase 3)
│   ├── <Name>LogicalInterfaces.sldd
│   ├── <Name>Physical.slx             (physical model — Phase 4)
│   ├── <Name>PhysicalInterfaces.sldd
│   ├── <Name>Profile.xml              (stereotype profile — Phase 4b)
│   ├── <Name>FunctionalToLogical.mldatx  (F→L allocation — Phase 5)
│   └── <Name>LogicalToPhysical.mldatx    (L→P allocation — Phase 6)
├── analysis/
│   └── <analysis>.mat                 (analysis instance, if Phase 8 ran)
└── scripts/
    ├── buildAll.m                      (run this to rebuild everything)
    ├── buildRequirements.m
    ├── buildFunctional.m
    ├── buildLogical.m
    ├── buildPhysical.m
    ├── buildFunctionalToLogical.m
    ├── buildLogicalToPhysical.m
    ├── buildAllocation.m
    ├── runAnalysis.m                   (if Phase 8 ran)
    └── buildTestCases.m

Traceability:
  SN ─[Derive]─▶ SR ◀─[Implement]─ LogicalComponent  (or PhysicalComponent)
                                        ▲
                                    [L→P Allocate]
                                        │
                                  LogicalElement
                                        ▲
                                    [F→L Allocate]
                                        │
                                   Function
  SR ─[Verify]─▶ TC requirement
```

Remind the user they can rebuild everything cleanly at any time with `buildAll()`.

---

## Handling rollback

If the user rejects a checkpoint:
1. Ask what specifically needs to change
2. Revise the proposed content
3. Re-present for approval
4. Regenerate the script with the changes
5. Re-run and re-checkpoint
6. **Append a `decisions.md` entry** capturing the original choice, the reason for the change, and what replaced it — don't rewrite earlier entries. Rollbacks are high-signal moments; failing to log them is how projects lose their "why".

Because every script deletes and recreates its artifacts from scratch, there is no state to undo — just regenerate.
