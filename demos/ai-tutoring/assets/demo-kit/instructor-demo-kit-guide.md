# MATLAB® AI Tutor Demo Kit

<!-- Copyright 2026 The MathWorks, Inc. -->

This demo kit gives instructors a complete, low-risk way to evaluate the MATLAB
AI Tutor skills before using them with students. It is designed for a 20-30 minute
walkthrough or a first-week pilot around one MATLAB topic.

## Demo Goal

Show that the tutor can:

- keep learners active through prediction, revision, debugging, and transfer;
- respect course AI-use policy;
- assess runnable MATLAB work using evidence;
- produce learner reports, aggregate reports, and instructor dashboards;
- support instructor review with calibrated transcript-quality examples.

## Recommended Demo Path

1. **Start with a course setup guide**
   - Skill: `matlab-plan-tutor-adoption`
   - Example input: "Introductory MATLAB programming module on array indexing,
     element-wise operations, and table variables."
   - Expected output: a concise adoption guide with skill sequence, starter
     student prompt, guardrails, first-week pilot, and evidence review plan.

2. **Create an AI-use policy**
   - Skill: `matlab-create-ai-policy`
   - Use [suggested-syllabus-ai-use-language.md](suggested-syllabus-ai-use-language.md)
     and `assets/examples/ai-policy-intro-matlab-coached.md` as examples.
   - Expected output: `AI-POLICY.md` suitable for LMS upload and local guardrail
     enforcement.

3. **Run a short tutoring interaction**
   - Skill sequence: `matlab-tutor-learners`,
     `matlab-coach-programming`,
     `matlab-create-hands-on-exercises`, and
     `matlab-coach-debugging`.
   - Use [sample-tutoring-transcript-array-indexing.md](sample-tutoring-transcript-array-indexing.md)
     as a demonstration transcript.

4. **Try practice materials**
   - MCQ set: [example-mcq-set-array-indexing.md](example-mcq-set-array-indexing.md)
   - Hands-on script: [array_indexing_assessment.m](array_indexing_assessment.m)

5. **Review evidence**
   - Session report example: `assets/examples/session-report-example.html`
   - Aggregate reports and instructor dashboards: ask the
     `matlab-report-tutor-sessions` skill to generate them from a set of
     session reports.
   - Transcript-quality calibration:
     `assets/examples/transcript-review-calibration.md`
     and `assets/examples/quality-report-calibration.md`

## First-Week Pilot

Use one concept, one short practice set, and one review artifact:

| Pilot element | Recommended choice |
| --- | --- |
| Topic | Array indexing and element-wise operations |
| Student prompt | "Predict the output size and value before running each line." |
| MCQ activity | 3-5 questions from the example MCQ set |
| Hands-on task | Complete the array-indexing assessment script |
| Debugging focus | Use exact error text, `size`, `class`, and a minimal reproduction |
| Evidence review | One session report plus one transcript-quality check |

## Instructor Checklist

- [ ] Generate or adapt `AI-POLICY.md`.
- [ ] Pick one module, lab, or recurring misconception.
- [ ] Give students a starter prompt and the AI-use policy.
- [ ] Ask students to submit a session report or short disclosure when required.
- [ ] Review 3-5 transcripts with `matlab-evaluate-tutor-quality`.
- [ ] Revise prompts, guardrails, or exercises before expanding the pilot.

## What to Look For

Strong sessions show:

- learner predictions before explanations;
- MATLAB evidence such as output, `size`, `class`, tests, or Code Analyzer
  messages;
- feedback that names the MATLAB reason and next action;
- assignment guardrails that ask for attempts and avoid complete restricted
  submissions;
- transfer prompts that change one meaningful dimension.

Weak sessions show:

- fluent explanations with no learner action;
- unverified MATLAB claims;
- complete homework-like answers before learner attempts;
- feedback that only says right or wrong;
- no transfer task after success.
