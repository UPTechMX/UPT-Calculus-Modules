# Population connected to the sewage network formula SDG version

## Methodology

The percentage of the population that is connected to the sewage network (con_sew) is calculated as the sum of the population connected to the sewage network (pop_con_sew) between the total population multiplied by 100.

## Modelo

```math

\begin{aligned}

pop\_con\_sew_{results} = \bigg\{ \sum population_{population_i} \text\textbar con\_sew_{population_i} = 1 \bigg\}

\\

con\_sew_{results} = ( pop\_con\_sew_{results} / tot\_pop_{results} ) * 100

\end{aligned}

```
