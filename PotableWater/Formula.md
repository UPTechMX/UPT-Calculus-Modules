# Population with access to potable water formula SDG version

## Methodology

The percentage of the population with access to potable water (water_acc) is calculated as the sum of the population that has access to potable water (pop_water_net) being connected to the network or access by wells or water spots (pop_water_well), divided by the total population and multiplied by 100.

## Model

```math

\begin{aligned}

water\_acc_{results} &= ( pop\_water\_net_{results} + pop\_water\_well_{results} )
/tot\_pop_{results}*100

\end{aligned}

```
