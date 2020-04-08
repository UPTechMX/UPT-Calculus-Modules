# High school capacity formula SDG version

## Methodology

The high school capacity (highschool_capacity) is calculated as the sum of the capacity of each elementary school  (high_capacity).

The high_capacity variable is calculated as the gross area of each school (gross_area) multiplied by the number of shifts of the school and then divided by the recomended area per student (highstudent_area) to ensure a quality education

## Model

```math

\begin{aligned}

highstudent\_area = \{ values \text\textbar name_{assumptions} = "highstudent\_area" \land fclass='criteria'\}

\\

high\_capacity_{amenities} &= \{ gross\_area_{amenities}*shift_{amenities} *highstudent\_area \text\textbar fclass_{amenities} = "high\_school" \land scenario_{amenities} = scenario\_var \}

\\

highschool\_capacity_{results} &= \bigg\{ \sum elemen\_capacity_{amenities} \text\textbar fclass_{amenities} = "high\_school" \land scenario_{amenities} = scenario\_var \bigg\}

\end{aligned}

```
