-- Criação da View Analítica para o Power BI (Import Mode)
-- english version: Creation of the Analytical View for Power BI (Import Mode)
CREATE OR REPLACE VIEW vw_lending_club_powerbi AS
WITH dados_base AS (
    SELECT 
        -- 1. Chave e Dimensões Estratégicas
        -- 1. Key and Strategic Dimensions
        id,
        loan_status,
        term,
        home_ownership,
        grade,
        sub_grade,
        purpose,
        emp_length,
        verification_status,
        addr_state,
        int_rate,
        issue_d,
        
        -- 2. Definição do multiplicador do CPI para Moeda Alvo (2018)
        -- 2. Definition of the CPI multiplier for Target Currency (2018)
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
        annual_inc,
        funded_amnt,
        installment
    FROM fato_loans
    WHERE annual_inc > 0 
      AND loan_status IN ('Fully Paid', 'Charged Off', 'Default')
),
dados_ajustados AS (
    SELECT 
        *,
        TO_DATE(issue_d, 'Mon-YYYY') AS data_emissao,
        CAST(RIGHT(issue_d, 4) AS INTEGER) AS ano_emissao,
        
        (annual_inc * fator_cpi) AS renda_real,
        (funded_amnt * fator_cpi) AS emprestimo_real,
        -- Cálculo do comprometimento usando Valor Presente
        -- Calculation of commitment using Present Value
        ((installment * fator_cpi) * 12) / (annual_inc * fator_cpi) AS comprometimento_real,
        -- Ciclo de vida do contrato
        -- Contract life cycle
        CASE WHEN term LIKE '%36%' THEN 3 ELSE 5 END AS anos_contrato
    FROM dados_base
)
SELECT 
    id,
    loan_status,
    term,
    home_ownership,
    grade,
    sub_grade,
    purpose,
    emp_length,
    verification_status,
    addr_state,
    
    -- Atributos Temporais Estratégicos
    -- Strategic Time Attributes
    data_emissao,
    ano_emissao,
    
    -- Segmentações Estratégicas (Classes e Faixas)
    -- Strategic Segmentations (Classes and Tiers)
    CASE 
        WHEN renda_real <= 44100 THEN '5. Classe E (Vulnerável <= 44.1k)'
        WHEN renda_real > 44100 AND renda_real <= 59850 THEN '4. Classe D (Baixa Renda 44.1k - 59.8k)'
        WHEN renda_real > 59850 AND renda_real <= 77040 THEN '3. Classe C (Classe Média 59.8k - 77k)'
        WHEN renda_real > 77040 AND renda_real <= 104000 THEN '2. Classe B (Média-Alta 77k - 104k)'
        ELSE '1. Classe A (VIP / High Net Worth > 104k)'
    END AS classe_renda,

    CASE 
        WHEN comprometimento_real <= 0.10 THEN 'Até 10% da renda'
        WHEN comprometimento_real > 0.10 AND comprometimento_real <= 0.20 THEN 'De 10% a 20% da renda'
        ELSE 'Mais de 20% da renda (Sufocado)'
    END AS faixa_comprometimento,
    
    -- Métricas Financeiras e Resultado Real
    -- Financial Metrics and Real Result
    ROUND(renda_real, 2) AS renda_real,
    ROUND(emprestimo_real, 2) AS emprestimo_real,
    
    CASE 
        WHEN loan_status = 'Fully Paid' THEN ROUND((emprestimo_real * (int_rate / 100)) * anos_contrato, 2)
        WHEN loan_status IN ('Charged Off', 'Default') THEN ROUND(-emprestimo_real, 2)
        ELSE 0 
    END AS resultado_financeiro_real

FROM dados_ajustados;

-- limite de escopo: extração otimizada para modelagem dimensional (Star Schema/Flat Table)
-- english version; scope limits: optimized extraction for dimensional modeling (Star Schema/Flat Table)