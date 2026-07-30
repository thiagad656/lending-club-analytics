# 🏦 Lending Club Analytics

**Diagnóstico de Performance de Crédito e Reavaliação de Escala** · *Credit Performance Diagnostic & Scale Reassessment*

Estudo de caso de analytics de crédito construído sobre os dados históricos públicos da **Happen Bank** (nome atual da LendingClub Corporation, NASDAQ: HAPN, após o rebranding concluído em junho de 2026), referentes ao período em que a empresa ainda operava como LendingClub (2007–2018).
*A credit analytics case study built on the public historical data of **Happen Bank** (the current name of LendingClub Corporation, NASDAQ: HAPN, following the rebrand completed in June 2026), covering the period when the company still operated as LendingClub (2007–2018).*

Este é um projeto de análise independente, sem afiliação ou patrocínio da Happen Bank.
*This is an independent analysis project, with no affiliation to or sponsorship from Happen Bank.*

Pipeline completo: **Kaggle → Azure Blob Storage → Python → PostgreSQL → Power BI (DAX)**, com correção monetária por CPI, segmentação proprietária de risco e um plano de ação estratégico C-level.
*Full pipeline: **Kaggle → Azure Blob Storage → Python → PostgreSQL → Power BI (DAX)**, featuring CPI-based monetary correction, proprietary risk segmentation, and a C-level strategic action plan.*

---

## 🗺️ Arquitetura & Pipeline / Architecture & Pipeline

O diagrama completo do pipeline (Kaggle → Azure → Python → PostgreSQL → Power BI) está em [`docs/architecture/architecture.png`](docs/architecture/architecture.png), com a fonte Mermaid em [`architecture.mmd`](docs/architecture/architecture.mmd) e a documentação em [`architecture.md`](docs/architecture/architecture.md).
*The full pipeline diagram (Kaggle → Azure → Python → PostgreSQL → Power BI) is available at [`docs/architecture/architecture.png`](docs/architecture/architecture.png), with the Mermaid source in [`architecture.mmd`](docs/architecture/architecture.mmd) and documentation in [`architecture.md`](docs/architecture/architecture.md).*

---

# 🇧🇷 Português

## Sobre o Projeto

Este projeto audita a performance de crédito de uma carteira de **1,34 milhão de contratos** e **US$ 20,3 bilhões** originados entre 2007 e 2018, usando o dataset público do Lending Club. Todo o pipeline — da ingestão bruta no Azure até o dashboard final no Power BI — foi construído do zero, incluindo correção monetária por inflação (CPI), duas variáveis proprietárias de segmentação de risco, e um diagnóstico de custo de oportunidade que embasa três recomendações estratégicas para o comitê.

## 🔑 Principais Resultados

| Métrica | Valor |
| :--- | :--- |
| Volume total financiado | US$ 20,3 bilhões |
| Contratos encerrados | 1,34 milhão |
| Lucro líquido acumulado | US$ 3,33 bilhões |
| ROA histórico consolidado | **4,43% a.a.** (meta interna: 4,00%) |
| Custo de oportunidade diagnosticado | US$ 299,5 milhões |
| Recuperado na Fase 1 (Reprecificação do Miolo) | US$ 123,75 milhões → ROA projetado de 4,57% a.a. |
| Perdas evitadas (Trava Cirúrgica de Prazo) | até US$ 85,6 milhões |
| Ganho incremental (Realocação da Grade G) | +US$ 4,3 milhões |
| Pendente para a Fase 2 | US$ 175,75 milhões |

