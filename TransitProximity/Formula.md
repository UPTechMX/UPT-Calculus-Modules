# Public transport proximity formula SDG version

## Methodology

Public transport proximity (transit_prox) is calculated by dividing the population (pop_prox_transit) that lives within the maximum recommended distance to a public transport route or stop (max_dist_transiti), by the total population (tot_pop).
First, a buffer (buffer) of the maximum recommended distance (max_dist_transiti) is created from the center of each public transport route or stop, according to the type of transportation (fclassi). Spatial information that defines the distribution of the different types of transport systems in the city is loaded in the ‘Transit’ table of the UP calculator. The maximum recommended distance varies according to the type of transportation system: for example, walking distance is 800 meters for structured transport systems like a BRT or subway, and 300 meters for buses and similar systems.
Second, the population (pop) of all the analysis points contained in the buffer is added up to obtain the population that lives close to public transport (pop_prox_transit).
Third, this population is divided by the total population of the city (tot_pop) to obtain the percentage of the population that lives close to public transport (transit_prox).

## Model

```math

\begin{aligned}

fclass=\{"transit","BRT",...,"subway"\}

\\

transit\_buffer &= \Big\{ \bigcup_i{buffer_{transit_i}} \text{\textbar} fclass_{transit_i} = fclass_j \Big\}

\\

pop\_prox\_transit &= \Big\{ \sum{ population_{population} \text{\textbar} location_{population} \bigcap transit\_buffer} \Big\}

\\

transit\_prox &= (pop\_prox\_transit  / tot\_pop ) * 100

\end{aligned}

```
