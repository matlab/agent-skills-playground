---
name: matlab-plan-grader-adoption
description: Use when an instructor asks for a MATLAB Grader assessment setup guide, adoption guide, pilot plan, course-specific rollout, QTI 3 sharing workflow, or recommended MATLAB Grader assessment-item-generation configuration based on a learning objective, course title, course description, module description, lab description, or assessment goal.
license: MathWorks BSD-3-Clause (see LICENSE)
metadata:
  author: MathWorks
  version: "1.0"
---

# MATLAB Grader Instructor Setup Guide

## Purpose

Generate a short instructor-facing setup guide for adopting the MATLAB Grader
Assessment Item Generator skill in a course, module, lab, assessment sequence, or
instructional-design workflow.

Treat the user's provided objective, course description, assessment goal, or
pilot request as the guide input. If the input is missing, ask for one sentence
describing the course, module, learning objective, or assessment context before
generating the guide.

## Input Handling

Use the input to infer the best-fit setup context:

- introductory MATLAB programming;
- engineering computation or modeling;
- data analysis or visualization lab;
- object-oriented programming with MATLAB classes;
- graded homework, quiz, lab, project, or exam preparation;
- QTI 3 interchange, LMS review, or instructional-design sharing;
- mixed or uncertain context.

If multiple contexts fit, choose the primary context and add a short note about
secondary considerations. Do not ask follow-up questions unless the input is too
vague to identify an assessment goal.

## Guide Workflow

1. Restate the inferred learning objective or assessment goal.
2. Identify the best-fit assessment context and why it fits.
3. Recommend an assessment item type: Script, Function, Class Definition,
   Class Inheritance, Object Usage, or Class Methods.
4. Recommend assessment purpose: formative, summative, or both.
   When the context mapping has a purpose emphasis, use it.
   Otherwise default to summative for graded or unspecified use, and both when
   the module serves practice first with grading reuse later.
5. Recommend `content_language: auto` unless the instructor requests a specific language code.
6. Provide an instructor-ready generation prompt for the `matlab-generate-grader-assessments` skill.
7. Define review gates for `description.txt`, `solution.m`, `template.m`,
   template line locks documented in `assessments.md`,
   `function_call.m` when the recommended type is Function, and `tests.m`.
8. Define QTI 3 export and sharing guidance when portability is requested.
9. Propose a first pilot with one generated item, one review pass, and one
   revision loop.
10. Include a concise instructor checklist.

If the request requires a MATLAB class definition, class inheritance,
object-usage, or class-method submission, include the generator's classdef
constraints in the starter prompt: learner-authored class definitions must be
plain `.m` files, not Live Script `.m` or `.mlx` files; referenced class, data,
and helper files must be listed for MATLAB Grader upload; generated helper files
must remain readable `.m` files rather than `.p` files. For abstract classes,
recommend a concrete subclass or object-usage task unless the learner-submitted
class can be assessed without instantiation.

Read [references/setup-guide-template.md](references/setup-guide-template.md)
for context mapping, output format, prompt patterns, and adaptation rules.

Read [references/research-summary.md](references/research-summary.md) when the
user asks for research basis, evidence, rationale, literature mapping, or an
instructor-facing explanation of the assessment design choices.

## Output Rules

- Default to Markdown unless the user asks for another format.
- Keep the guide practical enough for an instructor to use without extra setup.
- Include concrete `matlab-generate-grader-assessments` prompts, not only advice.
- Recommend QTI 3 only when the instructor asks for portability, LMS review,
  interchange, standards-based sharing, or instructional-design handoff.
- State that QTI 3 preserves MATLAB Grader artifacts for interchange and does
  not make generic QTI runtimes execute MATLAB code.
- Keep policies and institutional workflow language adjustable unless the user
  provides local requirements.
- Include a brief research-basis section only when requested or when the guide
  is intended for departmental review, pilot approval, or assessment redesign.
