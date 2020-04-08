# Land consumption formula SDG version

## Methodology

Land consumption (land_consumption_km) is calculated as the difference between the city footprint in the horizon year (fp_horizon) and the footprint in the base year (fp_base). The city footprint refers to the total built-up area of a city, including streets, open space and inner vacant land.
Urban footprint for the horizon year is estimated using artificial neural networks based on orography, roads, built-up area, population and employment historical data, using at least two points in time (e.g. years 2000 and 2015). The time gap between these two points in the past determine how far into the future can the forecast go; for example, 2030 would be the horizon year forecasted with 2000 and 2015 information.

## Model

```math

\begin{aligned}

land\_consumption\_0 &=  \bigg\{ 0.01 * \sum area_{population_i} \text\textbar location_{population_i} \in study\_area \land scenario_{population_i}=base\_scenario\_id \bigg\}

\\

land\_consumption\_1 &=  \bigg\{ 0.01 * \sum area_{population_i} \text\textbar location_{population_i} \in study\_area \land scenario_{population_i}=scenario\_id \bigg\}

\\

land\_consumption &= land\_consumption\_1 - land\_consumption\_0

\end{aligned}

```
