# Population located in sea flood areas formula SDG version

## Methodology

The percentage of the population living in sea flood areas (percent_sflood) is calculated as the sum of the population located in areas prone to floods due to sea rising levels (pop_sflood) divided by the total population (tot_pop) and multiplied by 100.

The pop_sflood variable is calculated as the sum of the population that is settle inside the sea flood areas polygon (sea_floods).

## Model

```math

\begin{aligned}

sea\_floods = \bigg\{ \bigcup_j^n sea\_floods_{risk_j} \text\textbar scenario_{risk_i} = scenario \bigg\}

\\

pop\_sflood_{results} &= \bigg\{ \sum population_{populaiton_i} \text\textbar sea\_floods \cap location_{population_i} \bigg\} / tot\_pop_{results}

\\

percent\_sflood &= pop\_sflood_{results} / tot\_pop_{results} * 100


\end{aligned}

```
