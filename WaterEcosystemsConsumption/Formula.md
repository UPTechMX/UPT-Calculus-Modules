# Water ecosystems consumption formula SDG version

## Methodology

Water related ecosystems land consumption (watereco_consumption) is calculated as the area of the urban footprint (in the horizon year) that was land a water related ecosystem in the base year.
The first step is to define the polygon that acknowledges these areas. Spatial information that delimits water related ecosystem land is uploaded in the ‘Footprint’ table of the UP calculator with footprint_id = water_eco. The land lost to urbanization is calculated by adding up the hectares of urban area (area) of each analysis point is located within the water_eco polygon and that was located outside the urban footprint in the base year (polygon with footprint_id = footprint_base in the ‘Footprint’ table).

## Model

```math

\begin{aligned}

water\_eco &= \bigg\{ \bigcup_j^n location_{footprint_j} \text\textbar scenario_{footprint_j} = scenario\_id \land name_{footprint_j}="water\_eco" \bigg\}

\\

footprint\_base &= \bigg\{ location_{footprint_j} \text\textbar scenario_{footprint_j} = scenario\_id \land name_{footprint_j}="footprint\_base" \bigg\}

\\

watereco\_consumption &= \bigg\{ 0.01 * \sum area_{population_i} \text\textbar location_{population_i} \in water\_eco ∧ location_{population_i} \notin footprint\_base  ∧ scenario_{population_i} = scenario\_id \bigg\}

\end{aligned}

```
