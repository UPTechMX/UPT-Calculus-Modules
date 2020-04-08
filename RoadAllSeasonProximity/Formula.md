# Road proximity formula SDG version

## Methodology

The percentage of the population who lives near of an all season road (allseason_prox) is calculated as the population with proximity to an all season road (pop_prox_allseason) divided by the total population (tot_pop) and multiplied by 100.

To calculate the pop_prox_allseason the first step is to create a buffer (bufferi) of the maximum recommended distance (max_dist_allseason) from each all season road. Then the population (pop) of all the analysis points contained in the buffer is added up to obtain the population that has an all season road.

## Model

```math

\begin{aligned}

fclass=\{"road\_season"\}

\\

tot\_pop = \Big\{ \sum { population_{population} \text{\textbar} scenario_{population} = scenario } \Big\}

\\

\{fclass_j\}\_max\_dist &= \{ value_{criteria} \text{\textbar} fclass_{criteria} = fclass_j \}

\\

\{fclass_j\}\_buffer &= \Big\{ \bigcup_i{buffer_{amenity_i}} \text{\textbar} fclass_{amenity_i} = fclass_j \Big\}

\\

pop\_prox\_\{fclass_i\} &= \Big\{ \sum{ population_{population} \text{\textbar} location_{population} \bigcap \{fclass_j\}\_buffer} \Big\}

\\

\{fclass_i\}\_prox &= ( pop\_prox\_\{fclass_i\} / tot\_pop ) * 100

\end{aligned}

```
