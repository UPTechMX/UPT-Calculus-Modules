# Solid waste recycled formula SDG version

## Methodology

The percentage is obtained by dividing the solid waste collected by the trucks (trucks_collect) by the recycling capacity of the transfer stations (rec_cap).

The solid waste collected by the truck is obtained by multiplying the trucks coverage (truck_coverage) by the solid waste generation per person (waste_per) by the total population  (tot_pop).

## Model

```math

\begin{aligned}

truck\_coverage &= \{ value_{assumptions} \text{\textbar} name_{assumptions} = "truck\_coverage" \land category_{assumptions} = "waste"\}

\\

waste\_per &= \{ value_{assumptions} \text{\textbar} name_{assumptions} = "waste\_per" \land category_{assumptions} = "waste"\}

\\

rec\_cap &= \{ value_{assumptions} \text{\textbar} name_{assumptions} = "rec\_cap" \land category_{assumptions} = "waste"\}

\\

trucks\_collect &= truck\_coverage * waste\_per * tot\_pop_{results}

\\

waste\_recycled_{results} &= trucks\_collect / rec\_cap

\end{aligned}

```
