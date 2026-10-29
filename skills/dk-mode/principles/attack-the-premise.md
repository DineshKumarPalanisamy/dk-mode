# Attack the Premise

Adapted from pstack `principle-attack-the-premise` (MIT, see `<dk>/NOTICE.md`).

When two or more fixes that share one belief have failed the same check, suspect the belief, not the fixes.

**Why:** Each failed fix is evidence against the belief it assumed. A third fix on the same belief spends effort where the evidence already says the cause is not.

**Pattern:**
- **Write the premise down.** One sentence that every failed fix assumed. For example: "the value is cached per property".
- **Test the premise before the next fix.** Find one observation that would come out differently if the premise were false, and make it. Look at which cases fail, not only how badly. Make the check rerunnable (a script or a test).
- **Follow the evidence.** If it breaks the premise, the cause is elsewhere: look for what the failures share that the premise did not predict. If it confirms the premise, ask the next "why" (`principles/fix-root-causes.md`). The earlier fixes may have treated a result instead of the cause.
- **Remove the condition, do not compensate for it** (`principles/laziness-protocol.md`). Cleanup code that runs after the fact leaves the cause in place and adds work on every run.

**Stop:** Do not start the next fix before the premise is written down and tested. In the reply, quote the premise and the observation that settled it.

Different from `architect`, which compares designs. This questions one fact the current fix assumes.
