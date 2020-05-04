# UPT Calculus Modules

## Table of contents

1. Description
1. How To Use
1. References
1. License
1. Author Info

## Description

This project contains all the calculation methods to evaluate the indicators included in the Urban Performance tool. 35 indicators related to the sustainable Development Goals were developed in order to assess the performance of several urban growth scenarios in the UP tool.

The Urban Planning Tool Urban Performance assesses the city's present and future performance by modeling investment projects or policies in a range of indicators related to the Sustainable Development Goals (SDG), including aspects such as poverty reduction, water management, energy, infrastructure, public transportation, climate action, etc. Urban Performance models multiple scenarios and spatial solutions to test the effectiveness of their contributions to sustainable development. Scenarios can serve.

## Main Technologies Used

- PL/PGSQL
- Python 3
- Django
- Celery

## How To Use

Read the Installation section.

### Installation

To install a calculus module:

1. Donwload the zip file available inside the directory of each Calculus Module,
1. Use the module installer available in the UrbanPerformance tool to enabled it in the geoportal.

#### Note

You will only be able to install the calculus module if you have an administrator role in the geoportal.

### Developing new indicators

To develop new Calculus Modules you can use any of the existing ones as a layout.

Some of them perform Parallel processing so you have to use the one that better fits you necesity.

## References

For detailed infomation about Djagno please visit [https://www.djangoproject.com/](https://www.djangoproject.com/)

For detailed infomation about Celery please visit [http://www.celeryproject.org/](http://www.celeryproject.org/)

For detailed infomation about how to use Celery with Django please visit [http://docs.celeryproject.org/en/latest/django/index.html](http://docs.celeryproject.org/en/latest/django/index.html)

## License

- SPDX-License-Identifier: MIT
- Copyright (c) 2020 CAPSUS S.C.

## Acknowledgements

We acknowledge the invaluable support of the [World Bank’s Trust Fund for Statistical Capacity Building](https://worldbank.org/) (TFSCB) in making this project. This tool was conceptualized at [City Planning Labs](https://collaboration.worldbank.org/content/sites/collaboration-for-development/en/groups/city-planning-labs.html) with the technical support from [SITOWise](https://www.sitowise.com/en). The tools were developed by [CAPSUS](http://capsus.mx/) and are maintained by [UPTech](http://up.technology/) and a community of developers. 
