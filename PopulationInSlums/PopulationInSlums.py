# -*- coding: utf-8 -*-
import sys
import os
import multiprocessing
import threading
import _thread as thread
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
            
            slums_classes=self.__getClassess("slums")
            
            slums_array="'{"+",".join(slums_classes)+"}'"

            error = True
            count = 0
            while error and count < 3:
                self.__Indicator = Indicator(self.__user)
                db = self.__Indicator.get_up_calculator_connection()
                try:
                    query = """
                        select urbper_indicator_population_in_slums({scenario},{slums})
                        """.format(
                            scenario=self.__scenario,
                            slums=slums_array
                        )
                    LogEvents(
                        "urbper_indicator population in slums",
                        "population in slums started: " + query,
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
                        "population in slums",
                        "population in slums module failed " +
                        str(count) + ": " + str(e),
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    db.close()
                    LogEvents(
                        "population in slums",
                        "population in slums module finished",
                        self.__scenario,
                        self.__user
                    )
        except Exception as e:
            LogEvents(
                "population in slums",
                "unknown error " +
                str(e),
                self.__scenario,
                self.__user
            )
    
    def __getClassess(self,fclass):
        try:
            query="""select distinct classification.name 
                from classification
                where classification.category='risk'
                and classification.fclass='{fclass}'
                """.format(fclass=fclass)
            results = classification.objects.filter(category='risk',fclass=fclass).distinct().values_list('name',flat=True)

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