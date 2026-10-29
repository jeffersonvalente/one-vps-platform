# ADR 0004 — Incident: SigNoz stopped ingesting (ZooKeeper OOMKilled)

**Window:** ~35 min without ingestion · **Severity:** lab, no meaningful loss · **Status:** resolved

## What happened
A tenant started a load test: an OpenTelemetry demo shop with 14 services, ~9k active metric series.
Twenty-seven minutes later `signoz-zookeeper-0` entered CrashLoopBackOff — **OOMKilled** at a 384 MiB
limit, 16 restarts. Without ZooKeeper, ClickHouse rejects INSERTs; the otel-collector logged
`Exporting failed. Rejecting data.` Yet the OTLP endpoint kept answering **200**, because the collector
is what answers — not the storage. The tenant's first (reasonable) guess was "too much volume".

## Why
Every limit in `signoz.yaml` had been sized for an *idle* lab (ZK 384 Mi, ClickHouse 2 Gi). A 14-service
shop is real load: thousands of ClickHouse parts → metadata in ZooKeeper → JVM heap exhausted.

## Diagnosis (6 minutes)
```bash
kubectl -n signoz get pods                                   # zookeeper CrashLoopBackOff, 16 restarts
kubectl -n signoz describe pod signoz-zookeeper-0 | grep -A3 "Last State"   # OOMKilled, exit 137
kubectl -n signoz logs deploy/signoz-otel-collector --since=40m | grep -c "Exporting failed"
```

## Fix
ZooKeeper: `heapSize: 512`, limit **1 Gi**. ClickHouse: limit **3 Gi**, `max_memory_usage` 2 GB.
One commit; ArgoCD applied it; ingestion recovered within two minutes. Memory budget updated.

## Lessons
- **"Endpoint returns 200" is not "data was stored."** Check the exporter's error count and the
  storage pods' `RESTARTS` before blaming the sender.
- Limits sized for idle break on the first load test. Size for expected load, then verify under it.
- Agreed with the tenant on a sender-side budget: < 3k active series in the lab; drop `process.*`
  and `runtime.*` metrics from demo workloads.
