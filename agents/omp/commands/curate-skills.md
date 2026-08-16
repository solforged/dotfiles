---
description: audit and prune omp-managed skills safely
---

audit omp's managed skills as a bounded working set.

scope:

- inspect every `skill.md` below the active omp managed-skills directory. account for both `~/.omp/agent/managed-skills` and `~/.config/omp/agent/managed-skills`, but deduplicate paths that resolve to the same file.
- do not inspect, edit, move, or delete authored skills, project skills, or managed skills belonging to another omp profile.
- a skill should encode a reusable, multi-step procedure. isolated facts belong in memory; one-off results, stale environment details, superseded procedures, and near-duplicates do not deserve separate skills.

first pass — dry run only:

1. inventory the managed skills and read each one in full.
2. classify each as keep, update/merge, move to memory, or delete.
3. prefer updating one strong skill and deleting overlapping weaker skills. preserve unique operational details during any proposed merge.
4. treat uncertain value or obsolescence as keep. do not invent evidence that a procedure is stale.
5. report the exact skill names, concise evidence for every non-keep decision, and the before/after count.
6. ask for one explicit approval covering the exact updates and deletions. do not mutate anything in this pass, even if arguments request automatic application.

application pass — only after that approval:

1. apply approved updates before deletions, using `manage_skill` rather than raw filesystem writes.
2. store an approved isolated durable fact with `learn` or `retain` before deleting its former skill.
3. delete only the exact approved managed-skill names.
4. re-inventory the managed-skills directory and report the resulting names and count.

optional focus from the user: $ARGUMENTS
