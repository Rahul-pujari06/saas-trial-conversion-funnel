# SaaS Trial Conversion Funnel Analysis

**Dataset:** RavenStack (synthetic SaaS dataset, credit: River @ Rivalytics)
**Tools:** MySQL (data modeling and analysis), Power BI (dashboard)
**Author:** [Your name]

## Objective

To analyze 500 customer accounts and their 5,000 associated subscription
records in order to understand what drives trial-to-paid conversion, and
to identify where the business should focus to improve it.

## Key findings

**1. Plan tier matters more than acquisition channel.**
Conversion rate varies far more by plan tier (Enterprise 83.8%, Basic
82.7%, Pro 75.8% — an 8-point spread) than by referral source (79.6% to
82.5% — a 3-point spread). This suggests that the product or pricing
experience of the Pro tier itself is a bigger lever than the channel that
brought the customer in.

**2. The Pro tier underperforms, and its performance depends heavily on
channel.**
The cross-tab analysis shows this is not uniform: Pro-tier conversion
ranges from 65.4% (partner referrals) to 79.5% (event referrals) — a
14-point gap within the same plan tier, driven entirely by acquisition
channel. Partner-referred Pro trials convert worse than any other
combination in the dataset.

**3. Partner referrals are polarized, not uniformly weak.**
Partner is the best-converting channel for Enterprise (90.0%) but the
worst-converting channel for Pro (65.4%). Averaging partner performance
across all tiers would hide this: the channel is not "weak," it is
mismatched to Pro-tier trial users specifically.

**4. Conversion shows no clear trend over time, but is highly volatile.**
Monthly conversion rate swings between 58.8% (January 2023) and 95.2%
(August 2024), with no steady upward or downward trend across the 24-month
window. This points to month-specific factors, such as campaigns,
seasonality, or pricing changes, rather than gradual product improvement
or decline.

**5. Converting trial accounts has clear, quantifiable revenue value.**
Paid subscriptions generate $11.3M in total MRR across 4,222 subscriptions,
averaging $2,686 per account. Every trial that fails to convert represents
a concrete, calculable amount of lost recurring revenue, not just a lost
signup.

## Recommendation

The company should prioritize investigating **why Pro-tier trials
underperform**, particularly those referred by partners. Two concrete next
steps are recommended:

1. **Review the partner referral process for Pro-tier signups.** If
   partners are pre-qualifying leads differently for Enterprise versus Pro
   (for example, incentive structures that favor high-value deals), Pro
   leads may be lower-intent by the time they reach a trial.
2. **Investigate the high-conversion months (August 2024 and May 2023)**
   to identify what worked. If these align with specific campaigns,
   onboarding changes, or pricing promotions, those tactics could be
   systematized rather than left to chance.

## Limitations

This is a synthetic dataset, so the findings reflect patterns in the
generated data rather than in a real company's customers. The methodology
used here — funnel segmentation, cohort and time-trend analysis, and
cross-tab breakdowns — is directly transferable to a real SaaS dataset
with a live database connection. A live connection would also enable full
cross-filtering in the dashboard, which was not fully possible here since
the analysis was built from static CSV exports of the SQL query results
rather than a live connection.
