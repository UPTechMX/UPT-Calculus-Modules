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
            
            road_classes=self.__getClassess("allseason")
            
            road_classes_array="'{"+",".join(road_classes)+"}'"            
            
            error = True
            count = 0
            while error and count < 3:
                self.__Indicator = Indicator(self.__user)
                db = self.__Indicator.get_up_calculator_connection()
                try:
                    query = """
                        select urbper_indicator_road_all_season_proximity({scenario},'allseason_prox'::varchar(10),'pop_prox_allseason'::varchar(10),{road_class})
                        """.format(
                            scenario=self.__scenario, 
                            road_class=road_classes_array
                        )
                    LogEvents(
                        "all season roads",
                        "all season roads module started: " + query,
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
                        "all season roads",
                        "all season roads module failed " +
                        str(count) + ": " + str(e),
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    db.close()
                    LogEvents(
                        "all season roads",
                        "all season roads module finished",
                        self.__scenario,
                        self.__user
                    )
        except Exception as e:
            LogEvents(
                "all season roads",
                "unknown error " +
                str(e),
                self.__scenario,
                self.__user
            )

    def __getClassess(self,fclass):
        try:
            query="""select distinct classification.name 
                from classification
                where classification.category='{category}'
                and classification.fclass='{fclass}'
                """.format(fclass=fclass)
            results = classification.objects.filter(category='roads',fclass=fclass).distinct().values_list('name',flat=True)

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
        else:
            error = False
            LogEvents(
                "classes",
                "classes finished",
                self.__scenario,
                self.__user
            )
            return results