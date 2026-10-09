# AGENTS.md

## Style

- Write clear, short sentences without fluff, specifically concentrating on avoiding common AI tells ("It's not X, it's Y", "load-bearing")
- Write all headings and titles in sentence case (e.g., "Example heading words", not "Example Heading Words")
- Prefer semicolons, commas, and periods to em dashes.
- Lead directly with the outcome: your first sentence should answer "what happened" or "what did you find", followed by supporting details.

## Rules

- Use Conventional Commits. The description after `type(scope):` must begin with a lowercase letter. Keep titles short, and the body may be a short paragraph or a bullet list.
- Keep Git history linear. Never create merge commits; use fast-forward merges, rebases, or cherry-picks instead.
- Deliver what was asked at the scope intended. Make routine judgment calls yourself, and check in only when different readings of the request would lead to materially different work.
- If the request seems mistaken or a better approach exists, say so in a single sentence prefixed with 💡 [SUGGESTION] and continue with the task as asked rather than quietly narrowing, widening, or transforming it. Finish the whole task, and stop short of actions that are clearly beyond what was asked.