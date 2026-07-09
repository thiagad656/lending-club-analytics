-- Análise do Resultado Financeiro Líquido cruzando Quintis de Renda e Comprometimento em Valor Presente
-- english version: Net Financial Result Analysis crossing Income Quintiles and Commitment in Present Value
WITH dados_base AS (
    SELECT 
        loan_status,
        int_rate,
        term,
        -- 1. Definição do multiplicador do CPI para conversão dos valores nominais para a Moeda Alvo (2018)
        -- 1. Definition of the CPI multiplier to convert nominal values to the Target Currency (2018)
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
        loan_status,
        int_rate,
        term,
        (annual_inc * fator_cpi) AS renda_real,
        (funded_amnt * fator_cpi) AS emprestimo_real,
        -- Cálculo do percentual de comprometimento baseado nos valores em Valor Presente
        -- Calculation of the commitment percentage based on Present Value amounts
        ((installment * fator_cpi) * 12) / (annual_inc * fator_cpi) AS comprometimento_real,
        -- Definição do ciclo de vida do contrato em anos
        -- Definition of the contract life cycle in years
        CASE WHEN term LIKE '%36%' THEN 3 ELSE 5 END AS anos_contrato
    FROM dados_base
)
SELECT 
    -- 2. Estrutura de segmentação baseada nos Quintis de Renda em Valor Presente
    -- 2. Segmentation structure based on Income Quintiles in Present Value
    CASE 
        WHEN renda_real <= 44100 THEN '5. Classe E (Vulnerável <= 44.1k)'
        WHEN renda_real > 44100 AND renda_real <= 59850 THEN '4. Classe D (Baixa Renda 44.1k - 59.8k)'
        WHEN renda_real > 59850 AND renda_real <= 77040 THEN '3. Classe C (Classe Média 59.8k - 77k)'
        WHEN renda_real > 77040 AND renda_real <= 104000 THEN '2. Classe B (Média-Alta 77k - 104k)'
        ELSE '1. Classe A (VIP / High Net Worth > 104k)'
    END AS classe_renda,

    -- 3. Segmentação das faixas de comprometimento real da renda
    -- 3. Segmentation of real income commitment bands
    CASE 
        WHEN comprometimento_real <= 0.10 THEN 'Até 10% da renda'
        WHEN comprometimento_real > 0.10 AND comprometimento_real <= 0.20 THEN 'De 10% a 20% da renda'
        ELSE 'Mais de 20% da renda (Sufocado)'
    END AS faixa_comprometimento,
    
    COUNT(*) AS total_clientes,
    
    -- 4. Cálculo da receita de juros acumulada no ciclo de vida total dos contratos liquidados
    -- 4. Calculation of accumulated interest revenue over the total life cycle of completed contracts
    ROUND(SUM(CASE WHEN loan_status = 'Fully Paid' THEN emprestimo_real * (int_rate / 100) * anos_contrato ELSE 0 END), 2) AS receita_real_juros,
    ROUND(SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN emprestimo_real ELSE 0 END), 2) AS perda_real_calote,
    
    ROUND(
        SUM(CASE WHEN loan_status = 'Fully Paid' THEN emprestimo_real * (int_rate / 100) * anos_contrato ELSE 0 END) - 
        SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN emprestimo_real ELSE 0 END), 
        2
    ) AS resultado_financeiro_real
FROM dados_ajustados
GROUP BY 1, 2
ORDER BY classe_renda DESC, faixa_comprometimento ASC;

-- limite de escopo: contratos encerrados com métricas monetárias convertidas para a Moeda Alvo (2018)
-- english version; scope limits: closed contracts with monetary metrics converted to the Target Currency (2018)