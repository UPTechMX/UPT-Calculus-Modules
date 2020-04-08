# Mountain land consumption formula SDG version

## Methodology

Mountain land consumption (mountain_consumption) is calculated as the area of the urban footprint (in the horizon year) that was land with mountain value in the base year.
The first step is to define the polygon that acknowledges the areas with mountain value. Spatial information that delimits mountain value land is uploaded in the ‘Footprint’ table of the UP calculator with footprint_id = mountain. The mountain land lost to urbanization is calculated by adding up the hectares of urban area (area) of each analysis point i located within the mountain polygon and that was located outside the urban footprint in the base year (polygon with footprint_id = footprint_base in the ‘Footprint’ table).

## Model

```math

\begin{aligned}

mountain\_land &= \bigg\{ \bigcup_j^n location_{footprint_j} \text\textbar scenario_{footprint_j} = scenario \land name_{footprint_j}="mountain" \bigg\}

\\

footprint\_base &= \bigg\{ \bigcup_j^n location_{footprint_j} \text\textbar scenario_{footprint_j} = scenario \land name_{footprint_j}="footprint\_base" \bigg\}

\\

mountain_consumption &=  \bigg\{ 0.01 * \sum area_{population_i} \text\textbar location_{population_i} \in mountain\_land \land area_{population_i} \notin footprint\_base \bigg\}

\end{aligned}

```
