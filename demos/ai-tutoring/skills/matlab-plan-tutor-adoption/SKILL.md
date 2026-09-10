---
name: matlab-plan-tutor-adoption
description: Use when an instructor asks for a MATLAB AI tutor setup guide, adoption guide, pilot plan, course-specific rollout, or recommended tutor configuration based on a learning objective, course title, course description, module description, or lab description.
license: https://www.mathworks.com/content/dam/mathworks/license/pmrl/license.md
metadata:
  author: MathWorks
  version: "1.0"
---

# MATLAB AI Tutor Instructor Setup Guide

## Purpose

Generate a short instructor-facing setup guide that fits the provided learning
objective, course title, course description, module description, or lab
description.

Treat the user's provided objective or course description as the guide input. If
the input is missing, ask for one sentence describing the course, module, or
learning objective before generating the guide.

## Input Handling

Use the input argument to infer the best-fit teaching context:

- introductory MATLAB programming course;
- engineering computation course;
- data analysis lab;
- graded homework, lab, project, quiz, or exam support;
- mixed or uncertain context.

If multiple contexts fit, choose the primary context and add a short note about
secondary considerations. Do not ask follow-up questions unless the input is too
vague to identify a course goal.

## Guide Workflow

1. Restate the inferred course or learning objective in one sentence.
2. Identify the best-fit teaching context and why it fits.
3. Recommend the MATLAB AI tutor skill sequence for that context.
4. Provide an instructor-ready starter prompt that can be used with students.
5. Define guardrails for assignment or assessment use.
6. Recommend `matlab-create-ai-policy` when the instructor needs a
   learner-facing AI-use policy or local tutoring-session enforcement file.
7. Propose a first-week pilot activity with one MCQ, one hands-on task, and one
   reflection or transcript/report review step.
8. Explain how to review session reports and transcripts.
9. Include a short revision loop: what the instructor should adjust after the
   first 5-10 sessions.

Read [references/setup-guide-template.md](references/setup-guide-template.md)
for context mapping, output format, and adaptation rules.

Read [references/research-summary.md](references/research-summary.md) when the
user asks for research basis, evidence, rationale, literature mapping, or an
instructor-facing explanation of why the recommended tutor behaviors are used.

## Output Rules

- Default to Markdown unless the user asks for another format.
- Keep the guide practical enough for an instructor to use without extra setup.
- Include concrete prompt text, not only advice.
- When the instructor asks for a demo, pilot, or adoption walkthrough, point to
  `assets/demo-kit/instructor-demo-kit-guide.md` (relative to the demo folder
  that contains `skills/`) and select only the demo-kit pieces that match their
  course context.
- Use course-appropriate guardrails: stricter for graded work, lighter for
  optional practice.
- Include `matlab-log-tutor-sessions`, `matlab-report-tutor-sessions`,
  and `matlab-evaluate-tutor-quality` when the guide involves instructor review.
- Do not invent course policies. If policy is not provided, write a conservative
  default and mark it as adjustable.
- Include a brief research-basis section only when requested or when the guide is
  intended for instructor adoption, departmental review, or pilot approval.
