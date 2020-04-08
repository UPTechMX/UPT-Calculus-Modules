# Buffers formulas

## Roads buffer formula SDG version

```math

\begin{aligned}

fclass&=\{"primary","secondary",...,"tertiary"\}

\\\\

\{fclass_j\}\_max\_dist &= \{ value_{assumptions} \text{\textbar} name_{assumptions} = fclass_j \land category_{assumptions} = "criteria"\}

\\

buffer_{roads_i} &= \{ (x – longitude_{roads_i})^2 + (y – latitude_{roads_i})^2 = {\{fclass_j\}\_max\_dist}^2 \text{\textbar} fclass_{roads_i}=fclass_j \}

\end{aligned}

```
