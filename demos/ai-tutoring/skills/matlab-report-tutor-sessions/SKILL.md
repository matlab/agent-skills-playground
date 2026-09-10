---
name: matlab-report-tutor-sessions
description: Use when a learner or instructor asks for a report, summary, reflection, progress note, performance recap, activity metrics, instructor-shareable record of a MATLAB AI tutoring session, aggregate report across multiple MATLAB tutoring session reports, or instructor dashboard artifact with metric drilldowns. Supports optional start and end datetime arguments for multi-session report and dashboard ranges.
license: https://www.mathworks.com/content/dam/mathworks/license/pmrl/license.md
metadata:
  author: MathWorks
  version: "1.0"
---

# MATLAB AI Tutor Session Report

## Purpose

Create clear HTML reports for MATLAB tutoring. Single-session reports help the
learner reflect on what was covered, what they demonstrated, where they need
more practice, and what evidence supports those conclusions. Aggregate reports
summarize patterns across multiple session reports for instructor review,
including recurring misconceptions, topic coverage, activity metrics, revision
behavior, and unresolved growth areas. Instructor dashboard artifacts present
the same evidence as a compact HTML dashboard with in-page drilldown panels for
key metrics.

Use this skill with:

- `matlab-tutor-learners`
- `matlab-coach-programming`
- `matlab-create-hands-on-exercises`
- `matlab-create-mcq-practice`
- `matlab-coach-debugging`
- `matlab-log-tutor-sessions`
- `matlab-evaluate-tutor-quality`

## Reporting Principles

- Base the report only on evidence from the current session or provided
  transcript.
- Do not infer grades, exam readiness, or personal traits beyond the evidence.
- Separate observed performance from recommendations.
- Use supportive, factual language that helps the learner plan next steps.
- If a metric is unavailable, write "Not observed" or "Not enough data" rather
  than estimating.
- Keep instructor-shareable notes professional and concise.
- Do not include sensitive personal information unless the learner explicitly
  asks to include it.
- Produce an HTML file by default, not Markdown, unless the user explicitly asks
  for another format.

## Mode Selection

- Use **single-session mode** when the user asks for a report of the current
  session, a provided transcript, or one tutoring interaction.
- Use **aggregate mode** when the user asks for multiple sessions, session
  analytics, progress over time, report aggregation, a date range, or an
  instructor overview across reports.
- Use **dashboard mode** when the user asks for an instructor dashboard,
  dashboard artifact, metric dashboard, drilldown view, or compact overview of
  key metrics across session reports.
- Use **quality dashboard mode** when the dashboard is based on transcript
  reviews or tutor quality reports rather than learner session reports. Include
  MATLAB accuracy, active learning, assignment guardrails, feedback quality,
  debugging support, and transfer prompt metrics.

## Single-Session Report Workflow

1. Identify the session context: topic, course context if given, practice mode,
   and learner goal.
2. Extract topics covered and the evidence for each topic.
3. Summarize learner strengths by topic.
4. Summarize growth areas by topic.
5. Compute activity metrics from observed MCQs, hands-on exercises, and
   debugging tasks.
6. Summarize important MATLAB evidence: script results, Code Analyzer feedback,
   test outcomes, error messages, or output mismatches.
7. Recommend 2-4 next practice actions.
8. Include an instructor-shareable summary if requested or useful.
9. Save the report as an `.html` file using the required filename pattern.

Read [references/report-template.md](references/report-template.md) for the
complete single-session and aggregate report formats, metric definitions, and
date-range rules.

This demo includes an example report at
`assets/examples/session-report-example.html`, relative to the demo folder that
contains `skills/` (not relative to this skill folder). Use it as a
visual and structural example when creating reports, but replace its fictional
session content with evidence from the current session.
When that file is not available (for example when only `skills/` was
installed), follow the template in `references/report-template.md` alone.

## File Naming

Autoname each report:

```text
matlab-ai-tutor-session-YYYY-MM-DD-HHMMSS.html
```

Use the local session start datetime when available (not the report-generation
time). If no session start was recorded, use the report-generation time and say
so in the report header. Use 24-hour time. Omit colons from the time so the
filename is portable across operating systems. Example:

```text
matlab-ai-tutor-session-2026-06-02-143015.html
```

If saving into a course or learner folder, keep this base filename and only
change the directory.

For aggregate reports, use:

```text
matlab-ai-tutor-aggregate-YYYY-MM-DD-to-YYYY-MM-DD.html
```

If the user supplies precise start and end datetimes, use:

```text
matlab-ai-tutor-aggregate-YYYY-MM-DD-HHMMSS-to-YYYY-MM-DD-HHMMSS.html
```

