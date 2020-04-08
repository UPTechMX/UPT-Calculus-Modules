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
from django.db import connection

class Module:
    def __init__(self, user, scenario, extra_dict_arguments=None):
        self.__user = user
        self.__scenario = scenario

    def run(self):
        try:
            self.__Indicator = Indicator(self.__user)
            self.__db = self.__Indicator.get_up_calculator_connection()
            vacuum(self.__Indicator.get_uri(), "mmu")
            self.__db.close()
            amenity_classes_set = self.__getAmentityClassess()
            error = True
            count = 0
            while error and count < 3:
                self.__Indicator = Indicator(self.__user)
                db = self.__Indicator.get_up_calculator_connection()
                try:
                    for amenity in amenity_classes_set:
                        amenity_classes = []
                        amenity_classes.append(amenity)
                        amenity_classes_array="'{"+",".join(amenity_classes)+"}'"
                        query = """
                            select urbper_indicator_pop_amenity_prox({scenario},'pop_prox_{fclass}'::varchar(30),'{fclass}_proximity'::varchar(30),{fclass_array})
                                """.format(scenario=self.__scenario, fclass=amenity, fclass_array=amenity_classes_array)
                        LogEvents(
                            amenity+" proximity",
                            amenity+" proximity module started: " + query,
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
                        "amenity proximity",
                        "amenity proximity module failed " +
                        str(count) + ": " + str(e) ,
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    db.close()
                    LogEvents(
                        "amenity proximity",
                        "amenity proximity module finished",
                        self.__scenario,
                        self.__user
                    )
        except Exception as e:
            LogEvents(
                "amenity proximity",
                "unknown error " +
                str(e),
                self.__scenario,
                self.__user
            )

            

    def __getAmentityClassess(self):
        try:
            error = True
            count = 0
            while error and count < 3:
                try:
                    with connection.cursor() as cursor:
                        query="""select distinct assumptions.name from amenities
                            inner join classification on classification."name" = amenities.fclass
                            inner join assumptions on assumptions.name = classification.fclass
                            where classification.category='amenities'
                            and amenities.scenario_id=assumptions.scenario_id
                            and assumptions.scenario_id={}""".format(self.__scenario)                        
                        LogEvents(
                            "amenity proximity",
                            "amenity proximity classes started: " + query,
                            self.__scenario,
                            self.__user
                        )
                        cursor.execute(query)

                        results_set=[list(row)[0] for row in cursor.fetchall()]
                        print(results_set)
                        
                    results=results_set
                except Exception as e:
                    error = True
                    count += 1
                    time.sleep(randint(1, 3))
                    LogEvents(
                        "amenity proximity",
                        "amenity proximity classes failed " +
                        str(count) + ": " + str(e),
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    LogEvents(
                        "amenity proximity",
                        "amenity proximity classes finished",
                        self.__scenario,
                        self.__user
                    )
                    return results
        except Exception as e:
            LogEvents(
                "amenity proximity",
                "unknown error " + str(e),
                self.__scenario,
                self.__user
            )
