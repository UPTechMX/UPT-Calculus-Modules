# Edudational infrastructure in risk formula SDG version

## Methodology

The total number of educational infrastructure in risk areas (edu_risk) is calculated as the sum of all the amenities with the fclass related to educational infrastructure (as school, elementary_school, highschool) that  are inside the risks polygons located in the footprint table

## Model

```math

\begin{aligned}

risk = \bigg\{ \bigcup_j^n location_{footprint_j} \text\textbar scenario_{footprint_j} = scenario\_id \land name_{footprint_j}="risk" \bigg\}

\\

edu\_risk = \{ count (location_{amenities}) \text\textbar location_{amenity} \in risk ∧ fclass_{amenities} = "edu" \}

\end{aligned}

```
