# Buffers formulas

## Transit buffer formula SDG version

```math

\begin{aligned}

fclass&=\{"bus","BRT",...,"cycle"\}

\\\\

\{fclass_j\}\_max\_dist &= \{ value_{assumptions} \text{\textbar} name_{assumptions} = fclass_j \land category_{assumptions} = "criteria"\}

\\

buffer_{transit_i} &= \{ (x – longitude_{transit_i})^2 + (y – latitude_{transit_i})^2 = {\{fclass_j\}\_max\_dist}^2 \text{\textbar} fclass_{transit_i}=fclass_j \}

\end{aligned}

```