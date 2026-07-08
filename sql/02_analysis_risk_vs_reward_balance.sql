-- Avaliação financeira de Risco vs Retorno cruzando Faixas de Renda e Comprometimento
-- english version: Risk vs Reward financial evaluation crossing Income Tiers and Commitment
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
    
    COUNT(*) AS total_clientes,
    
    -- Estimativa de receita anual de juros (Volume total * Taxa média de juros)
    -- english version: Estimated annual interest revenue (Total volume * Average interest rate)
    ROUND(SUM(funded_amnt * (int_rate / 100)), 2) AS receita_estimada_juros,
    
    -- Volume total perdido diretamente em calotes
    -- english version: Total volume lost directly to defaults
    ROUND(SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN funded_amnt ELSE 0 END), 2) AS volume_perda_calote,
    
    -- O Resultado Líquido (Receita de Juros - Perda por Calote)
    -- english version: The Net Result (Interest Revenue - Default Loss)
    ROUND(
        SUM(funded_amnt * (int_rate / 100)) - 
        SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN funded_amnt ELSE 0 END), 
        2
    ) AS resultado_financeiro_liquido
FROM fato_loans
WHERE annual_inc > 0
GROUP BY 1, 2
ORDER BY faixa_renda ASC, faixa_comprometimento ASC;

-- limite de renda baixa definida: <= $43.000
-- english version; lower income limit defined: <= $43.000

-- limite de renda intermediária definida: $43.000 a $85.000
-- english version; middle income limit defined: $43.000 to $85.000

-- limite de renda alta definida: > $85.000
-- english version; high income limit defined: > $85.000