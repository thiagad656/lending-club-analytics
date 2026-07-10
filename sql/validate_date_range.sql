-- Validação da integridade temporal do dataset
-- english version: Temporal integrity validation of the dataset
SELECT 
    MIN(TO_DATE(issue_d, 'Mon-YYYY')) AS data_minima,
    MAX(TO_DATE(issue_d, 'Mon-YYYY')) AS data_maxima
FROM fato_loans;