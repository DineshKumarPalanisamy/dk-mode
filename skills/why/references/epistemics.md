# Epistemics

How to rate confidence when the evidence is old, partial, and sometimes contradictory, and how to say it without false certainty.

## Confidence tiers

Every claim sits in one tier. The tier decides the section it goes in and the words it uses.

1. **Direct.** Someone wrote down why. A PR description ("fixes paging for users with more than 1000 items"), a work item ("the customer asked for this in their security review"), a code comment ("clamp to 100, the upstream API rejects more"), a design doc, a chat message from the author. Words: plain and cited. "This exists because X (PR 412)."
2. **Supported.** No single source says it, but several point the same way. The PR title says "improve performance", the work item is tagged perf, and the nearby commits touch the same hot path. Words: confident, with each piece listed. "The evidence points to X: A, B, C."
3. **Inferred.** A reasonable reading that nothing states. The error was hitting production (incident timing) and the fix merged the same day, so it was likely a hotfix. Words: hedged, with the chain shown. "Given A and B, C seems likely because D."
4. **Speculative.** A possible story on thin evidence, where other stories fit as well. Words: "One possibility is X, but we found no direct evidence." Usually goes under Competing hypotheses.
5. **Unknown.** You looked and did not find out. This is a valid and useful result. Words: say exactly what you searched. "We read the 6 PRs that touched this file since 2023, searched the tracker for 'retry' and 'timeout', and grepped for the constant. None gave a reason."

## Words

- Words that claim intent or success need a citation next to them: "because", "the reason is", "was designed to", "fixes", "the team decided". Never use them for an inference.
- Hedges mark interpretation: "appears to", "seems to", "likely", "suggests", "is consistent with", "may have been".
- Avoid: "obviously", "clearly", "of course", "just", "I think". Write "the evidence suggests" instead.

## Traps

- **Rationalizing.** Code that makes sense today may have been written for a reason that no longer applies, or that was wrong then. Do not invent a clean reason for messy history. A consistent pattern may be copy-paste, not a choice. No mention of a concern is not proof there was none.
- **Agreeing with the user's guess.** A guess in the question is a lead to check, not a conclusion. Check it like any other candidate and say plainly if the evidence does not support it.
- **Picking a side.** When sources disagree, show both with citations. Both can be true (the work item gave the business reason, the PR gave the author's framing), or one can be wrong. The user decides.
- **Filling gaps.** A confident guess in place of "we don't know" harms the user, because they act on it. Name each gap: the question, where you searched, with which terms, and what came back.

## Before you finish

Check every claim in "What we found" and "What we can infer": it has a citation or moves down a tier, and its words match its tier. Remove any claim that uses code as proof of its own intent. "What we don't know" must exist. If it is empty, either the record was unusually complete or something is missing from the search.
