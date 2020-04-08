# Wastewater treated percentage formula SDG version

## Methodology

The percentage of wastewater that receives treatment is calculated by dividing the volume of treated wastewater (wwtreated) by the total volume of wastewater generated in the city (ww). The result is multiplied by 100 to express it as a percentage.
The total volume of wastewater includes both non-renewable water and renewable water (harvested rainwater) that requires treatment. This volume is estimated by multiplying a factor (ww_factor) that describes the percentage of water that becomes wastewater, by the sum of the total volume of water consumed by the city (tot_water*tot_pop) and the total volume of rainwater harvested in the city. Since the factor (ww_factor) is expressed as a percentage, it is divided by 100 to convert it to a decimal number.
The total volume of rainwater harvested in the city is estimated by multiplying the number of new houses (HU_new) by the percentage of the new houses implementing rainwater harvesting and water saving measures (GBC_pen/100) and by the amount of rainwater harvested per household (rwh).
The number of new housing units (HU_new) is calculated as the difference between the total housing units in the horizon year (hu_tot) and the total housing units in the base year (HU_existing).

## Model

```math

\begin{aligned}

base\_scenario &= \{ scenario\_id_{scenario} \text\textbar is\_base_{scenario}=1 \}

\\

ww\_factor &= \{ value \text\textbar name_{assumptions} = "ww\_factor" \land fclass="water" \land scenario_{assumptions} = scenario\_id \}

\\

wwtreated &= \{ value \text\textbar name_{assumptions} = "wwtreated" \land fclass="water" \land scenario_{assumptions} = scenario\_id \}

\\

rwh &= \{ value \text\textbar name_{assumptions} = "rwh" \land fclass="green\_b\_code" \land scenario_{assumptions} = scenario\_id \}

\\

GBC\_pen &= \{ value \text\textbar name_{assumptions} = "GBC\_pen" \land fclass="green\_b\_code" \land scenario_{assumptions} = scenario\_id \}

\\

HU\_existing &=  \{ hu\_tot_{results} \text\textbar scenario\_id_{results} = base\_scenario \}



\\

HU\_new &= \{ hu\_tot_{results} - HU\_existing \text\textbar scenario\_id.results = scenario\_id \}

\\

ww &= (ww\_factor/100) * (tot\_water_{results} * tot\_pop_{results} + rwh*HU\_new*(GBC\_pen/100))

\\

wwt\_pct &=
\begin{cases}

100 &\text {if } wwtreated > ww

\\

(wwtreated / ww) *100 &\text {if } wwtreated <= ww

\end{cases}

\end{aligned}

```
