# High school ratio formula SDG version

## Methodology

The percentage of students that can be served by the highschools (highmax_perc) is calculated as the division of the highschool capacity (highschool_capacity) by the population that is in age of attending  highschool (pop_high).

To calculate the pop_high there are two options. The first, if exists information of population by age per analysis point the calculation sum  the population in age to attend highschool (highpop) from each analysis point. The second option is to have a global percentage of  population in age to attend highschool (highpop_perc), if this value is used, then to calculate pop_high is necessary to multiply highpop_perc by the total population (tot_pop).

## Model

```math

\begin{aligned}

highpop\_perc &= \{ highpop\_perc\_{assumptions} \text\textbar  scenario_{assumptions}=scenario\_id \land name_{assumptions}="highpop\_perc" \land fclass_{assumptions}="criteria"  \}

\\
pop\_high &=  
\begin{cases}

\bigg\{ \sum highpop_{population_i} \text\textbar scenario_{population_i}=scenario\_id \bigg\} &\text{if } highpop\_perc = null
\\
tot\_pop_{results} * highpop\_perc &\text{if } highpop\_perc\ != null
\end{cases}
\\
highmax\_perc &= highschool\_capacity_{results} / pop\_high


\end{aligned}

```
