# Elementary school capacity formula SDG version

## Methodology

The elementary school capacity (elementary_capacity) is calculated as the sum of the capacity of each elementary school  (elemen_capacity).

The elemen_capacity variable is calculated as the gross area of each school (gross_area) multiplied by the number of shifts of the school and then divided by the recomended area per student (student_area) to ensure a quality education

## Model

```math

\begin{aligned}

elestudent\_area = \{ values \text\textbar name_{assumptions} = "elestudent\_area" \land fclass='criteria'\}

\\

elemen\_capacity_{amenities} &= \{ gross\_area_{amenities}*shift_{amenities} *elestudent\_area \text\textbar fclass_{amenities} = "elementary\_school" \land scenario_{amenities} = scenario\_var \}

\\

elementary\_capacity_{results} &= \bigg\{ \sum elemen\_capacity_{amenities} \text\textbar fclass_{amenities} = "elementary\_school" \land scenario_{amenities} = scenario\_var \bigg\}

\end{aligned}

```
