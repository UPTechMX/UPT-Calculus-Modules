# Buffers formulas

## Amenity buffer formula SDG version

```math

\begin{aligned}

fclass&=\{"hospital","atm",...,"school"\}

\\\\

\{fclass_j\}\_max\_dist &= \{ value_{assumptions} \text{\textbar} name_{assumptions} = fclass_j \land category_{assumptions} = "criteria"\}

\\

buffer_{amenity_i} &= \{ (x – longitude_{amenity_i})^2 + (y – latitude_{amenity_i})^2 = {\{fclass_j\}\_max\_dist}^2 \text{\textbar} fclass_{amenity_i}=fclass_j  \}

\end{aligned}

```
