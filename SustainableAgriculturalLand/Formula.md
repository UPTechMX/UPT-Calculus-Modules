# Sustainable agriculture land formula SDG version

## Methodology

Sustainable agricultural land  (agric_sustainable) is calculated as the percentage of agricultural land that is under productive and sustainable agiriculture
The first step is to define the polygon that acknowledges sustainable agricultural land. Spatial information that delimits sustainable agricultural land is uploaded in the ‘Footprint’ table of the UP calculator with footprint_id = agricultural_sus. The percentage of sustainable agricultural land is calculated by comparing the hectares of sustainable agricultural land  and the hectares of the agricultural polygon  (polygon with footprint_id =agricultural in the ‘Footprint’ table).

## Model

```math

\begin{aligned}

agricultural = \bigg\{ \bigcup_j^n location_{footprint_j} \text\textbar scenario_{footprint_j} = scenario \land name_{footprint_j}="agricultural" \bigg\}

\\

sustainable\_agri = \bigg\{ \bigcup_j^n location_{footprint_j} \text\textbar scenario_{footprint_j} = scenario \land name_{footprint_j}="agricultural\_sus" \bigg\}

\\

agricultur\_sus = agricultural \cap sustainable\_agri

\\

agric\_sustainable\_pct_{results} = (area_{agricultur\_sus} / area_{agricultural}) * 100

\end{aligned}

```
