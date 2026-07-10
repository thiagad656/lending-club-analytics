# Dicionário de Dados / Data Dictionary

Este documento descreve a estrutura de dados utilizada no projeto, detalhando o pipeline de transformação, a tabela fato original (`fato_loans`) e a camada analítica final (`vw_lending_club_powerbi`).

---

## 1. Origem dos Dados e Processo de ETL (Data Pipeline)

A tabela fato principal (`fato_loans`) passou por um processo rigoroso de **ETL (Extract, Transform, Load)** para focar exclusivamente na modelagem de risco de crédito:
* **Redução de Escopo:** Dezenas de colunas secundárias e métricas redundantes de comportamento pós-concessão foram removidas para otimizar o desempenho do banco.
* **Filtro de Massa:** Mantive apenas os registros estruturais necessários para avaliar o perfil do cliente no ato da contratação versus o desfecho final do crédito (`loan_status`), removendo linhas com renda zerada.

---

## 2. Tabela Fato: fato_loans (Dados Brutos)

| # | Nome da Coluna | Tipo de Dados | Descrição |
| :--- | :--- | :--- | :--- |
| 1 | `id` | varchar(100) | Identificador único de cada contrato de empréstimo. |
| 2 | `loan_amnt` | numeric(10,2) | Valor nominal do empréstimo solicitado pelo tomador. |
| 3 | `funded_amnt` | numeric(10,2) | Valor total nominal efetivamente liberado pelo banco. |
| 4 | `term` | varchar(20) | O número de parcelas do contrato ("36 months" ou "60 months"). |
| 5 | `int_rate` | numeric(5,2) | Taxa de juros nominal aplicada ao empréstimo (em percentual). |
| 6 | `installment` | numeric(10,2) | Valor da parcela mensal nominal que o tomador deve pagar. |
| 7 | `grade` | varchar(5) | Nota de classificação de risco atribuída ao empréstimo (A a G). |
| 8 | `sub_grade` | varchar(5) | Subdivisão fina da classificação de risco (ex: A1, B3). |
| 9 | `emp_title` | varchar(255) | Título profissional ou cargo informado pelo tomador no cadastro. |
| 10 | `emp_length` | varchar(100) | Tempo de emprego do tomador em anos (ex: "< 1 year", "10+ years"). |
| 11 | `home_ownership` | varchar(50) | Status de propriedade da residência (RENT, OWN, MORTGAGE). |
| 12 | `annual_inc` | numeric(15,2) | Renda anual nominal autodeclarada pelo tomador. |
| 13 | `verification_status`| varchar(100) | Indica se a renda do tomador foi verificada pelo banco ou não. |
| 14 | `issue_d` | varchar(20) | O mês e ano em que o empréstimo foi oficialmente emitido (Texto). |
| 15 | `loan_status` | varchar(150) | Status atual do contrato (Fully Paid, Charged Off, Default). |
| 16 | `purpose` | varchar(100) | A categoria/motivo do empréstimo informada pelo tomador. |
| 17 | `addr_state` | varchar(5) | A sigla do estado americano de residência do tomador. |

---

## 3. Camada de View: vw_lending_club_powerbi (Dados Refinados)

Esta estrutura consolida a inteligência de negócios do projeto diretamente via query no PostgreSQL, aplicando as regras de cálculo do CPI e as métricas financeiras antes da importação pelo Power BI.

| # | Nome da Coluna | Tipo de Dados | Definição / Regra de Negócio |
| :--- | :--- | :--- | :--- |
| 1 | `id` | varchar(100) | Identificador único do contrato herdado de `fato_loans`. |
| 2 | `loan_status` | varchar(150) | Filtro aplicado para isolar apenas safras maduras (`Fully Paid`, `Charged Off`, `Default`). |
| 3 | `term` | varchar(20) | Prazo original do contrato (36 ou 60 parcelas mensais). |
| 4 | `home_ownership` | varchar(50) | Tipo de moradia declarado pelo tomador de crédito. |
| 5 | `grade` | varchar(5) | Classificação macro de risco do cliente definida pelo banco. |
| 6 | `sub_grade` | varchar(5) | Subcategoria detalhada de risco para análise de sensibilidade. |
| 7 | `purpose` | varchar(100) | Finalidade do uso do capital informada pelo tomador. |
| 8 | `emp_length` | varchar(100) | Tempo de permanência do cliente no emprego atual. |
| 9 | `verification_status`| varchar(100) | Status de validação cadastral da renda declarada. |
| 10 | `addr_state` | varchar(5) | Estado norte-americano de origem da operação. |
| 11 | `data_emissao` | date | Conversão do texto original de data (`issue_d`) para o tipo Date do PostgreSQL. |
| 12 | `ano_emissao` | int4 | Extração do ano de dentro da string `issue_d` para filtros e linhas de tempo. |
| 13 | `classe_renda` | text | Segmentação socioeconômica baseada na `renda_real` (Classes A a E). |
| 14 | `faixa_comprometimento`| text | Razão da parcela anualizada sobre a `renda_real` (Sufocado, Moderado, Confortável). |
| 15 | `renda_real` | numeric | $$\text{renda\_real} = \text{annual\_inc} \times \text{fator\_cpi}$$ |
| 16 | `emprestimo_real` | numeric | $$\text{emprestimo\_real} = \text{funded\_amnt} \times \text{fator\_cpi}$$ |
| 17 | `resultado_financeiro_real`| numeric | **Se Fully Paid:**<br>$$\text{Resultado} = \text{emprestimo\_real} \times \left(\frac{\text{int\_rate}}{100}\right) \times \text{anos\_contrato}$$<br>**Se Charged Off / Default:**<br>$$\text{Resultado} = -\text{emprestimo\_real}$$ |

