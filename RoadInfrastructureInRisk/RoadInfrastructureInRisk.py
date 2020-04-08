# -*- coding: utf-8 -*-
import sys
import os
import time
import gc
from random import randint
import json
import math


from plup.indicators.Indicator import Indicator
from plup.Helpers.Vacuum import vacuum
from plup.Helpers.LogEvents import LogEvents
from django.db import transaction
from plup.models import assumptions,classification

class Module:
    def __init__(self, user, scenario, extra_dict_arguments=None):
        self.__user = user
        self.__scenario = scenario

    def run(self):
        try:
            self.__Indicator = Indicator(self.__user)
            road_classes=self.__getClassess("road_infrastructure","roads")
            road_classes_array="'{"+",".join(road_classes)+"}'"            
            risk_classes=self.__getClassess("risk","risk")
            risk_classes_array="'{"+",".join(risk_classes)+"}'"
            error = True
            count = 0
            while error and count < 3:
                print("Entrando\n")
                self.__Indicator = Indicator(self.__user)
                db = self.__Indicator.get_up_calculator_connection()
                try:
                    query = """
                        select urbper_indicator_road_infrastructure_in_risk({scenario},'road_risk'::varchar(10),{road_class},{risk_classes})
                        """.format(
                            scenario=self.__scenario, 
                            road_class=road_classes_array,
                            risk_classes=risk_classes_array
                        )
                    LogEvents(
                        "road infrastructure in risk",
                        "road infrastructure in risk module started: " + query,
                        self.__scenario,
                        self.__user
                    )
                    with transaction.atomic():
                        db.execute(query)
                except Exception as e:
                    error = True
                    count += 1
                    time.sleep(randint(1, 3))
                    db.close()
                    LogEvents(
                        "road infrastructure in risk",
                        "road infrastructure in risk module failed " +
                        str(count) + ": " + str(e),
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    db.close()
                    LogEvents(
                        "road infrastructure in risk",
                        "road infrastructure in risk module finished",
                        self.__scenario,
                        self.__user
                    )
        except Exception as e:
            LogEvents(
                "road infrastructure in risk",
                "unknown error " +
                str(e),
                self.__scenario,
                self.__user
            )
    
    def __getClassess(self,fclass,category):
        try:
            query="""select distinct classification.name 
                from classification
                where classification.category='{category}'
                and classification.fclass='{fclass}'
                """.format(fclass=fclass,category=category)
            results = classification.objects.filter(category=category,fclass=fclass).distinct().values_list('name',flat=True)

            LogEvents(
                "classes",
                "classes finished: " + query,
                self.__scenario,
                self.__user
            )

            results_set=[row for row in results]
                
            results=results_set
        except Exception as e:
            error = True
            time.sleep(randint(1, 3))
            LogEvents(
                "classes",
                "classes failed: " + str(e),
                self.__scenario,
                self.__user
            )
            return []
        else:
            error = False
            LogEvents(
                "classes",
                "classes finished",
                self.__scenario,
                self.__user
            )
            return results
    
    