---
name: matlab-project
description: >
  Use this skill for any work involving a MATLAB Project (.prj file) — creating
  a new project, tracking files, managing the project path, configuring Simulink
  cache and code-generation folders, running project health checks, or writing
  build scripts that keep the project in sync with the file system. Trigger
  phrases include "set up a MATLAB project", "create a .prj", "track this file
  in the project", "project health check", "build script conventions". This
  skill is the generic foundation; domain-specific skills (e.g. `mbse-workflow`)
  build on it.
---

# MATLAB Project — Setup, Conventions, and Build-Script Patterns

A MATLAB Project (`.prj`) is a single file that manages path, tracked artifacts,
shortcuts, derived-output locations, and health checks. This skill covers the
mechanics so every downstream workflow (requirements, architecture, analysis,
anything else) can rely on a predictable project shape.

Domain skills reuse this skill's helpers (`setupProject`, `registerWithProject`)
and conventions (idempotent build scripts, `removeFile` before `delete`,
`runChecks` at the end of `buildAll`). They may override the living-doc
templates with domain-specific versions.

---

## Creating a project

Use [`code/setupProject.m`](code/setupProject.m) to create the project inline
(not as a saved script — the `scripts/` folder doesn't exist yet):

```matlab
setupProject(projectName, projectFolder, subfolders, derivedSubfolders)
```

- `subfolders` — cell array of folders that are created, added as tracked
  project files, and placed on the MATLAB path. Callers choose the layout.
- `derivedSubfolders` — cell array of folders for build outputs. Created but
  **not tracked**. The first two entries are wired to `SimulinkCacheFolder`
  and `SimulinkCodeGenFolder` if supplied, so Simulink cache / codegen stays
  out of source control.

Example (MBSE shape):

```matlab
setupProject("MySystem", "C:\work\MySystem", ...
    {'requirements','architecture','analysis','verification','scripts'}, ...
    {fullfile('derived','cache'), fullfile('derived','codegen')});
```

### Path management rule

**Every tracked folder that is supposed to be on the path must be registered
with both `addFolderIncludingChildFiles` *and* `addPath`.** If you only do the
first, `runChecks` later fails with `Project:Checks:ProjectPath` ("a folder is
on the MATLAB path but not registered as a project path folder"). `setupProject`
handles this for the initial folder set; any folder added later must follow the
same pattern.

### Why no `startup.m`

A `startup.m` is unnecessary when build scripts are idempotent and self-cleaning
(each script clears its own state at the top — see below). Adding one introduces
hidden state that survives between runs and tends to mask bugs. Leave it out.

---

## File lifecycle — tracking, shortcuts, removal

### Tracking files as they're created

Use the [`code/registerWithProject.m`](code/registerWithProject.m) helper from
every build script. It is idempotent and a no-op if no project is open:

```matlab
registerWithProject({fileA, fileB, ...}, {folderA, ...})
```

Each build script should call this at the end, passing the files it created.
`buildAll.m` additionally registers all script files. This keeps the project
in sync with the file system without any manual `addFile` bookkeeping.

### Shortcuts

`addShortcut(proj, filePath)` (no label argument) adds a file to the project's
Shortcuts panel. Add shortcuts progressively as key files are created — typical
targets: the top-level build script, the main model, the primary data file.

### Removing tracked files

**Always call `removeFile` before `delete`** when getting rid of a tracked file.
A bare `delete()` removes the file from disk but leaves a broken reference in
the project, causing `runChecks` failures:

```matlab
proj = currentProject();
removeFile(proj, fullfile(archDir, 'OldArtifact.sldd'));  % untrack first
delete(fullfile(archDir, 'OldArtifact.sldd'));             % then remove from disk
```

This matters whenever a build script replaces an artifact with a new name — the
old tracked entry must be removed explicitly.

---

## Build-script idempotency conventions

Any build script that writes tracked artifacts should follow these rules so
`buildAll.m` can run any phase in any order without accumulating stale state:

1. **Clear state at the top.** For MATLAB it is often enough to `clear` nothing
   and rely on the delete-and-recreate step. For toolboxes with in-memory
   state (e.g. `slreq.clear()`, `Profile.closeAll()`), call their reset APIs
   as the first action.
2. **Delete the target artifacts before recreating them.** Guard every file
   op with `isfile` / `isfolder` so the first run (when files don't exist)
   and later runs (when they do) take the same path.
3. **Recreate artifacts from scratch.** Never mutate an existing file in place.
4. **Call `registerWithProject` at the end**, passing every artifact the
   script produced. The helper is a no-op if a file doesn't exist, so
   conditional artifacts (link-store files that only appear when links are
   created) are safe to pass unconditionally.

This pattern is what lets users rebuild everything cleanly by calling
`buildAll()` — there is no state to undo, just regenerate.

---

## `buildAll.m` shape

The top-level orchestrator script calls each phase / build script in order,
then registers the script files themselves, then runs project health checks:

```matlab
%% Register all scripts with the project
scriptsDir = fileparts(mfilename('fullpath'));
scriptFiles = { ...
    fullfile(scriptsDir, 'buildAll.m'), ...
    % ... every other script the project uses ...
    fullfile(scriptsDir, 'registerWithProject.m'), ...
};
registerWithProject(scriptFiles);

%% Project health check
proj = matlab.project.currentProject();
if ~isempty(proj.Name)
    results = runChecks(proj);
    nFail = 0;
    fprintf('\nProject checks:\n');
    for i = 1:numel(results)
        if results(i).Passed
            fprintf('  [PASS] %s\n', results(i).Description);
        else
            fprintf('  [FAIL] %s\n', results(i).Description);
            for j = 1:numel(results(i).ProblemFiles)
                fprintf('           %s\n', results(i).ProblemFiles(j));
            end
            nFail = nFail + 1;
        end
    end
    if nFail == 0
        fprintf('All checks passed.\n');
    else
        fprintf('%d check(s) failed — review output above.\n', nFail);
    end
end
```

`runChecks` runs 8 built-in project checks including file existence, path
consistency (`Project:Checks:ProjectPath`), unsaved files, and SLPRJ folder
placement. The most common failure is `Project:Checks:ProjectPath` — fix with
`addPath(proj, folderPath)` on the offending folder.

---

## Living documentation: `plan.md` and `decisions.md`

Projects built with this skill carry two hand-curated markdown files at the
project root. They are *not* build outputs — they preserve context a future
reader otherwise couldn't recover from the code alone.

| File | Purpose | Update cadence |
|---|---|---|
| `plan.md` | Canonical overview: scope, source artifacts, milestone status, open questions, known risks. | At each milestone and whenever scope or constraints change. |
| `decisions.md` | Append-only log of non-obvious decisions — each with context, options, rationale, revisit trigger. | Append at any checkpoint where the chosen approach wasn't forced by the inputs, and at every rollback. |

Templates live at [`templates/plan.md`](templates/plan.md) and
[`templates/decisions.md`](templates/decisions.md). Copy both into the project
root during setup, fill placeholders, and register them with the project so
they ship with the repo:

```matlab
proj = currentProject();
addFile(proj, fullfile(proj.RootFolder, 'plan.md'));
addFile(proj, fullfile(proj.RootFolder, 'decisions.md'));
```

**Override for domain skills.** Any domain skill (e.g. `mbse-workflow`) may
ship its own `plan.md` / `decisions.md` templates under its own `templates/`
folder and use those *instead* of the generic ones here. Overrides should
keep the core section order (Overview → Source artifacts → Status → Open
questions → Known risks) so readers moving between projects find familiar
anchors. Add domain-specific sections below the core set.

**When to append a decisions entry:** only when a judgment call was made.
Mechanical steps and input-forced decisions don't belong. Good examples:
"shortened artifact prefix from full system name to make filenames
manageable"; "split module X into four sub-modules per user preference"; "added
property Y mid-project after initial scope excluded it". Bad examples: "created
the .prj file"; "imported 27 rows from xlsx".

**When to skip an entry:** bug fixes, API iteration, rerunning a script after
an error, or anything that reflects tooling friction rather than design
judgment.

---

## Quick reference

| Task | Call |
|---|---|
| Create project | `setupProject(name, folder, subfolders, derivedSubfolders)` |
| Track files/folders after creation | `registerWithProject(files, folders)` |
| Add a shortcut | `addShortcut(proj, filePath)` |
| Remove a tracked file | `removeFile(proj, path)` **then** `delete(path)` |
| Ensure folder is on path | `addPath(proj, folderPath)` |
| Health check | `runChecks(proj)` (see `buildAll.m` shape above) |
