-- detalhando a renda anual pelo status do empréstimo
-- english version: breaking down annual income by loan status
SELECT 
    loan_status,
    COUNT(*) AS qtd_clientes,
    -- Média e Desvio Padrão
    ROUND(AVG(annual_inc), 2) AS renda_media,
    ROUND(STDDEV(annual_inc), 2) AS desvio_padrao_renda,
    
    -- Percentis (25%, 50% que é a mediana, e 75%)
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY annual_inc)::NUMERIC, 2) AS percentil_25,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY annual_inc)::NUMERIC, 2) AS mediana_50,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY annual_inc)::NUMERIC, 2) AS percentil_75
FROM fato_loans
WHERE loan_status IN ('Fully Paid', 'Charged Off', 'Default')
GROUP BY loan_status;

-- limite de renda baixa definida: <= $43.000
-- english version; lower income limit defined: <= $43.000

-- limite de renda intermediária definida: $43.000 a $85.000
-- english version; middle income limit defined: $43.000 to $85.000

-- limite de renda alta definida: > $85.000
-- english version; high income limit defined: > $85.000