## Metodologia de Ajuste Monetário e Performance Financeira

Para garantir a comparabilidade dos dados financeiros ao longo do tempo (2007-2018), aplicou-se um fator de correção monetária baseado no **CPI (Consumer Price Index)** para converter todos os valores nominais para **Dólares Constantes de 2018**.

* **Fonte dos dados:** U.S. Bureau of Labor Statistics (BLS), [CPI-U (Consumer Price Index for All Urban Consumers)](https://www.bls.gov/cpi/).
* **Critério:** Utilizou-se a média anual do CPI para cada ano de emissão dos empréstimos (`issue_d`).
* **Fatores aplicados:**
    - 2007: 1.21
    - 2008-2009: 1.17
    - 2010: 1.15
    - 2011: 1.11
    - 2012: 1.09
    - 2013: 1.07
    - 2014-2015: 1.05
    - 2016: 1.04
    - 2017: 1.02
    - Base (2018): 1.00

---

### 1. Atualização de Rendas e Poder de Compra

Tratar dólares de anos diferentes como equivalentes mascararia o risco real. A inflação acumulada reduz o poder de compra; logo, um cliente com renda nominal de \$55.000 em 2007 tinha uma capacidade financeira real muito superior a um cliente com os mesmos \$55.000 em 2018.

**Mecânica Matemática:**
A taxa de indexação é calculada dividindo o CPI do ano base pelo ano de emissão:

$$\text{Fator de Correção} = \frac{\text{CPI}_{2018}}{\text{CPI}_{\text{Ano de Emissão}}}$$

A renda real atualizada na View segue a fórmula:

$$renda\_real = annual\_inc \times fator\_cpi$$

* **Impacto na Regra de Negócio (Categorização):** Um cliente de 2007 com renda nominal de \$55.000, ao ter o valor corrigido pelo fator 1.21, atinge uma **renda real de \$66.550**. Sem o ajuste, ele seria classificado incorretamente como *Classe D (Baixa Renda)*. Com o ajuste, o Power BI o classifica corretamente como *Classe C (Classe Média)*, normalizando a análise de risco entre safras temporais.

---

### 2. Lógica do Resultado Financeiro Real (Performance de Crédito)

A coluna `resultado_financeiro_real` não representa o Lucro Líquido contábil final do banco (Net Income), mas atua como um indicador fiel de **Performance Líquida de Crédito (Net Credit Performance)** por contrato, modelado sob dois cenários de estresse de risco:

#### Cenário A: Contrato Adimplido (`Fully Paid`)
O banco recupera o capital principal investido e obtém lucro através dos juros acumulados sobre o saldo corrigido:

$$Resultado = emprestimo\_real \times \left(\frac{int\_rate}{100}\right) \times anos\_contrato$$

*Onde os anos do contrato são definidos como 3 (para 36 meses) ou 5 (para 60 meses).*

#### Cenário B: Contrato Inadimplido (`Charged Off` ou `Default`)
Assume-se o pior cenário de risco com uma **LGD (Loss Given Default) de 100%**. Quando o banco decreta o prejuízo do contrato, assume-se a perda integral do valor financiado ajustado:

$$Resultado = -emprestimo\_real$$

*Nota Metodológica: Para fins de simplificação analítica e devido à natureza pública do dataset, este cálculo não deduz custos operacionais internos, taxas de recuperação parciais pós-calote (Recoveries) ou o custo de captação de fundos do banco (Spread).*

==============================================================================

## Monetary Adjustment and Financial Performance Methodology

To ensure the comparability of financial data over time (2007-2018), a monetary correction factor based on the **CPI (Consumer Price Index)** was applied to convert all nominal values into **2018 Constant Dollars**.

* **Data Source:** U.S. Bureau of Labor Statistics (BLS), [CPI-U (Consumer Price Index for All Urban Consumers)](https://www.bls.gov/cpi/).
* **Criteria:** The annual average CPI for each loan issuance year (`issue_d`) was used.
* **Applied Factors:**
    - 2007: 1.21
    - 2008-2009: 1.17
    - 2010: 1.15
    - 2011: 1.11
    - 2012: 1.09
    - 2013: 1.07
    - 2014-2015: 1.05
    - 2016: 1.04
    - 2017: 1.02
    - Base (2018): 1.00

---

### 1. Income Update and Purchasing Power

Treating dollars from different years as equivalents would mask the true credit risk. Accumulated inflation erodes purchasing power; therefore, a borrower with a nominal income of \$55,000 in 2007 possessed a significantly higher real financial capacity than a borrower with the same \$55,000 in 2018.

**Mathematical Mechanics:**
The indexation rate is calculated by dividing the baseline year CPI by the issuance year CPI:

$$\text{Correction Factor} = \frac{\text{CPI}_{2018}}{\text{CPI}_{\text{Issuance Year}}}$$

The adjusted real income in the View follows the formula:

$$real\_income = annual\_inc \times cpi\_factor$$

* **Business Rule Impact (Categorization):** A 2007 borrower with a nominal income of \$55,000, when adjusted by the 1.21 factor, achieves a **real income of \$66,550**. Without this adjustment, they would be incorrectly classified as *Tier D (Low Income)*. With the adjustment, Power BI correctly categorizes them as *Tier C (Middle Class)*, normalizing risk analysis across different historical cohorts.

---

### 2. Real Financial Result Logic (Net Credit Performance)

The `resultado_financeiro_real` column does not represent the bank's final accounting Net Income, but serves as a reliable proxy for **Net Credit Performance** per contract, modeled under two strict risk stress scenarios:

#### Scenario A: Fully Paid Contract (`Fully Paid`)
The bank recovers the invested principal capital and generates profit through the accumulated interest over the adjusted balance:

$$Result = real\_loan \times \left(\frac{int\_rate}{100}\right) \times contract\_years$$

*Where contract years are mapped to either 3 (for 36 months) or 5 (for 60 months).*

#### Scenario B: Defaulted Contract (`Charged Off` or `Default`)
The worst-case risk scenario is assumed with a **100% LGD (Loss Given Default)**. When the bank charges off the loan, it recognizes the total loss of the adjusted funded amount:

$$Result = -real\_loan$$

*Methodological Note: For analytical simplicity and due to the public nature of the dataset, this calculation does not deduct internal operating expenses, partial post-default recovery rates (Recoveries), or the bank's cost of funding (Spread).*