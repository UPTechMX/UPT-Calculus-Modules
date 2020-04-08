# Green land availability formula SDG version

## Methodology

Green land consumption (greenland_consumption) is calculated as the area of the urban footprint (in the horizon year) that was land with high environmental value in the base year. This includes forests, natural reserves, etc.
The first step is to define the polygon that acknowledges the areas with high environmental value. Spatial information that delimits high-value environmental land is uploaded in the ‘Footprint’ table with footprint_id = green_land. The green land lost to urbanization is calculated by adding up the hectares of urban area (area) of each analysis points i located within the green_land polygon and that was located outside the urban footprint in the base year (polygon with footprint_id = footprint_base in the ‘Footprint’ table).

## Model

```math

\begin{aligned}

green\_land &= \bigg\{ \bigcup_j^n location_{footprint_j} \text\textbar scenario_{footprint_j} = scenario\_id \land name_{footprint_j}="green\_land" \bigg\}

\\

area\_protected &= \bigg\{ \bigcup_j^n location_{footprint_j} \text\textbar scenario_{footprint_j} = scenario\_id \land name_{footprint_j}="area\_protected" \bigg\}

\\

greenland\_availability_{results} &=  (area_{green\_land} / area_{area\_protected})*100

\\

\end{aligned}

```
