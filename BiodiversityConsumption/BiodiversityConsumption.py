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
from plup.models import assumptions
from plup.models import classification

class Module:
    def __init__(self, user, scenario, extra_dict_arguments=None):
        self.__user = user
        self.__scenario = scenario

    def run(self):
        try:
            self.__Indicator = Indicator(self.__user)
            biodiversity_classes= self.__getBiodiversityClassess()
            biodiversity_array="'{"+",".join(biodiversity_classes)+"}'"
            error = True
            count = 0
            while error and count < 3:
                self.__Indicator = Indicator(self.__user)
                db = self.__Indicator.get_up_calculator_connection()
                try:
                    query = """
                        select urbper_indicator_biodiversity_land_consumption({scenario},'biodiversity_consumption',{biodiversity})
                        """.format(
                            scenario=self.__scenario, 
                            biodiversity=biodiversity_array,
                        )
                    LogEvents(
                        "biodiversity land consumption",
                        "biodiversity land consumption module started: " + query,
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
                        "biodiversity land consumption",
                        "biodiversity land consumption module failed " +
                        str(count) + ": " + str(e),
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    db.close()
                    LogEvents(
                        "biodiversity land consumption",
                        "biodiversity land consumption module finished",
                        self.__scenario,
                        self.__user
                    )
        except Exception as e:
            LogEvents(
                "biodiversity land consumption",
                "unknown error " +
                str(e),
                self.__scenario,
                self.__user
            )
    def __getBiodiversityClassess(self):
        try:
            error = True
            count = 0
            while error and count < 3:
                try:
                    query="""select distinct classification.name 
                        from classification
                        where classification.category='footprint'
                        and classification.fclass='biodiversity'
                        """
                    results = classification.objects.filter(category='footprint',fclass='biodiversity').distinct().values_list('name',flat=True)

                    LogEvents(
                        "biodiversity",
                        "biodiversity classes finished: " + query,
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
                        "biodiversity",
                        "biodiversity classes failed " +
                        str(count) + ": " + str(e),
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    LogEvents(
                        "biodiversity",
                        "biodiversity classes finished",
                        self.__scenario,
                        self.__user
                    )
                    return results
        except Exception as e:
            LogEvents(
                "biodiversity",
                "unknown error " + str(e),
                self.__scenario,
                self.__user
            )