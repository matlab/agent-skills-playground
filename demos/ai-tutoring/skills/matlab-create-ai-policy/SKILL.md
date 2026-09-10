---
name: matlab-create-ai-policy
description: Use when an instructor wants to create, interview for, configure, install, update, or review a course AI-use policy for MATLAB AI tutoring. Produces an AI-POLICY.md file for LMS sharing and local tutoring-session enforcement by assignment guardrails.
license: https://www.mathworks.com/content/dam/mathworks/license/pmrl/license.md
metadata:
  author: MathWorks
  version: "1.0"
---

# MATLAB AI Tutor Course Policy

## Purpose

Interview an instructor to create a course-specific `AI-POLICY.md` file. The
file should be suitable to upload to a learning management system, share with
learners, and install locally for MATLAB AI tutoring sessions so assignment
guardrails can enforce the instructor's rules.

Use this skill before a course pilot, when adopting the tutor for graded work,
or when an instructor wants one policy that applies consistently across
homework, labs, projects, quizzes, exams, and instructor-facing materials.

## Interactive Interview

Run the interview in short rounds. Ask at most three questions at a time and
summarize choices before generating the policy. If the instructor supplies a
syllabus, assignment description, or existing policy, extract answers from it
first and ask only about gaps.

Required policy requirements:

1. Course title, term, instructor, and contact or support path.
2. Course-wide AI-use stance: encouraged, allowed with limits, restricted, or
   prohibited except when explicitly authorized.
3. Rules by activity type: homework, labs, projects, quizzes, exams, take-home
   assessments, and instructor-facing content.
4. Allowed AI tutor help: concept explanations, analogous examples, debugging,
   code review, tests, reflection, transcript logs, and session reports.
5. Restricted AI tutor help: final solutions, full programs, answer keys,
   hidden test bypassing, unauthorized collaboration, and polishing work before
   a meaningful learner attempt.
6. Attribution requirements: whether learners must disclose tutor use, include
   prompts/transcripts, cite AI assistance, or submit session reports.
7. Data and privacy boundaries: what learners should avoid sharing.
8. Local enforcement level for MATLAB AI Tutor guardrails.
9. Effective date and review cadence.

Read [references/policy-interview.md](references/policy-interview.md) for the
interview sequence, enforcement levels, and policy decision matrix.

Read [references/ai-policy-template.md](references/ai-policy-template.md) before
writing `AI-POLICY.md`.

Read [references/policy-examples.md](references/policy-examples.md) when the
instructor asks for examples, wants help choosing policy strictness, or needs
calibrated wording for homework, labs, projects, quizzes, exams, or
instructor-facing solution generation.

## Output Workflow

1. Interview the instructor until required policy requirements are known.
2. Summarize the interpreted policy choices and ask for confirmation when
   anything is ambiguous or high stakes.
3. Generate `AI-POLICY.md` in the current working directory unless the user
   specifies another writable course folder.
4. Use learner-facing language: clear, direct, and suitable for an LMS.
5. Include a "Local MATLAB AI Tutor Enforcement" section that assignment
   guardrails can read.
6. Include a "Policy Summary for Tutor Guardrails" block with compact rules for
   tutoring sessions.
7. Tell the user where the file was written and how to use it with the tutor.

## Local Installation Rules

- The policy filename must be `AI-POLICY.md`.
- The preferred local install location is the course or tutoring session working
  directory.
- When a tutoring session starts, `matlab-apply-assignment-guardrails` should
  look for `AI-POLICY.md` in the current working directory and apply it before
  general guardrail defaults.
- If multiple policies are present, use the nearest policy in the current
  course/session directory and state which file is active.
- If no policy is present, use conservative default guardrails and ask whether
  the task is graded or policy-constrained when unclear.

## Output Constraints

- Do not invent institutional policy, honor-code language, or legal claims.
- If the instructor is unsure, mark the policy item as "Instructor default:
  conservative" and write a clear placeholder for later revision.
- Keep the policy actionable for learners and enforceable by the tutor.
- Do not create separate README files. The policy artifact is `AI-POLICY.md`.

## Examples

This demo includes an example learner-facing policy at
`assets/examples/ai-policy-intro-matlab-coached.md`, relative to the demo folder
that contains `skills/` (not relative to this skill folder). Use it as a
structural example only; replace the course name, activity rules, disclosure
requirements, and local enforcement settings with the instructor's confirmed
policy choices.
