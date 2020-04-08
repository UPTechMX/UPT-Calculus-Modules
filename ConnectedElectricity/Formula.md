# Population connected to the electricity network formula SDG version

## Methodology

The percentage of the population that is connected to electricity (con_elec) is calculated as the sum of the population connected to the electricity network (pop_con_elec) divided by the total population then multiplied by 100.

To calculate pop_con_elec the percentage of connected population (con_elec) is multiplied by the population of each analysis point (pop) and then all the population obtained is added to obtain the pop_con_elec variable.

## Model

```math

\begin{aligned}

tot\_pop = \Big\{ \sum { population_{population} \text{\textbar} scenario_{population} = scenario } \Big\}

\\

pop\_con\_elec &= \Big\{ \sum population_{population_i} \text{\textbar} con\_elec_{population_i} = 1 \Big\}

\\

con\_elec &= ( pop\_con\_elec / tot\_pop ) * 100


\end{aligned}

```
