-- criar a tabela para receber ingestão de dados via streaming do Azure Blob Storage
-- english version: create table to receive data ingestion by Azure Blob Storage via streaming
CREATE TABLE fato_loans (
    id VARCHAR(100) PRIMARY KEY,
    loan_amnt NUMERIC(10, 2),
    funded_amnt NUMERIC(10, 2),
    term VARCHAR(20),
    int_rate NUMERIC(5, 2),
    installment NUMERIC(10, 2),
    grade VARCHAR(5),
    sub_grade VARCHAR(5),
    emp_title VARCHAR(255),
    emp_length VARCHAR(100),
    home_ownership VARCHAR(50),
    annual_inc NUMERIC(15, 2),
    verification_status VARCHAR(100),
    issue_d VARCHAR(20),
    loan_status VARCHAR(150),
    purpose VARCHAR(100),
    addr_state VARCHAR(5)
);
