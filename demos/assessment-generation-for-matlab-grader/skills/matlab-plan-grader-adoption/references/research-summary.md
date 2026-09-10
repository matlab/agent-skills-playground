# Research Summary for MATLAB Grader Setup Guides

Use this as a concise instructor-facing evidence map. It is not a full
literature review. The point is to connect setup-guide recommendations to
defensible assessment-design principles and practical MATLAB Grader choices.

## Evidence Map

| Setup choice | Research basis | Practical setup-guide implication |
| --- | --- | --- |
| Constructive alignment | Assessment tasks should directly require the learner behavior named in the objective. | Start with a measurable objective, then choose Script or Function based on the observable evidence. |
| Formative assessment | Feedback is most useful when learners can inspect evidence and revise. | For practice, include self-check prompts, diagnostic test names, and visible MATLAB evidence such as values, sizes, data types, and plots. |
| Summative assessment | Automated grading should use independent checks, edge cases, and robust evidence. | For graded use, include randomized inputs, different-range hardcoding detection, edge or transfer cases, and minimal answer-revealing hints. |
| Output-based code assessment | Runnable outputs and tests give stronger evidence than code appearance alone unless style is the objective. | Prefer checking function outputs, workspace variables, and plot data rather than grading syntax style. |
| Automated assessment review | Generated tests and prompts need instructor review before deployment. | Require review gates for description, solution, template, tests, and QTI 3 metadata before importing or assigning an item. |
| Interchange transparency | Portable packages should preserve semantics and limitations. | State that QTI 3 export is for interchange and review; generic QTI runtimes should not be expected to execute MATLAB Grader tests. |

## Instructor-Facing Rationale

Use this paragraph when a setup guide needs a short research basis:

```text
This MATLAB Grader setup emphasizes constructive alignment, observable MATLAB
evidence, randomized test coverage, and instructor review before deployment.
Those choices support assessment validity: the item should measure the stated
objective, give learners or graders interpretable evidence, and avoid brittle
or hardcoded solutions. QTI 3 export is treated as an interchange package, not
as a replacement for MATLAB Grader execution.
```

## Design Rules Derived from the Evidence

- Start with the learning objective and select the assessment item type from the
  evidence needed.
- Use formative design for practice and revision; use summative design for
  grading robustness.
- Check behavior rather than code style unless the objective requires a method.
- Include at least one transfer or different-range hardcoding check for graded
  use.
- Review all generated artifacts before using them with students.
- Validate QTI 3 XML separately from MATLAB Grader runtime behavior.

## Selected Sources

- Biggs, J. (1996). Enhancing teaching through constructive alignment. *Higher
  Education, 32*, 347-364. DOI: 10.1007/BF00138871.
- Black, P., & Wiliam, D. (1998). Assessment and classroom learning.
  *Assessment in Education: Principles, Policy & Practice, 5*(1), 7-74.
  DOI: 10.1080/0969595980050102.
- Hattie, J., & Timperley, H. (2007). The power of feedback. *Review of
  Educational Research, 77*(1), 81-112. DOI: 10.3102/003465430298487.
- Messer, M., Brown, N. C. C., Kölling, M., & Shi, M. (2024). Automated
  grading and feedback tools for programming education: A systematic review.
  *ACM Transactions on Computing Education, 24*(1). DOI: 10.1145/3636515.
- Paiva, J. C., Leal, J. P., & Figueira, A. (2022). Automated assessment in
  computer science education: A state-of-the-art review. *ACM Transactions on
  Computing Education, 22*(3). DOI: 10.1145/3513140.
- Shute, V. J. (2008). Focus on formative feedback. *Review of Educational
  Research, 78*(1), 153-189. DOI: 10.3102/0034654307313795.
