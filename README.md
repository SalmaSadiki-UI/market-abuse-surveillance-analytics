# Market Abuse Surveillance Analytics

A market-surveillance case study using SQL, Python, spreadsheet investigation workflows and Tableau to identify and prioritise unusual AAPL order-book activity.

## Dashboard

![Market Abuse Surveillance Dashboard](market_abuse_dashboard.png)

## Business Problem

How can order-book event data be used to identify potentially suspicious trading patterns that may warrant further market-abuse investigation?

## Tools

- SQL
- Python
- Google Sheets
- Tableau

## Dataset

AAPL LOBSTER sample order-book and message data for 21 June 2012.

The dataset contains order submissions, cancellations, deletions and executions alongside five levels of order-book depth.

## Surveillance Approach

The analysis focused on identifying unusual order behaviour using a combination of:

- unusually large order size
- very short cancellation time
- order size relative to visible best-side liquidity
- transparent surveillance-priority scoring
- manual secondary-review decisions

An alert is treated as a reason for further investigation, not evidence that market abuse occurred.

## Key Findings

- 143,822 new orders were observed.
- Average new-order size was approximately 90 shares.
- Rapid cancellation was common, meaning cancellation speed alone was not sufficient to identify suspicious activity.
- 46 orders met the combined large-order and fast-cancellation surveillance threshold.
- The highest-priority candidate was a 2,099-share buy order cancelled in approximately 0.00035 seconds.
- That order was approximately 20.99× the visible best-side liquidity.
- Some flagged orders exceeded 200× the visible top-of-book liquidity.

## Investigation Workflow

The top surveillance candidates were reviewed using a structured spreadsheet investigation log containing:

- alert ID
- reviewer notes
- investigation status
- escalation decision
- review outcome

The strongest cases were escalated for secondary review rather than labelled as confirmed market abuse.

## Limitations

This dataset does not contain client or participant identifiers.

As a result, the analysis cannot establish trader intent, link activity across accounts, or prove spoofing or other forms of manipulation.

A real investigation would require additional client-level trading data, linked orders, executions, market context and supporting evidence.

## AI Use

AI tools were used selectively for learning support, debugging and refining parts of the workflow.

All analysis steps, outputs and conclusions were reviewed and checked before being included in the final project.

## Project Structure

- `market_abuse_dashboard.png` — final dashboard preview
- SQL analysis files
- Python surveillance analysis
- surveillance candidate CSV
- spreadsheet investigation workflow
- Tableau workbook / interactive dashboard
