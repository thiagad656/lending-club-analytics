-- Contagem de Clientes por Quintil de Renda Corrigida (Valor Presente 2018)
-- english version: Client Count by Adjusted Income Quintile (2018 Present Value)
WITH dados_base AS (
    SELECT 
        -- 1. Definição do multiplicador do CPI
        -- 1. Definition of the CPI multiplier
        CASE 
            WHEN RIGHT(issue_d, 4) = '2007' THEN 1.21
            WHEN RIGHT(issue_d, 4) IN ('2008', '2009') THEN 1.17
            WHEN RIGHT(issue_d, 4) = '2010' THEN 1.15
            WHEN RIGHT(issue_d, 4) = '2011' THEN 1.11
            WHEN RIGHT(issue_d, 4) = '2012' THEN 1.09
            WHEN RIGHT(issue_d, 4) = '2013' THEN 1.07
            WHEN RIGHT(issue_d, 4) IN ('2014', '2015') THEN 1.05
            WHEN RIGHT(issue_d, 4) = '2016' THEN 1.04
            WHEN RIGHT(issue_d, 4) = '2017' THEN 1.02
            ELSE 1.00
        END AS fator_cpi,
        annual_inc
    FROM fato_loans
    WHERE annual_inc > 0 
      AND loan_status IN ('Fully Paid', 'Charged Off', 'Default')
),
dados_ajustados AS (
    SELECT 
        -- 2. Cálculo da renda real
        -- 2. Calculation of real income
        (annual_inc * fator_cpi) AS renda_real
    FROM dados_base
)
SELECT 
    -- 3. Agrupamento pelas 5 classes exatas de mercado
    -- 3. Grouping by the 5 exact market classes
    CASE 
        WHEN renda_real <= 44100 THEN '5. Classe E (Vulnerável <= 44.1k)'
        WHEN renda_real > 44100 AND renda_real <= 59850 THEN '4. Classe D (Baixa Renda 44.1k - 59.8k)'
        WHEN renda_real > 59850 AND renda_real <= 77040 THEN '3. Classe C (Classe Média 59.8k - 77k)'
        WHEN renda_real > 77040 AND renda_real <= 104000 THEN '2. Classe B (Média-Alta 77k - 104k)'
        ELSE '1. Classe A (VIP / High Net Worth > 104k)'
    END AS classe_renda,
    
    COUNT(*) AS total_clientes
FROM dados_ajustados
GROUP BY 1
ORDER BY classe_renda DESC;

-- limite de escopo: contagem total isolada por classe de renda
-- english version; scope limits: total count isolated by income class