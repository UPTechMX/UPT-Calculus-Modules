# Population with access to potable water by wells or water spots formula SDG version

## Methodology

The percentage of the population with access to potable water by wells or water spots (perc_water_well) is calculated as the sum of the population that access to potable water (pop_water_well)  by wells or water spots divided by the total population and multiplied by 100.

To calculate it a buffer (buffer) of the maximum recommended distance (max_dist_water) is created from the center of each well or water spot, then if the analysis point is inside the buffer is considered that the analysis point have 100% access to water.

## Model

```math

\begin{aligned}

buffer\_dwells &= \Big\{ \bigcup_i{buffer_{amenity_i}} \text{\textbar} fclass_{amenity_i} = "dwells" \Big\}

\\

pop\_water\_dwe_{results}&= \Big\{ \sum{ population_{population} \text{\textbar} location_{population} \bigcap buffer\_dwells } \Big\}

\\

perc\_water\_well_{results}&= (pop_water_dwe_{results} / tot_pop_results) * 100

\end{aligned}

```
