# Population with access to potable water by water network formula SDG version

## Methodology

The percentage of the population with access to potable water by water network (perc_water_net) is calculated as the sum of the population being connected to the water network (pop_water_network) divided by the total population and multiplied by 100

## Model

```math

\begin{aligned}

pop\_water\_net_{results}&= \big\{ \sum population_{population_i} \text \textbar water\_net_{population_i}=1 \big\}

\\

perc\_water\_net_{results}&= (pop\_water\_net_{results} /  tot\_pop_{results} )  * 100

\end{aligned}

```
