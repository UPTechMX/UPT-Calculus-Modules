# Population located in slums formula SDG version

## Methodology

The percentage of the population that is located in slums (pop_slum) is obtained by adding all the population in all the analysis point inside the slums polygons divided by the total population (tot_pop) and multiplied by 100

## Model

```math

\begin{aligned}

slums = \bigg\{ \bigcup_j^n slum_{risk_j} \text\textbar scenario_{risk_i} = scenario \bigg\}

\\

pop\_slums_{results} &= \bigg\{ \sum population_{populaiton_i} \text\textbar slum \cap location_{population_i} \bigg\} / tot\_pop_{results} * 100

\end{aligned}

```
