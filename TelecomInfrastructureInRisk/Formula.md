# Telecommunications infrastructure in risk areas formula SDG version

## Methodology

The total number of telecommunications infrastructure in risk areas (telecom_risk) is calculated as the sum of all the elements inside the telecommunications table that  are inside the risks polygons located in the footprint table

## Model

```math

\begin{aligned}

risk = \bigg\{ \bigcup_j^n location_{footprint_j} \text\textbar scenario_{footprint_j} = scenario\_id \land name_{footprint_j}="risk" \bigg\}

\\

telecom\_risk = \{ count (location_{amenities}) \text\textbar location_{amenity} \in risk ∧ fclass_{amenities} = "telecom" \}

\end{aligned}

```
