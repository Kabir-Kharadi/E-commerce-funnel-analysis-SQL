# P4 Sales Funnel Analysis

## About the Project

I analyzed an e-commerce sales funnel using SQL to track the customer journey from initial pageview to final purchase. The goal was to identify drop-off points, evaluate marketing channel efficiency, and provide actionable business recommendations to improve conversion rates and optimize ad spend.

It helped me strengthen real SQL skills in funnel analysis, conversion rate tracking, and translating raw data into strategic business decisions.

## Files in this Repository

## Files in this Repository

*   `Funnel_Analysis.sql` &larr; SQL queries used to extract funnel data (main file)
*   `user_events.csv` &larr; The raw dataset containing user interaction logs
*   `README.md` &larr; This file

## Database Schema

The analysis is based on an events log table capturing user interactions:

| Field | Type | Null | Key |
| :--- | :--- | :--- | :--- |
| event_id | int | NO | PRI |
| user_id | int | YES | |
| event_type | text | YES | |
| event_date | timestamp | YES | |
| product_id | int | YES | |
| amount | text | YES | |
| traffic_source | text | YES | |

**Dataset Note:** The `user_events.csv` contains 9381 rows of real anonymized e-commerce data.

## Final Recommendations (Verdict)

### 1. UX & Website Optimization
*   **Don't Touch the Checkout Flow:** The conversion rates from Checkout Start to Purchase are excellent (~80%+). This indicates the technical payment flow is frictionless.
    *   *Action:* Do not redesign the checkout page right now; you risk breaking something that is working perfectly.

### 2. Marketing Strategy
*   **Stop Over-Investing in Social for Sales:** Social Media is driving 30% of our traffic (Volume) but has the lowest conversion rate (Efficiency). We are likely paying for "window shoppers."
    *   *Action:* Shift budget away from "Traffic" objectives on social ads and focus on "Retargeting" or "Lead Gen" to capture emails instead.
*   **Double Down on Email Marketing:** Email is our highest converting channel (~13%+ conversion rate vs ~6% for Social).
    *   *Action:* Implement an aggressive email capture popup for those high-volume Social visitors. If we can get them onto our email list, our data proves they are far more likely to buy later.

### 3. Financial & Revenue
*   **Audit Ad Spend against AOV:** We found our Average Order Value is ~$115.
    *   *Action:* Set a strict Customer Acquisition Cost (CAC) limit. If we are paying more than $30-$40 to acquire a customer via Social Media ads (which convert poorly), we are likely losing money on those specific transactions.

## Author

**Kabir Kharadi**
Fourth Project | Learning Business Analysis
