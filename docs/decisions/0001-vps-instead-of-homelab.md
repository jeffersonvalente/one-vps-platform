# ADR 0001, A rented VPS instead of a home server

**Status:** accepted

## Context
Work for two clients and personal projects ran on one desktop PC. The real bottleneck was not the
lab itself (~8 GB inside WSL2) but everything around it: WSL2's 50 % RAM cap, Docker Desktop's idle
footprint, and a browser/game competing for the rest. I also wanted access from anywhere.

## Options
1. Used mini PC at home (Ryzen 7, 32–64 GB) + a free-tier cloud VM as always-on anchor.
2. Cloud only: one 16 GB KVM VPS in-region.
3. Cheaper-per-GB providers abroad (more RAM, +150–220 ms latency, no local datacenter).

## Decision
Option 2. 16 GB on a headless Linux box covers the current lab comfortably, there is no Windows,
browser or game sharing it. In-region latency, no hardware to babysit, upgrade path if needed.

## Consequences
- Resource limits are mandatory on everything heavy (see ADR 0004 for what happens otherwise).
- 4 GB swap as a buffer, not as RAM.
- The PC becomes a thin client; the work lives on the server.
