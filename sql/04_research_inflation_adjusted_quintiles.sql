-- Extração dos Quintis de Renda (20%, 40%, 60%, 80%) corrigidos pela inflação oficial dos EUA até 2018
-- english version: Extraction of Income Quintiles (20%, 40%, 60%, 80%) adjusted by official US inflation up to 2018
WITH dados_inflacionados AS (
    SELECT 
        annual_inc,
        -- 1. Extrai o ano do campo issue_d (ex: 'Dec-2015' -> 2015)
        -- 1. Extracts the year from the issue_d field (e.g., 'Dec-2015' -> 2015)
        RIGHT(issue_d, 4)::INT AS ano_emprestimo,
        
        -- 2. Aplica o multiplicador do CPI para trazer a renda para o valor presente de 2018
        -- 2. Applies the CPI multiplier to bring income to the 2018 present value
        CASE 
            WHEN RIGHT(issue_d, 4) = '2007' THEN annual_inc * 1.21
            WHEN RIGHT(issue_d, 4) IN ('2008', '2009') THEN annual_inc * 1.17
            WHEN RIGHT(issue_d, 4) = '2010' THEN annual_inc * 1.15
            WHEN RIGHT(issue_d, 4) = '2011' THEN annual_inc * 1.11
            WHEN RIGHT(issue_d, 4) = '2012' THEN annual_inc * 1.09
            WHEN RIGHT(issue_d, 4) = '2013' THEN annual_inc * 1.07
            WHEN RIGHT(issue_d, 4) IN ('2014', '2015') THEN annual_inc * 1.05
            WHEN RIGHT(issue_d, 4) = '2016' THEN annual_inc * 1.04
            WHEN RIGHT(issue_d, 4) = '2017' THEN annual_inc * 1.02
            ELSE annual_inc * 1.00 -- 2018 já é o valor presente / 2018 is already present value
        END AS renda_corrigida
    FROM fato_loans
    WHERE annual_inc > 0 
      AND loan_status IN ('Fully Paid', 'Charged Off', 'Default')
)
SELECT 
    -- 3. Calcula os 4 pontos de corte que dividem a base em 5 grupos de 20%
    -- 3. Calculates the 4 cut-off points that divide the database into 5 groups of 20%
    ROUND(PERCENTILE_CONT(0.20) WITHIN GROUP (ORDER BY renda_corrigida)::NUMERIC, 2) AS quintil_20,
    ROUND(PERCENTILE_CONT(0.40) WITHIN GROUP (ORDER BY renda_corrigida)::NUMERIC, 2) AS quintil_40,
    ROUND(PERCENTILE_CONT(0.60) WITHIN GROUP (ORDER BY renda_corrigida)::NUMERIC, 2) AS quintil_60,
    ROUND(PERCENTILE_CONT(0.80) WITHIN GROUP (ORDER BY renda_corrigida)::NUMERIC, 2) AS quintil_80
FROM dados_inflacionados;

-- limite de escopo: contratos encerrados com renda válida corrigida pelo CPI americano
-- english version; scope limits: closed contracts with valid income adjusted by the US CPI