---

# Data Dictionary (English Version)

This document describes the exact data structure used in the project, detailing the transformation pipeline, the original fact table (`fato_loans`), and the final analytical layer (`vw_lending_club_powerbi`).

---

## 1. Data Origin and ETL Process (Data Pipeline)

The main fact table (`fato_loans`) underwent an **ETL (Extract, Transform, Load)** process to strictly focus on credit risk modeling:
* **Scope Reduction:** Dozens of secondary columns and redundant post-origination behavior metrics were removed to optimize database performance.
* **Mass Filtering:** I retained only the structural records necessary to evaluate the borrower's profile at the time of application versus the final credit outcome (`loan_status`), removing zero-income rows.

---

## 2. Fact Table: fato_loans (Raw Data)

| # | Column Name | Data Type | Description |
| :--- | :--- | :--- | :--- |
| 1 | `id` | varchar(100) | Unique identifier for each loan contract. |
| 2 | `loan_amnt` | numeric(10,2) | The nominal listed amount of the loan applied for by the borrower. |
| 3 | `funded_amnt` | numeric(10,2) | The total nominal amount committed and released to that loan. |
| 4 | `term` | varchar(20) | The number of payments on the loan ("36 months" or "60 months"). |
| 5 | `int_rate` | numeric(5,2) | Interest Rate on the loan (percentage value). |
| 6 | `installment` | numeric(10,2) | The monthly payment nominal amount owed by the borrower. |
| 7 | `grade` | varchar(5) | LC assigned loan grade based on credit risk (A to G). |
| 8 | `sub_grade` | varchar(5) | LC assigned loan subgrade (e.g., A1, B3). |
| 9 | `emp_title` | varchar(255) | The job title supplied by the borrower when applying for the loan. |
| 10 | `emp_length` | varchar(100) | Employment length in years. Possible values are between 0 and 10+. |
| 11 | `home_ownership` | varchar(50) | The home ownership status provided by the borrower (RENT, OWN, MORTGAGE). |
| 12 | `annual_inc` | numeric(15,2) | The self-reported annual nominal income provided by the borrower. |
| 13 | `verification_status`| varchar(100) | Indicates if the borrower's income or source was verified by the bank. |
| 14 | `issue_d` | varchar(20) | The month and year which the loan was officially funded (Text format). |
| 15 | `loan_status` | varchar(150) | Current status of the loan (Fully Paid, Charged Off, Default). |
| 16 | `purpose` | varchar(100) | A category provided by the borrower for the loan request. |
| 17 | `addr_state` | varchar(5) | The US state provided by the borrower in the loan application. |

---

## 3. View Layer: vw_lending_club_powerbi (Analytics Layer)

This structure consolidates the project's business intelligence directly via query in PostgreSQL, applying CPI calculation rules and financial metrics prior to Power BI importation.

| # | Column Name | Data Type | Definition / Business Rule |
| :--- | :--- | :--- | :--- |
| 1 | `id` | varchar(100) | Unique contract identifier inherited from `fato_loans`. |
| 2 | `loan_status` | varchar(150) | Filter applied to isolate only mature cohorts (`Fully Paid`, `Charged Off`, `Default`). |
| 3 | `term` | varchar(20) | Original duration of the credit contract (36 or 60 months). |
| 4 | `home_ownership` | varchar(50) | Home ownership status declared by the credit applicant. |
| 5 | `grade` | varchar(5) | Macro credit risk classification assigned to the customer. |
| 6 | `sub_grade` | varchar(5) | Detailed credit risk subgrade for sensitivity analysis. |
| 7 | `purpose` | varchar(100) | The primary reason or category declared for the loan request. |
| 8 | `emp_length` | varchar(100) | The borrower's length of employment in the current job. |
| 9 | `verification_status`| varchar(100) | Verification status of the borrower's reported income. |
| 10 | `addr_state` | varchar(5) | The borrower's US state of residence. |
| 11 | `data_emissao` | date | Conversion of the original text date (`issue_d`) into a PostgreSQL Date type. |
| 12 | `ano_emissao` | int4 | Year extraction from the `issue_d` string to enable trend and cohort analysis. |
| 13 | `classe_renda` | text | Socioeconomic stratification based on `real_income` (Tiers A to E). |
| 14 | `faixa_comprometimento`| text | Ratio of annualized payments over `real_income` (Suffocated, Moderate, Comfortable). |
| 15 | `renda_real` | numeric | $$\text{real\_income} = \text{annual\_inc} \times \text{cpi\_factor}$$ |
| 16 | `emprestimo_real` | numeric | $$\text{real\_loan} = \text{funded\_amnt} \times \text{cpi\_factor}$$ |
| 17 | `resultado_financeiro_real`| numeric | **If Fully Paid:**<br>$$\text{Result} = \text{real\_loan} \times \left(\frac{\text{int\_rate}}{100}\right) \times \text{contract\_years}$$<br>**If Charged Off / Default:**<br>$$\text{Result} = -\text{real\_loan}$$ |