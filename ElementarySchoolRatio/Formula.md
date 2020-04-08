# Elementary school ratio formula SDG version

## Methodology

The percentage of students that can be served by the elementary schools (elemax_perc) is calculated as the division of the elementary school capacity (elementary_capacity) by the population that is in age of attending elementary schools (pop_elemen).

To calculate the pop_elemen there are two options. The first, if exists information of population by age per analysis point the calculation sums  the population in age to attend elementary school (elepop) from each analysis point. The second option is to have a global percentage of  population in age to attend elementary school (elepop_perc), if this value is used, then to calculate pop_elemen is necessary to multiply elepop_perc by the total population (tot_pop).

## Model

```math

\begin{aligned}

elepop\_perc &= \{ elepop\_perc\_{assumptions} \text\textbar  scenario_{assumptions}=scenario\_id \land name_{assumptions}="elepop\_perc" \land fclass_{assumptions}="criteria"  \}

\\
pop\_elemen_{results} &=  
\begin{cases}

\bigg\{ \sum elepop_{population_i} \text\textbar scenario_{population_i}=scenario\_id \bigg\} &\text{if } elepop\_perc = null
\\
tot\_pop_{results} * elepop\_perc &\text{if } elepop\_perc\ != null
\end{cases}
\\
elemax\_perc_{results} &= elementary\_capacity_{results} / pop\_elemen


\end{aligned}

```
