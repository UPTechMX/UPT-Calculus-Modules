# Population located in not safe settlements formula SDG version

## Methodology

The percentage of population that is located in not safe settlements (percent_notsafe) is calculated as the division of the population in not safe areas (pop_nosafe) by the total population (tot_pop) multiplied by 100.

The pop_nosafe variable is calculated as the sum of the population that is located inside the union of the polygons of slums (slums), informal settlements (informar_set) and inadequate housing (inadeq_hu).

## Method

```math

\begin{aligned}

slums = \bigg\{ \bigcup_j^n slum_{risk_j} \text\textbar scenario_{risk_i} = scenario \bigg\}

\\

pop\_slums_{results} &= \bigg\{ \sum population_{populaiton_i} \text\textbar slum \cap location_{population_i} \bigg\} / tot\_pop_{results} * 100

\end{aligned}

```
