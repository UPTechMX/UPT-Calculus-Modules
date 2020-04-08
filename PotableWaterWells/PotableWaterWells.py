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
from plup.models import classification

class Module:
    def __init__(self, user, scenario, extra_dict_arguments=None):
        self.__user = user
        self.__scenario = scenario

    def run(self):
        try:
            error = True
            count = 0
            dwells_classes= self.__getAmenityClassess()            
            dwells_array="'{"+",".join(dwells_classes)+"}'"
            while error and count < 3:
                self.__Indicator = Indicator(self.__user)
                db = self.__Indicator.get_up_calculator_connection()
                try:
                    query = """
                        select urbper_indicator_potable_water_wells({scenario},{fclass_array})
                        """.format(
                            scenario=self.__scenario,fclass_array=dwells_array
                        )
                    LogEvents(
                        "potable water wells",
                        "potable water wells module started: " + query,
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
                        "potable water wells",
                        "potable water wells module failed " +
                        str(count) + ": " + str(e),
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    db.close()
                    LogEvents(
                        "potable water wells",
                        "potable water wells module finished",
                        self.__scenario,
                        self.__user
                    )
        except Exception as e:
            LogEvents(
                "potable water wells",
                "unknown error " +
                str(e),
                self.__scenario,
                self.__user
            )

    def __getAmenityClassess(self):
        try:
            error = True
            count = 0
            while error and count < 3:
                try:
                    query="""select distinct classification.name 
                        from classification
                        where classification.category='amenities'
                        and classification.fclass='dwells'
                        """
                    results = classification.objects.filter(category='amenities',fclass='dwells').distinct().values_list('name',flat=True)

                    LogEvents(
                        "dwells",
                        "dwells classes finished: " + query,
                        self.__scenario,
                        self.__user
                    )
                    # cursor.execute(query)

                    results_set=[row for row in results]
                        
                    results=results_set
                except Exception as e:
                    error = True
                    count += 1
                    time.sleep(randint(1, 3))
                    LogEvents(
                        "dwells",
                        "dwells classes failed " +
                        str(count) + ": " + str(e),
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    LogEvents(
                        "dwells",
                        "dwells classes finished",
                        self.__scenario,
                        self.__user
                    )
                    return results
        except Exception as e:
            LogEvents(
                "dwells",
                "unknown error " + str(e),
                self.__scenario,
                self.__user
            )