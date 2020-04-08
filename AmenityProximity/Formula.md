# Amenity proximity formula SDG version

## Methodology

The proximity (amen_proxi) is calculated for each amenity class (fclass) by dividing the population (pop_prox_ami) that lives within the maximum distance recommended for that type of amenity (max_disti), by the total population (tot_pop).
The first step is to create a buffer (bufferi) of the maximum recommended distance (max_disti) from the center of each amenity. Spatial information on the location of amenities and urban services can be found in the ‘Amenities’ table of the UP calculator. Next, the population (pop) of all the analysis points contained in the buffer is added up to obtain the population that has access to a particular amenity (pop_prox_ami). Finally, this population is divided by the total population of the city (tot_pop) to obtain the percentage of the population that lives within the recommended distance for that type of amenity (amen_proxi). In the UP calculator, the values for max_disti are included in the ‘Assumptions’ table and can be identified by their ‘critiera_id’. The ‘criteria_id’ must match the ‘fclass’ field in the ‘Amenities’ table for the tool to be able to generate buffers adequately and calculate the indicators.

## Model

```math

\begin{aligned}

fclass=\{"hospital","atm",...,"school"\}

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
