# Road infrastructure in risk formula SDG version

## Methodology

The total number of kilometers of roads infrastructure in risk areas (roads_risk) is calculated as the sum of the length of the roads that  are inside the risks polygons located in the footprint table divided

## Model

```math

\begin{aligned}

risk = \bigg\{ \bigcup_j^n location_{footprint_j} \text\textbar scenario_{footprint_j} = scenario\_id \land name_{footprint_j}="risk" \bigg\}

\\


road\_risk_{results} =\bigg\{ \sum length_{roads} | location_{roads} \in risk \land scenario_{roads}=scenario\_id \big\}

\end{aligned}

```
