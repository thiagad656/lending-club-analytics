# Fontes de Referência e Benchmarks Externos (Ano-Base: 2018)

Este documento centraliza os links oficiais e os relatórios de auditoria utilizados para validar as metas de risco e rentabilidade (Hurdle Rate de ROA > 4,0% aa) aplicadas na análise do portfólio do Lending Club.

---

## 1. Relatórios Anuais Oficiais (SEC Form 10-K)

Para avaliar os concorrentes diretos que operam no mercado norte-americano de crédito ao consumo especializado e cartões de varejo (Monolenders), foram utilizados os balanços financeiros auditados do ano fiscal encerrado em 31 de dezembro de 2018.

### 💳 Discover Financial Services (DFS)
* **ROA Corporativo (2018):** 2,70%
* **Link Direto SEC EDGAR:** [Discover Financial Services - Form 10-K (FY 2018)](https://www.sec.gov/Archives/edgar/data/1393612/000139361219000011/dfs1231201810k.htm)
* **Contexto de Uso:** Utilizado como indicador de eficiência para grandes emissores de crédito direto ao consumidor digital e redes de pagamento nos EUA.

### 💳 Synchrony Financial (SYF)
* **ROA Corporativo (2018):** 3,80%
* **Link Direto SEC EDGAR:** [Synchrony Financial - Form 10-K (FY 2018)](https://www.sec.gov/Archives/edgar/data/1601712/000160171219000053/synchrony1231201810k.htm)
* **Contexto de Uso:** Maior emissora de cartões *private label* (cartões de loja) e financiamentos de varejo dos EUA, servindo como o benchmark de teto para operações de alto rendimento (*high-yield consumer credit*).

---

## 2. Indicadores Macroeconômicos e Banco Central (Federal Reserve)

Os indicadores de taxa livre de risco e a média de rentabilidade de todo o sistema bancário tradicional dos EUA foram extraídos da base de dados oficial do Federal Reserve Bank of St. Louis (FRED).

### 🏛️ Taxa Livre de Risco (Custo de Oportunidade)
* **Métrica:** U.S. 10-Year Treasury Yield (Média de 2,91% aa em 2018)
* **Link Direto FRED:** [Série DGS10 - 10-Year Treasury Constant Maturity Rate](https://fred.stlouisfed.org/series/DGS10)
* **Contexto de Uso:** Define a barreira mínima de atratividade financeira. Explicita que a carteira do Lending Club entregou um prêmio de risco real ao investidor acima dos títulos soberanos.

### 🏛️ Média Geral dos Bancos Comerciais Americanos
* **Métrica:** ROA Médio do Sistema Bancário dos EUA (1,32% aa em 2018)
* **Link Direto FRED:** [Série USROA - Return on Average Assets for all U.S. Banks](https://fred.stlouisfed.org/series/USROA)
* **Contexto de Uso:** Demonstra que o portfólio otimizado no Power BI (ROA linearizado de 4,43% aa) performou significativamente acima da média de mercado devido à especialização em linhas de crédito de varejo de alta margem.

---

# External Benchmarks and Reference Sources (Baseline Year: 2018)

This document centralizes the official links and audit reports used to validate the risk and profitability targets (ROA Hurdle Rate > 4.0% p.a.) applied in the Lending Club portfolio analysis.

---

## 1. Official Annual Reports (SEC Form 10-K)

To evaluate direct competitors operating in the U.S. consumer credit and retail card market (Monolenders), audited financial statements for the fiscal year ended December 31, 2018, were utilized.

### 💳 Discover Financial Services (DFS)
* **Corporate ROA (2018):** 2.70%
* **Direct SEC EDGAR Link:** [Discover Financial Services - Form 10-K (FY 2018)](https://www.sec.gov/Archives/edgar/data/1393612/000139361219000011/dfs1231201810k.htm)
* **Use Case Context:** Used as an efficiency benchmark for major digital direct-to-consumer credit issuers and payment networks in the U.S.

### 💳 Synchrony Financial (SYF)
* **Corporate ROA (2018):** 3.80%
* **Direct SEC EDGAR Link:** [Synchrony Financial - Form 10-K (FY 2018)](https://www.sec.gov/Archives/edgar/data/1601712/000160171219000053/synchrony1231201810k.htm)
* **Use Case Context:** The largest issuer of private-label credit cards (store cards) and retail financing in the U.S., serving as the ceiling benchmark for high-yield consumer credit operations.

---

## 2. Macroeconomic Indicators and Central Bank (Federal Reserve)

Risk-free rate and average profitability indicators for the entire U.S. traditional banking system were extracted from the official database of the Federal Reserve Bank of St. Louis (FRED).

### 🏛️ Risk-Free Rate (Opportunity Cost)
* **Metric:** U.S. 10-Year Treasury Yield (Averaging 2.91% p.a. in 2018)
* **Direct FRED Link:** [Series DGS10 - 10-Year Treasury Constant Maturity Rate](https://fred.stlouisfed.org/series/DGS10)
* **Use Case Context:** Defines the minimum financial attractiveness barrier (Hurdle Rate). It explicitly demonstrates that the Lending Club portfolio delivered a positive risk premium (alpha) to investors above sovereign bonds.

### 🏛️ U.S. Commercial Banks Average Profitability
* **Metric:** Average ROA for all U.S. Commercial Banks (1.32% p.a. in 2018)
* **Direct FRED Link:** [Series USROA - Return on Average Assets for all U.S. Banks](https://fred.stlouisfed.org/series/USROA)
* **Use Case Context:** Demonstrates that the optimized portfolio in Power BI (annualized ROA of 4.43% p.a.) performed significantly above the market average due to its specialization in high-margin retail credit lines.