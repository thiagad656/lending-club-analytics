-- Classificação cruzada: Faixas de Renda baseadas nos quartis estatísticos vs Comprometimento da Renda Mensal
-- english version: Cross-classification: Income Tiers based on statistical quartiles vs Monthly Income Commitment
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
    ROUND(AVG(funded_amnt), 2) AS tamanho_medio_emprestimo,
    ROUND(AVG(int_rate), 2) AS taxa_juros_media,
    
    ROUND(
        (COUNT(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN 1 END)::NUMERIC / COUNT(*)) * 100, 
        2
    ) AS taxa_calote
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