> Ver o racional completo de cada número no pitch executivo e no roteiro de fala (seção [Apresentação & Vídeos](#-apresentação--vídeos)).

## 🗂️ Estrutura do Repositório

```
lending-club-analytics/
├── docs/
│   ├── architecture/
│   │   ├── architecture.md        # Documentação do pipeline
│   │   ├── architecture.mmd       # Diagrama Mermaid (fonte)
│   │   └── architecture.png       # Diagrama renderizado
│   ├── presentation/
│   │   ├── slides/                # Pitch executivo (PT-BR / EN-US, .pdf + .pptx)
│   │   └── speech_script/         # Roteiro de teleprompter (PT-BR / EN-US, .docx + .pdf)
│   ├── data_dictionary.md         # Dicionário de dados (fato_loans + view)
│   ├── external_benchmarks.md     # Benchmarks externos (SEC, FRED)
│   └── financial_methodology.md   # Metodologia de CPI e segmentação
├── pbi/
│   ├── LendingClub_Analysis.Report/
│   ├── LendingClub_Analysis.SemanticModel/
│   └── LendingClub_Analysis.pbip  # Projeto Power BI (Power BI Desktop)
├── sql/                            # Scripts de exploração, criação e análise
├── src/
│   └── ingest_azure_to_postgres.py # Ingestão Azure Blob → PostgreSQL
├── .env                            # Variáveis de ambiente (não versionado)
├── .gitignore
└── README.md
```

## ⚙️ Pipeline de Dados

1. **Fonte bruta:** CSV público do Lending Club (`accepted_2007_to_2018Q4.csv`, ~2,2M linhas) carregado no Azure Blob Storage.
2. **Ingestão (`src/ingest_azure_to_postgres.py`):** leitura em streaming direto da nuvem, poda para 17 colunas essenciais, carga incremental em PostgreSQL via SQLAlchemy (chunks de 50.000 linhas).
3. **Camada SQL (`sql/`):** limpeza, filtro de ciclos concluídos (~1,34M linhas), correção monetária por CPI, feature engineering (`renda_real`, `faixa_comprometimento`, `classe_renda`) e criação da view `vw_lending_club_powerbi`.
4. **Camada Power BI (`pbi/`):** modelagem DAX (ROA acumulado e anualizado, custo de oportunidade, cenários de reprecificação), árvore de decomposição e dashboard executivo.

A estrutura de tabelas e colunas (`fato_loans` e a view `vw_lending_club_powerbi`) está documentada em [`docs/data_dictionary.md`](docs/data_dictionary.md); os scripts em [`sql/`](sql/) seguem uma numeração sequencial (`01_` a `07_`) que reflete a ordem lógica da análise, além de scripts exploratórios sem prefixo numérico.

## 📐 Metodologia

- **Correção monetária:** todos os valores nominais foram ajustados para **Dólares Constantes de 2018** via fatores de CPI (BLS CPI-U), permitindo comparar safras de 2007 a 2018 em igualdade de condições.
- **Resultado financeiro real:** por contrato, calculado como `emprestimo_real × (int_rate/100) × anos_contrato` para contratos quitados, ou `-emprestimo_real` (LGD de 100%) para contratos inadimplentes — sem dedução de custos operacionais, recuperações pós-calote ou custo de captação (ver nota metodológica completa no documento).
- **Segmentação proprietária:** `classe_renda` (quintis de renda calibrados nos dados, não em cortes genéricos de governo) e `faixa_comprometimento` (parcela sobre renda, isolando o impacto incremental do contrato — diferente do DTI tradicional de mercado).

Detalhamento completo, fórmulas e justificativa de cada corte em [`docs/financial_methodology.md`](docs/financial_methodology.md).

## 📈 Benchmarks Externos

| Referência | Métrica | Valor (2018) | Fonte |
| :--- | :--- | :--- | :--- |
| Discover Financial Services | ROA corporativo | 2,70% | SEC Form 10-K |
| Synchrony Financial | ROA corporativo | 3,80% | SEC Form 10-K |
| Bancos comerciais dos EUA (média) | ROA médio do sistema | 1,32% | FRED (série USROA) |
| U.S. 10-Year Treasury | Taxa livre de risco | 2,91% | FRED (série DGS10) |

Fontes, links diretos e contexto de uso em [`docs/external_benchmarks.md`](docs/external_benchmarks.md).

## 🎥 Apresentação & Vídeos

| Item | PT-BR | EN-US |
| :--- | :--- | :--- |
| Slides do pitch | [.pptx](docs/presentation/slides/Diagnostico_Credito_Happen_Bank_PT-BR.pptx) · [.pdf](docs/presentation/slides/Diagnostico_Credito_Happen_Bank_PT-BR.pdf) | [.pptx](docs/presentation/slides/Happen_Bank_Credit_Diagnostic_EN-US.pptx) · [.pdf](docs/presentation/slides/Happen_Bank_Credit_Diagnostic_EN-US.pdf) |
| Roteiro de fala | [.docx](docs/presentation/speech_script/Roteiro_Fala_Happen_Bank_PT-BR.docx) · [.pdf](docs/presentation/speech_script/Roteiro_Fala_Happen_Bank_PT-BR.pdf) | [.docx](docs/presentation/speech_script/Happen_Bank_Speech_Script_EN-US.docx) · [.pdf](docs/presentation/speech_script/Happen_Bank_Speech_Script_EN-US.pdf) |

- 🔜 **Em breve:** vídeo do pitch executivo (~12 min) com o resultado completo da análise.
- 🔜 **Em breve:** vídeo do processo técnico — cada decisão tomada, como a IA foi usada ao longo do projeto, e quais perguntas foram feitas no caminho.

## 🛠️ Stack Técnica

`Python` · `Azure Blob Storage` · `PostgreSQL` · `SQL` · `Power BI` · `DAX` · `Mermaid`

## 📦 Fonte dos Dados

[Lending Club Loan Data — Kaggle](https://www.kaggle.com/datasets/wordsforthewise/lending-club) (arquivo `accepted_2007_to_2018Q4.csv`).

## 👤 Autor

**Thiago da Silva**
[LinkedIn](https://www.linkedin.com/in/thiago--dasilva/) · [GitHub](https://github.com/thiagad656/)

---

# 🇺🇸 English

## About the Project

This project audits the credit performance of a **1.34 million contract**, **$20.3 billion** portfolio originated between 2007 and 2018, using the public Lending Club dataset. The entire pipeline — from raw ingestion on Azure to the final Power BI dashboard — was built from scratch, including inflation-based monetary correction (CPI), two proprietary risk-segmentation variables, and an opportunity-cost diagnostic that underpins three strategic recommendations for the committee.

## 🔑 Key Findings

| Metric | Value |
| :--- | :--- |
| Total volume financed | $20.3 billion |
| Closed contracts | 1.34 million |
| Accumulated net profit | $3.33 billion |
| Consolidated historical ROA | **4.43% p.a.** (internal target: 4.00%) |
| Diagnosed opportunity cost | $299.5 million |
| Recovered in Phase 1 (Repricing the Middle) | $123.75 million → projected ROA of 4.57% p.a. |
| Losses avoided (Surgical Term Lock) | up to $85.6 million |
| Incremental gain (Grade G Reallocation) | +$4.3 million |
| Pending for Phase 2 | $175.75 million |

> See the full rationale behind every number in the executive pitch and speech script (see [Presentation & Videos](#-presentation--videos)).

## 🗂️ Repository Structure

```
lending-club-analytics/
├── docs/
│   ├── architecture/
│   │   ├── architecture.md        # Pipeline documentation
│   │   ├── architecture.mmd       # Mermaid diagram (source)
│   │   └── architecture.png       # Rendered diagram
│   ├── presentation/
│   │   ├── slides/                # Executive pitch (PT-BR / EN-US, .pdf + .pptx)
│   │   └── speech_script/         # Teleprompter script (PT-BR / EN-US, .docx + .pdf)
│   ├── data_dictionary.md         # Data dictionary (fato_loans + view)
│   ├── external_benchmarks.md     # External benchmarks (SEC, FRED)
│   └── financial_methodology.md   # CPI and segmentation methodology
├── pbi/
│   ├── LendingClub_Analysis.Report/
│   ├── LendingClub_Analysis.SemanticModel/
│   └── LendingClub_Analysis.pbip  # Power BI project (Power BI Desktop)
├── sql/                            # Exploration, creation, and analysis scripts
├── src/
│   └── ingest_azure_to_postgres.py # Azure Blob → PostgreSQL ingestion
├── .env                            # Environment variables (not versioned)
├── .gitignore
└── README.md
```

## ⚙️ Data Pipeline

1. **Raw source:** public Lending Club CSV (`accepted_2007_to_2018Q4.csv`, ~2.2M rows) loaded into Azure Blob Storage.
2. **Ingestion (`src/ingest_azure_to_postgres.py`):** direct cloud streaming read, pruned to 17 essential columns, incremental load into PostgreSQL via SQLAlchemy (50,000-row chunks).
3. **SQL layer (`sql/`):** cleanup, filtering to completed cohorts (~1.34M rows), CPI-based monetary correction, feature engineering (`renda_real`, `faixa_comprometimento`, `classe_renda`), and creation of the `vw_lending_club_powerbi` view.
4. **Power BI layer (`pbi/`):** DAX modeling (accumulated and annualized ROA, opportunity cost, repricing scenarios), decomposition tree, and executive dashboard.

Table and column structure (`fato_loans` and the `vw_lending_club_powerbi` view) is documented in [`docs/data_dictionary.md`](docs/data_dictionary.md); scripts in [`sql/`](sql/) follow sequential numbering (`01_` through `07_`) reflecting the logical order of the analysis, plus a few unprefixed exploratory scripts.

## 📐 Methodology

- **Monetary correction:** all nominal values were adjusted to **2018 Constant Dollars** using CPI factors (BLS CPI-U), allowing 2007–2018 cohorts to be compared on equal footing.
- **Real financial result:** calculated per contract as `real_loan × (int_rate/100) × contract_years` for fully paid contracts, or `-real_loan` (100% LGD) for defaulted ones — with no deduction for operating costs, post-default recoveries, or cost of funding (see the full methodological note in the document).
- **Proprietary segmentation:** `classe_renda` (income quintiles calibrated on the data itself, not generic government cutoffs) and `faixa_comprometimento` (installment-to-income ratio isolating the loan's incremental impact — different from the market's traditional DTI).

Full formulas and rationale for every cutoff are in [`docs/financial_methodology.md`](docs/financial_methodology.md).

## 📈 External Benchmarks

| Reference | Metric | Value (2018) | Source |
| :--- | :--- | :--- | :--- |
| Discover Financial Services | Corporate ROA | 2.70% | SEC Form 10-K |
| Synchrony Financial | Corporate ROA | 3.80% | SEC Form 10-K |
| U.S. commercial banks (average) | System-wide average ROA | 1.32% | FRED (series USROA) |
| U.S. 10-Year Treasury | Risk-free rate | 2.91% | FRED (series DGS10) |

Sources, direct links, and usage context in [`docs/external_benchmarks.md`](docs/external_benchmarks.md).

## 🎥 Presentation & Videos

| Item | PT-BR | EN-US |
| :--- | :--- | :--- |
| Pitch slides | [.pptx](docs/presentation/slides/Diagnostico_Credito_Happen_Bank_PT-BR.pptx) · [.pdf](docs/presentation/slides/Diagnostico_Credito_Happen_Bank_PT-BR.pdf) | [.pptx](docs/presentation/slides/Happen_Bank_Credit_Diagnostic_EN-US.pptx) · [.pdf](docs/presentation/slides/Happen_Bank_Credit_Diagnostic_EN-US.pdf) |
| Speech script | [.docx](docs/presentation/speech_script/Roteiro_Fala_Happen_Bank_PT-BR.docx) · [.pdf](docs/presentation/speech_script/Roteiro_Fala_Happen_Bank_PT-BR.pdf) | [.docx](docs/presentation/speech_script/Happen_Bank_Speech_Script_EN-US.docx) · [.pdf](docs/presentation/speech_script/Happen_Bank_Speech_Script_EN-US.pdf) |

- 🔜 **Coming soon:** ~12-minute executive pitch video walking through the full analysis.
- 🔜 **Coming soon:** technical process video — every decision made, how AI was used throughout the project, and what questions were asked along the way.

## 🛠️ Tech Stack

`Python` · `Azure Blob Storage` · `PostgreSQL` · `SQL` · `Power BI` · `DAX` · `Mermaid`

## 📦 Data Source

[Lending Club Loan Data — Kaggle](https://www.kaggle.com/datasets/wordsforthewise/lending-club) (`accepted_2007_to_2018Q4.csv`).

## 👤 Author

**Thiago da Silva**
[LinkedIn](https://www.linkedin.com/in/thiago--dasilva/) · [GitHub](https://github.com/thiagad656/)