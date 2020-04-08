# Biodiversity land consumption formula SDG version

## Methodology

Biodiversity land consumption (biodiversity_consumption) is calculated as the area of the urban footprint (in the horizon year) that was land with high biodiversity value in the base year. This includes biodiversity areas.
The first step is to define the polygon that acknowledges the areas with high biodiversity value. Spatial information that delimits high-value biodiversity land is uploaded in the ‘Footprint’ table of the UP calculator with footprint_id = biodiversity. The biodiversity land lost to urbanization is calculated by adding up the hectares of urban area (area) of each analysis point i located within the biodiversity polygon and that was located outside the urban footprint in the base year (polygon with footprint_id = footprint_base in the ‘Footprint’ table).

## Model

```math

\begin{aligned}

biodiversity &= \bigg\{ \bigcup_j^n location_{footprint_j} \text\textbar scenario_{footprint_j} = scenario\_id \land name_{footprint_j}="biodiversity" \bigg\}

\\

footprint\_base &= \bigg\{ \bigcup_j^n location_{footprint_j} \text\textbar scenario_{footprint_j} = scenario\_id \land name_{footprint_j}="footprint\_base" \bigg\}

\\

biodiversity\_consumption_{results} &=  \bigg\{ 0.01 * \sum area_{population_i} \text\textbar location_{population_i} \in biodiversity \land area_{population_i} \notin footprint\_base \bigg\}

\end{aligned}

```
