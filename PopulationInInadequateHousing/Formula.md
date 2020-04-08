# Population located in inadequate housing formula SDG version

## Methodology

The percentage of the population living in inadequate housing (percent_inade) is calculated as the sum of the population located in inadequate housing  (pop_inade) divided by the total population (tot_pop) and multiplied by 100.

The pop_inade variable is calculated as the sum of the population that is located inside the inadequate housing polygon (inadequate_hu).

## Model

```math

\begin{aligned}

pop\_inade = \bigg\{ \bigcup_j^n pop\_inade_{risk_j} \text\textbar scenario_{risk_i} = scenario \bigg\}

\\

pop\_inade_{results} &= \bigg\{ \sum population_{populaiton_i} \text\textbar pop\_inade \cap location_{population_i} \bigg\} / tot\_pop_{results}

\\

percent\_inade &= pop\_sflood_{results} / tot\_pop_{results} * 100


\end{aligned}

```
