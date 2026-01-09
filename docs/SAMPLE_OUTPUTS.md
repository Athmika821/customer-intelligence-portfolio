# Sample Outputs (Anonymized)

## Revenue Impact Analysis

| Category | Issue Count | Churn Risk | Financial Impact |
|----------|-------------|------------|------------------|
| Delivery Speed | 198 | 29 | ₹142,080 |
| Order Accuracy | 48 | 6 | ₹20,400 |
| Food Quality | 49 | 7 | ₹25,200 |
| Other | 202 | 34 | ₹75,600 |

## Top Fix Opportunities (by ROI)

| Issue | Occurrences | Impact | Fix Cost | ROI | Recommended Action |
|-------|-------------|--------|----------|-----|-------------------|
| missing_items | 7 | ₹16,800 | ₹50,000 | 0.34x | Process improvement |
| customer_frustration | 2 | ₹4,800 | ₹15,000 | 0.32x | Support training |
| order_delay | 5 | ₹12,000 | ₹50,000 | 0.24x | Operations fix |
| late_delivery | 4 | ₹9,600 | ₹50,000 | 0.19x | Logistics review |

## Key Insight Example

**Traditional approach:**
"Delivery late" = 200 complaints → Hire more delivery partners

**My framework:**
- 85 cases: 15-30 min delay (annoying, low revenue impact)
- 67 cases: 30-60 min delay (frustrating, moderate impact)
- 48 cases: 60+ min delay (revenue-blocking, high churn risk)

**Decision:** Fix the 60+ min delays first (highest ROI)

## Decomposition Example

**Input complaint:**
"Order cancelled after 2 hours, money stuck, support useless, app crashed"

**System output:**
1. operational/order_cancellation → Operations team
2. financial/refund_delay → Finance team
3. process/support_unresponsive → Support team
4. functional/app_crash → Engineering team
5. emotional/churn_risk → Retention team

**Business value:** 5 actionable issues vs 1 generic "delivery problem"
