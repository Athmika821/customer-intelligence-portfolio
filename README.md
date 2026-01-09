# Customer & Revenue Intelligence System

> A hybrid DBT + n8n platform that transforms customer complaints into ROI-ranked business intelligence using 90% deterministic processing and 10% AI-assisted decomposition.

## Problem Statement

Traditional complaint analysis systems:
- Rely 100% on AI (expensive, slow, unexplainable)
- Prioritize by frequency (misses high-impact, low-volume issues)
- Lack financial quantification (no ROI calculation)
- Provide generic categories (no actionable decomposition)

## Solution Architecture

**Hybrid Intelligence Design:**
- **90% Deterministic (SQL):** Pattern matching, signal extraction, severity scoring
- **10% AI-Assisted (OpenAI):** Complex multi-issue decomposition for edge cases
- **Cost Optimization:** 90% reduction vs pure-AI approach
- **Explainability:** Every decision traceable to SQL logic or confidence score

**Tech Stack:**
- Data Warehouse: PostgreSQL (Supabase)
- Transformation: DBT (4-layer pipeline)
- Orchestration: n8n
- AI: OpenAI GPT-4o-mini (targeted use only)

## Key Results

**Data Processed:**
- 520 customer reviews analyzed
- 470 reviews auto-processed deterministically (90%)
- 50 complex cases routed to AI (10%)
- 213 atomic issues extracted

**Business Intelligence:**
- 79 churn-risk customers identified
- ₹352,000 revenue exposure quantified
- Top 10 fix opportunities ranked by ROI
- 90% cost reduction vs pure-AI baseline

## System Design

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed system design.

## Code Examples

See [examples/](examples/) for sample SQL models demonstrating:
- Deterministic pattern matching
- Signal extraction logic
- ROI calculation methodology

## Documentation

- **[Architecture Overview](docs/ARCHITECTURE.md)** - System design and data flow
- **[Sample Outputs](docs/SAMPLE_OUTPUTS.md)** - Anonymized results and insights

## Design Principles

1. **Deterministic First, AI Second**
   - Reserve AI for genuinely complex cases
   - 90% of complaints follow predictable patterns
   - SQL: instant, free, explainable

2. **Financial Quantification**
   - Revenue at risk (churn × LTV)
   - Refund exposure (complaints × average)
   - Support costs (escalations × cost per ticket)

3. **Actionable Decomposition**
   - Atomic issues (one fix owner per issue)
   - Clear severity scores
   - ROI-ranked priorities

## Technical Highlights

- **4-layer DBT pipeline** (staging → intermediate → fact → marts)
- **Hybrid processing** (deterministic + AI routing logic)
- **Revenue intelligence layer** (financial impact calculation)
- **ROI prioritization engine** (fix cost vs business impact)

## Contact

**Athmika T.P.** | AI Workflow Developer & Applied Analytics Specialist

[LinkedIn](https://www.linkedin.com/in/athmika-t-p-a0a22b94/)

---

*Note: This repository contains documentation and architecture samples. Full implementation is proprietary.*
