# Population located in informal settlements formula SDG version

## Methodology

The percentage of the population living in informal settlements (percent_informalset) is calculated as the sum of the population located in informal settlements (pop_informalset) divided by the total population (tot_pop) and multiplied by 100.

The pop_informalset variable is calculated as the sum of the population that is located inside the informal settlements polygon (informal_set).

## Model

```math

\begin{aligned}

pop\_informalset = \bigg\{ \bigcup_j^n pop\_informalset_{risk_j} \text\textbar scenario_{risk_i} = scenario \bigg\}

\\

pop\_informalset_{results} &= \bigg\{ \sum population_{populaiton_i} \text\textbar pop\_informalset \cap location_{population_i} \bigg\} / tot\_pop_{results}

\\

percent\_informalset &= pop\_informalset_{results} / tot\_pop_{results} * 100


\end{aligned}

```
