# System Architecture

## High-Level Design
```
┌─────────────────────────────────────┐
│     DATA INGESTION LAYER            │
│  (Manual scraping, 520 reviews)     │
│  → raw_reviews table         │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  TRANSFORMATION LAYER (DBT)         │
│                                     │
│  Stage 1: Staging                   │
│    └─ stg_reviews            │
│       (cleaning, validation)        │
│                                     │
│  Stage 2: Intermediate              │
│    ├─ int_issue_flags               │
│    │  (pattern detection)           │
│    └─ int_enriched_signals          │
│       (signal extraction)           │
│                                     │
│  Stage 3: Mart (Business Ready)     │
│    ├─ fct_customer_issues           │
│    │  (complexity routing 90/10)    │
│    ├─ mart_revenue_impact           │
│    ├─ mart_fix_roi                  │
│    └─ mart_decision_recommendations │
│                                     │
│  Output: 90% processed, 10% flagged │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  AI LAYER (n8n Child 3)             │
│                                     │
│  Input: 50 reviews flagged complex  │
│  Process: OpenAI atomic extraction  │
│  Output: decomposed_issues table    │
│         (213 atomic issues)         │
│                                     │
│  Cost: ~$1 per run                  │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  ORCHESTRATION LAYER (n8n Master)   │
│                                     │
│  1. Trigger DBT pipeline            │
│  2. Check for complex cases         │
│  3. Run Child 3 if needed           │
│  4. Generate summary report         │
│                                     │
│  Output: Execution summary          │
└─────────────────────────────────────┘
```

## Data Flow

### Stage 1: Staging (DBT)

**Model:** `stg_reviews`

**Input:** Raw scraped reviews (520 rows)  
**Process:** 
- Lowercase text normalization
- Whitespace trimming
- Calculate review_length
- Flag company responses
- Filter null/empty reviews

**Output:** Clean, standardized reviews ready for analysis

---

### Stage 2A: Pattern Detection (DBT)

**Model:** `int_issue_flags`

**Input:** Staged reviews  
**Process:** SQL regex pattern matching  
**Output:** Binary flags for 5 issue types

Issue flags detected:
- `has_delivery_delay`: Time-related complaints
- `has_temperature_issue`: Cold/hot food mentions
- `has_service_issue`: Rude behavior complaints
- `has_order_accuracy_issue`: Wrong/missing items
- `has_quality_issue`: Food quality problems
- `total_issue_flags`: Sum of all flags (0-5)

---

### Stage 2B: Signal Extraction (DBT)

**Model:** `int_enriched_signals`

**Input:** Staged reviews + issue flags  
**Process:** Business rule evaluation  
**Output:** 7 business intelligence signals

Signals extracted:
- `has_churn_language`: "never again", "last time", "switching to [competitor]"
- `mentions_money`: Refund/charge/payment mentions
- `mentions_time_delay`: Specific time delays (hours/minutes)
- `mentions_support`: Helpline/customer care issues
- `engagement_tier`: Review detail level (High/Medium/Low)
- `exclamation_count`: Emotion proxy
- `emotion_intensity_raw`: Calculated anger score (0-100)

---

### Stage 3: Business Mart Layer (DBT)

**Model:** `fct_customer_issues`

**Input:** issue_flags + enriched_signals  
**Process:** Business logic application  
**Output:** Production-ready customer intelligence

Key transformations:
- **Primary category assignment** (Delivery Speed, Food Quality, etc.)
- **Complexity level calculation** (High/Medium/Low based on flag count)
- **Severity scoring** (0-100 weighted score)
- **Preliminary priority score** (business urgency)
- **AI routing flag** (`requires_deep_analysis = true` when flags ≥ 2)

**Result:** 470 reviews fully processed, 50 flagged for AI

---

**Model:** `mart_revenue_impact`

**Input:** `fct_customer_issues`  
**Process:** Financial exposure calculation  
**Output:** Revenue at risk by category

Calculations:
```
Churn Revenue = churn_count × ₹2,400 LTV × 25% rate
Refund Exposure = financial_complaints × ₹350 × 60% claim rate
Support Costs = escalations × ₹150 per ticket
Total Impact = sum of above
```

---

**Model:** `mart_fix_roi`

**Input:** `decomposed_issues` (from n8n) + `mart_revenue_impact`  
**Process:** ROI calculation per issue  
**Output:** Fix opportunities ranked by ROI

Fix cost estimation:
- Simple (3 days): ₹15,000
- Moderate (2 weeks): ₹50,000
- Complex (1 month): ₹100,000

Business impact calculation:
```
Impact = occurrence_count × severity_multiplier
  where severity_multiplier:
    critical: ₹3,600
    high: ₹2,400
    medium: ₹1,200
    low: ₹600

ROI = Impact / Fix_Cost
```

---

**Model:** `mart_decision_recommendations`

**Input:** `mart_fix_roi`  
**Process:** Filter and rank top opportunities  
**Output:** Top 10 actionable recommendations

Each recommendation includes:
- Priority rank (1-10)
- Issue subtype (specific problem)
- Fix owner team (engineering/operations/support/product)
- Recommended action
- Business justification (with metrics)
- Implementation timeline

---

### Stage 4: AI Decomposition (n8n Child 3)

**Technology:** n8n workflow + OpenAI GPT-4o-mini

**Input:** 50 reviews where `requires_deep_analysis = true`  
**Context:** Pre-detected signals from DBT (churn risk, money, support, emotion)  
**Process:** 
1. Fetch complex cases from `fct_customer_issues`
2. Send to OpenAI with context
3. Extract 1-5 atomic issues per review
4. Write to `decomposed_issues` table
5. Update `ai_processed = true` flag