Use the earliest and latest included session dates when no date range arguments
are provided.

For instructor dashboard artifacts, use:

```text
matlab-ai-tutor-dashboard-YYYY-MM-DD-to-YYYY-MM-DD.html
```

If the user supplies precise start and end datetimes, use:

```text
matlab-ai-tutor-dashboard-YYYY-MM-DD-HHMMSS-to-YYYY-MM-DD-HHMMSS.html
```

## Aggregate Report Arguments

Aggregate and dashboard modes accept two optional arguments:

1. `start_datetime`: earliest session report datetime to include.
2. `end_datetime`: latest session report datetime to include.

If both arguments are provided, include session reports whose report datetime is
within the inclusive range. Accept common datetime formats such as
`YYYY-MM-DD`, `YYYY-MM-DD HH:MM`, and `YYYY-MM-DD HHMMSS`.

If no arguments are provided, use all available MATLAB AI Tutor session reports
in the current working directory for this tutoring session. Match files named
like `matlab-ai-tutor-session-YYYY-MM-DD-HHMMSS.html` and exclude aggregate
reports unless the user explicitly asks to include them.

## Aggregate Report Workflow

1. Find candidate single-session HTML reports in the current working directory.
2. Parse each report datetime from the filename first, then from the report
   header if needed.
3. Filter reports by `start_datetime` and `end_datetime` when provided.
4. Extract visible metrics and evidence from the included reports. Do not invent
   missing values.
5. Aggregate topic coverage, MCQ results, hands-on script results, debugging
   tasks, revision behavior, and unresolved growth areas.
6. Identify recurring misconceptions and repeated strengths only when supported
   by more than one report or by explicit repeated evidence.
7. Include a table of included reports with dates, focus, and evidence basis.
8. Save a standalone HTML aggregate report using the aggregate filename pattern.

## Dashboard Artifact Workflow

1. Use the same report discovery, datetime parsing, and date-range filtering as
   aggregate mode.
2. Build one standalone HTML file. Do not require separate CSV files unless the
   user explicitly asks for export files or an implementation uses CSV as a
   temporary intermediate.
3. Show dashboard cards for key metrics. For learner session dashboards, include
   MCQ accuracy by topic, hands-on script pass rate, common debugging patterns,
   Code Analyzer issues, and unresolved topics needing instructor follow-up. For
   tutor quality dashboards, include MATLAB accuracy, active learning,
   assignment guardrails, feedback quality, debugging support, and transfer
   prompts.
4. Add drilldown controls for each key metric. Each control should open an
   in-page panel, modal, or expandable section with the supporting sessions,
   evidence snippets, affected topics, and recommended instructor action.
5. Include an "Included Reports" section and an "Evidence Limits" section so the
   instructor can see exactly what was and was not counted.
6. Save the dashboard using the dashboard filename pattern.

## Metrics to Track

Track only metrics visible in the session:

- **MCQs**: attempted, correct, incorrect, skipped, accuracy, most common
  misconception.
- **Hands-on exercises**: attempted, completed, passed on first run, passed
  after revision, unresolved, MATLAB execution result, Code Analyzer issues.
- **Debugging tasks**: errors investigated, root causes identified, repairs
  verified, minimal reproductions created.
- **Engagement evidence**: predictions made, explanations given, tests designed,
  revisions attempted, transfer tasks completed.

## Topic-Level Strengths and Growth Areas

For each major topic, include:

- **Topic**: MATLAB concept or workflow.
- **Evidence**: learner answer, code behavior, execution result, or feedback
  moment.
- **Strength**: what the learner demonstrated.
- **Growth area**: what still needs practice.
- **Recommended next step**: one focused action.

Avoid generic comments such as "needs more practice" without naming the MATLAB
behavior to practice.

## Instructor-Shareable Notes

When creating an instructor-shareable section:

- Keep it factual and evidence-based.
- Avoid overly personal phrasing.
- Include enough detail to support instructional follow-up.
- Make clear whether the report is based on a complete session transcript or
  only the visible conversation.

Use this framing:

```text
This report summarizes the observed tutoring session. It is not a formal grade.
Metrics reflect only activities completed in the session.
```

## When Data Is Missing

If the session did not include MCQs, hands-on exercises, or debugging tasks, do
not invent metrics. Instead, include:

```text
No MCQs were attempted in this session.
No hands-on MATLAB script was executed in this session.
No debugging task was worked in this session.
```

## Output Length

Default to a concise report that an instructor could skim in 2-3 minutes. If the
session was long, multiple reports are included, or the learner asks for detail,
include a longer topic-by-topic appendix.
