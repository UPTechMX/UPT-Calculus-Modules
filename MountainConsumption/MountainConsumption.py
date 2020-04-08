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
            
            mountain_classes=self.__getMountainClassess()
            mountain_array="'{"+",".join(mountain_classes)+"}'"
            error = True
            count = 0
            while error and count < 3:
                self.__Indicator = Indicator(self.__user)
                db = self.__Indicator.get_up_calculator_connection()
                try:
                    query = """
                        select urbper_indicator_mountain_land_consumption({scenario},'mountain_consumption',{mountain})
                        """.format(
                            scenario=self.__scenario, 
                            mountain=mountain_array,
                        )
                    LogEvents(
                        "mountain land consumption",
                        "mountain land consumption module started: " + query,
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
                        "mountain land consumption",
                        "mountain land consumption module failed " +
                        str(count) + ": " + str(e),
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    db.close()
                    LogEvents(
                        "mountain land consumption",
                        "mountain land consumption module finished",
                        self.__scenario,
                        self.__user
                    )
        except Exception as e:
            LogEvents(
                "mountain land consumption",
                "unknown error " +
                str(e),
                self.__scenario,
                self.__user
            )

    def __getMountainClassess(self):
        try:
            error = True
            count = 0
            while error and count < 3:
                try:
                    query="""select distinct classification.name 
                        from classification
                        where classification.category='footprint'
                        and classification.fclass='mountain'
                        """
                    results = classification.objects.filter(category='footprint',fclass='mountain').distinct().values_list('name',flat=True)

                    LogEvents(
                        "mountain",
                        "mountain classes finished: " + query,
                        self.__scenario,
                        self.__user
                    )

                    results_set=[row for row in results]
                        
                    results=results_set
                except Exception as e:
                    error = True
                    count += 1
                    time.sleep(randint(1, 3))
                    LogEvents(
                        "mountain",
                        "mountain classes failed " +
                        str(count) + ": " + str(e),
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    LogEvents(
                        "mountain",
                        "mountain classes finished",
                        self.__scenario,
                        self.__user
                    )
                    return results
        except Exception as e:
            LogEvents(
                "mountain",
                "unknown error " + str(e),
                self.__scenario,
                self.__user
            )