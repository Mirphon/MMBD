--Q1
-- Для витрины
SELECT
    c.federal_district,
    ROUND(SUM(t.amount_rub), 2) AS turnover_rub
FROM marts.fct_transactions AS t
JOIN marts.dim_client AS c USING (client_sk)
JOIN marts.dim_date AS d USING (date_sk)
WHERE d.date_actual >= DATE '2026-07-01'
  AND d.date_actual < DATE '2026-08-01'
  AND t.status = 'approved'
  AND t.channel IN ('pos', 'ecom')
GROUP BY c.federal_district
ORDER BY turnover_rub DESC;


-- Для сырых данных, чтобы было с чем сравнить
SELECT
    r.federal_district,
    ROUND(SUM(t.amount), 2) AS raw_amount_sum
FROM raw.transactions AS t
JOIN raw.cards AS k USING (card_id)
JOIN raw.accounts AS a USING (account_id)
JOIN raw.clients AS c USING (client_id)
JOIN raw.regions AS r
    ON c.city = r.city
WHERE t.txn_ts >= TIMESTAMP '2026-07-01 00:00:00'
  AND t.txn_ts < TIMESTAMP '2026-08-01 00:00:00'
  AND t.status = 'approved'
  AND t.channel IN ('pos', 'ecom')
GROUP BY r.federal_district
ORDER BY raw_amount_sum DESC;



--Q2
SELECT
    m.merchant_id,
    m.merchant_name,
    ROUND(SUM(t.amount_rub), 2) AS turnover_rub
FROM marts.fct_transactions AS t
JOIN marts.dim_client AS c USING (client_sk)
JOIN marts.dim_merchant AS m USING (merchant_sk)
WHERE c.segment = 'premium'
  AND t.status = 'approved'
  AND t.channel IN ('pos', 'ecom')
  AND t.txn_ts >= TIMESTAMP '2026-06-01 00:00:00'
  AND t.txn_ts < TIMESTAMP '2026-09-01 00:00:00'
GROUP BY m.merchant_id, m.merchant_name
ORDER BY turnover_rub DESC, m.merchant_id
LIMIT 5;


--Q3
SELECT
    d.week_start,
    t.channel,
    COUNT(*) AS total_attempts,
    COUNT(*) FILTER (
        WHERE t.status = 'declined'
    ) AS declined_attempts,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE t.status = 'declined')
        / COUNT(*),
        2
    ) AS declined_percent
FROM marts.fct_transactions AS t
JOIN marts.dim_date AS d USING (date_sk)
WHERE d.date_actual >= DATE '2026-08-01'
  AND d.date_actual < DATE '2026-09-01'
  AND t.status IN ('approved', 'declined')
GROUP BY d.week_start, t.channel
ORDER BY d.week_start, t.channel;