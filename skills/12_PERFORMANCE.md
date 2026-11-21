# 12 — Performance

**Purpose:** Record measured limits and tuning guidance without guessing workload behavior.

**Confidence note:** No runtime code, metrics, or performance tests were available on 2026-11-21. Code wins (see 16).

No hard limits, hot paths, deliberate inefficiencies, expensive queries, or profiling commands are verified. Do not optimize based on assumed traffic or claim capacity without measurements. When evidence exists, record the workload, environment, metric, threshold, and exact profiling procedure; check Supabase query cost and client network behavior as separate boundaries. **Miss →** a local improvement may shift latency or load into another component without addressing the measured bottleneck.
