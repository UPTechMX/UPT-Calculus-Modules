# Buffers formulas

## Risk buffer formula SDG version

```math

\begin{aligned}

fclass&=\{"flood",...,"slums"\}

\\\\

\{fclass_j\}\_max\_dist &= \{ value_{assumptions} \text{\textbar} name_{assumptions} = fclass_j \land category_{assumptions} = "criteria"\}

\\

buffer_{risk_i} &= \{ (x – longitude_{risk_i})^2 + (y – latitude_{risk_i})^2 = {\{fclass_j\}\_max\_dist}^2 \text{\textbar} fclass_{risk_i}=fclass_j \}

\end{aligned}

```