**Output:** 213 atomic issues extracted

Each issue includes:
- `issue_type`: operational/financial/process/emotional/functional
- `issue_subtype`: Specific problem description
- `funnel_stage`: Where in customer journey
- `affected_component`: What failed
- `issue_severity`: critical/high/medium/low
- `fix_owner_team`: Who should fix it
- `fix_complexity`: simple/moderate/complex
- `extraction_confidence`: 0.0-1.0

**Key design:** AI receives context from DBT, making prompts more targeted and effective.

---

### Stage 5: Orchestration (n8n Master Workflow)

**Technology:** n8n master workflow

**Process:**
1. **Trigger DBT run** (manual or scheduled)
   - Executes `dbt run` command
   - Updates all 7 models
   
2. **Check for complex cases**
   - Query: `SELECT COUNT(*) WHERE requires_deep_analysis = true AND ai_processed = false`
   
3. **Conditional branching**
   - If count > 0 → Trigger Child 3 workflow
   - If count = 0 → Skip to summary
   
4. **Generate summary report**
   - Reviews processed
   - Complex cases handled
   - Issues decomposed
   - Execution status

**Output:** Automated intelligence pipeline with summary reporting

---

## Design Decisions

### Why Hybrid (90/10)?

**Deterministic processing handles:**
- Standard patterns ("late delivery", "cold food")
- Clear signals ("money stuck", "rude support")
- Volume processing (470 reviews instantly)
- Cost: $0

**AI processing handles:**
- Multi-issue complexity (4+ intertwined problems)
- Context-dependent interpretation
- Emotional nuance
- Cost: ~$1 for 50 reviews

**Cost comparison:**
- Pure AI approach: $10/review × 520 = $5,200
- Hybrid approach: ($0 × 470) + ($0.02 × 50) = $1
- **Savings: 99.98%**

---

### Why DBT for Transformation?

- **SQL-based:** Readable, maintainable business logic
- **Modular:** 4-layer architecture (staging → intermediate → mart)
- **Fast execution:** Views for intermediate, tables for marts
- **Testable:** Can validate transformations
- **Industry standard:** Widely adopted in data teams

---

### Why n8n for Orchestration?

- **Visual workflows:** Easy to debug and maintain
- **HTTP integration:** Direct Supabase REST API calls
- **Conditional logic:** Route to AI only when needed
- **Error handling:** Retry logic, graceful failures
- **Master orchestration:** Coordinates DBT + AI workflows

---

### Why Separate n8n Workflows?

**Child 3:** Issue decomposition (focused, reusable)  
**Master:** Pipeline orchestration (coordinates all stages)

**Benefits:**
- Modularity (can test Child 3 independently)
- Reusability (Child 3 can be called from multiple places)
- Maintainability (easier to debug single workflow)
- Scalability (can run Child 3 in parallel if needed)

---

## Key Metrics

### Processing Performance

**Deterministic layer (DBT):**
- 470 reviews processed in <1 minute
- 7 models executed sequentially
- Zero API costs

**AI layer (n8n + OpenAI):**
- 50 reviews processed in ~3 minutes
- Sequential API calls (one at a time)
- Cost: ~$1 per full run

**Total pipeline:** ~5 minutes end-to-end

---

### Quality Metrics

**Deterministic coverage:** 90.4% (470/520 reviews)  
**AI processing:** 9.6% (50/520 reviews)  
**Atomic issues extracted:** 213 (avg 4.3 per complex review)  
**AI extraction confidence:** 0.85-0.95 average  
**Churn risks identified:** 79 customers (15% of total)

---

### Cost Metrics

**Infrastructure:** Supabase free tier (sufficient for prototype)  
**DBT processing:** $0 (compute only)  
**AI processing:** ~$1 per 520 reviews  
**Total cost per run:** ~$1  
**Cost per review (blended):** $0.002

---

## Technology Stack Summary

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Storage** | Supabase (PostgreSQL) | Data warehouse |
| **Transformation** | DBT (7 models) | Business logic |
| **Orchestration** | n8n (2 workflows) | Pipeline automation |
| **AI** | OpenAI GPT-4o-mini | Complex case handling |

---

## Scalability Considerations

**Current:** 520 reviews (prototype)  
**Tested capacity:** Single-run validation only  
**Estimated capacity:** 1,000-2,000 reviews/day (conservative)

### Optimization Path for Scale:

**DBT optimizations:**
- Incremental models (process only new reviews)
- View materialization for intermediate layers (faster)
- Table materialization for marts (optimized reads)

**n8n optimizations:**
- Parallel AI processing (batch API requests)
- Connection pooling (reuse DB connections)
- Error recovery (resume from failure point)

**Database optimizations:**
- Index key lookup columns (id, signal_id, decomposition_run_id)
- Partition large tables by date
- Vacuum/analyze regularly

### Known Bottlenecks:

1. **Sequential AI calls** (n8n processes one review at a time)
   - Solution: Implement batch processing with Promise.all()
   
2. **DBT sequential execution** (models run one after another)
   - Solution: Use `threads: 4` in profiles.yml for parallelization
   
3. **Single Supabase connection** (can timeout under load)
   - Solution: Connection pooling or upgrade plan

---

## Production Readiness Assessment

✅ **Completed:**
- 4-layer DBT pipeline functional
- Hybrid processing (90/10) validated
- n8n orchestration working
- Revenue intelligence implemented
- ROI calculations verified

⚠️ **Needs validation:**
- Load testing (>1,000 reviews)
- Error recovery scenarios
- Concurrent workflow execution
- Database performance under load

🔜 **Future enhancements:**
- Automated testing (dbt test)
- CI/CD pipeline
- Monitoring/alerting
- API endpoint for real-time queries
