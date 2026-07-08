-- Análise de Causa Raiz Global: Cruzando todas as faixas com Prazo de Contrato e Tipo de Moradia
-- english version: Global Root Cause Analysis: Crossing all bands with Loan Term and Home Ownership Type
SELECT 
    CASE 
        WHEN annual_inc <= 43000 THEN '1. Renda Baixa (<= 43k)'
        WHEN annual_inc > 43000 AND annual_inc <= 85000 THEN '2. Renda Intermediária (43k - 85k)'
        ELSE '3. Renda Alta (> 85k)'
    END AS faixa_renda,

    CASE 
        WHEN (installment * 12 / annual_inc) <= 0.10 THEN 'Até 10% da renda'
        WHEN (installment * 12 / annual_inc) > 0.10 AND (installment * 12 / annual_inc) <= 0.20 THEN 'De 10% a 20% da renda'
        ELSE 'Mais de 20% da renda (Sufocado)'
    END AS faixa_comprometimento,
    
    term AS prazo_contrato,
    home_ownership AS tipo_moradia,
    COUNT(*) AS total_clientes,
    
    ROUND(
        SUM(funded_amnt * (int_rate / 100)) - 
        SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN funded_amnt ELSE 0 END), 
        2
    ) AS resultado_financeiro_liquido
FROM fato_loans
WHERE annual_inc > 0 
  AND home_ownership IN ('RENT', 'MORTGAGE', 'OWN') -- Filtra apenas os tipos principais de moradia / Filters only main home ownership types
GROUP BY 1, 2, 3, 4
ORDER BY resultado_financeiro_liquido ASC;

-- limite de renda baixa definida: <= $43.000
-- english version; lower income limit defined: <= $43.000

-- limite de renda intermediária definida: $43.000 a $85.000
-- english version; middle income limit defined: $43.000 to $85.000

-- limite de renda alta definida: > $85.000
-- english version; high income limit defined: > $85.000