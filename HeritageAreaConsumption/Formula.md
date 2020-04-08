# Heritage area consumption formula SDG version

## Methodology

Heritage area consumption (heritage_consumption) is calculated as the area of the urban footprint (in the horizon year) that was heritage land in the base year. This includes heritage areas.
The first step is to define the polygon that acknowledges the areas considered as heritage land. Spatial information that delimits heritage land is uploaded in the ‘Footprint’ table of the UP calculator with footprint_id = heritage. The heritage land lost to urbanization is calculated by adding up the hectares of urban area (area) of each analysis point is located within the heritage polygon and that was located outside the urban footprint in the base year (polygon with footprint_id = footprint_base in the ‘Footprint’ table).

## Model

```math

\begin{aligned}

heritage &= \bigg\{ \bigcup_j^n location_{footprint_j} \text\textbar scenario_{footprint_j} = scenario\_id \land name_{footprint_j}="heritage" \bigg\}

\\

footprint\_base &= \bigg\{ location_{footprint_j} \text\textbar scenario_{footprint_j} = scenario\_id \land name_{footprint_j}="footprint\_base" \bigg\}

\\

heritage\_consumption &= \bigg\{ 0.01 * \sum area_{population_i} \text\textbar location_{population_i} \in heritage ∧ location_{population_i} \notin footprint\_base  ∧ scenario_{population_i} = scenario\_id \bigg\}

\end{aligned}

```
