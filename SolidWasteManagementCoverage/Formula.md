# Solid waste management coverage formula SDG version

## Methodology

There are two components that determine the capacity of the solid waste management system to cope with the volume of solid waste generated in the city (solidw_coverage): the landfill’s coverage (landfill_coverage) and the collection trucks’ coverage (truck_coverage). To measure the coverage of the system as a whole, the weakest link in the process must be identified. If both the landfill and the collection trucks can handle the whole waste generation, then there is complete coverage. However, if either the landfill or the collection trucks cannot handle the generated waste, then the system’s coverage will be equal to the capacity of the component that has the largest deficiency.

The landfill is said to have complete coverage (landfill_coverage=100) when the quantity of waste it can handle in a week (land_ef*7) is greater than the city's waste generation per week, which is equal to the waste generation per person per day (waste_per) multiplied by the total population (tot_pop) and by the number of days in a week (7). Otherwise, the landfill’s coverage is equal to the quantity of waste that the landfill can handle in a week (land_ef*7) divided by the city’s total waste generation (waste_per*tot_pop*7). The result is multiplied by 100 to express it as a percentage.

The truck coverage is assessed based on the collection capacity of the entire truck fleet (truckcol_cap) multiplied by the number of weekly collections (collections) that each truck carries out. If this number is greater than the city’s waste generation per week (waste_per*tot_pop*7), there is complete coverage by the collection trucks (truck_coverage=100). Otherwise, the collection truck’s coverage is equal to the daily collection capacity of the entire truck fleet (truckcol_cap) multiplied by the number of times waste is collected each week (collections), and divided by the city’s total waste generation (waste_per*tot_pop*7). The result is multiplied by 100 to express it as a percentage.

The daily collection capacity of the entire truck fleet (truckcol_cap) is estimated as the multiplication of the number of trucks available for solid waste collection (truck1_quant) by the average capacity of an individual collection truck (truck1_cap).

## Models

```math

\begin{aligned}

truckcol\_cap = truck1\_quant*truck1\_cap*1000

\\

truck\_coverage &=
\begin{cases}
    100 &\text{if } (7*(waste\_per*tot\_pop)) < (truckcol\_cap*collections)
\\
    (truckcol\_cap*collections/((7)*(waste\_per*tot\_pop)))*100 &\text{others }
\end{cases}

\\\\

landfill\_coverage &=
\begin{cases}
    100 &\text{if } (land\_ef*7*1000) > (waste\_per*tot\_pop*7)
\\
    ((land\_ef*7*1000)/(waste\_per*tot\_pop*7))*100  &\text{others }
\end{cases}

\\\\

solidw\_coverage &=
\begin{cases}
    100 &\text{if } landfill\_coverage = 100 \land truck\_coverage =100
    \\
    truck\_coverage &\text{if } truck\_coverage < landfill\_coverage
    \\
    landfill\_coverage &\text{others }
\end{cases}

\end{aligned}

```
