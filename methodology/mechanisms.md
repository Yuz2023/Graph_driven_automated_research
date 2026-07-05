# Supporting tools

Five tools support the research cycle. Each was introduced in response to
a specific need that arose during operation.

1. **Topic selection.** A generator maintains several hundred open
   questions (converter variants combined with transformation types and
   question categories) and ranks them by fixed, documented rules. A
   ledger records questions that were attempted and failed, so they are
   not proposed again.
2. **Rule drafting.** When the same class of error occurs twice, the
   system drafts a new working rule assembled from the recorded lessons.
   The human approves or rejects the draft; approved rules become
   permanent automated checks.
3. **Dashboard.** A single page summarizes progress, recorded errors,
   standing rules, and pending approvals. Every number on it is a count of
   recorded entries.
4. **Evaluation.** Results are evaluated on six dimensions (power quality,
   tracking, stress, reliability, efficiency, cost) as separate verdicts,
   never combined into a single weighted score. Thresholds are anchored to
   cited engineering standards. Comparisons across different test setups
   are rejected, and thresholds are sized to the magnitude of the quantity
   they check.
5. **Traceability.** All governed records compile into a provenance graph.
   Any conclusion can be traced backwards to the decision, the error
   report, or the experiment that produced it.
