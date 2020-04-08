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
from django.db import transaction,connection
from plup.models import assumptions

class Module:
    def __init__(self, user, scenario, extra_dict_arguments=None):
        self.__user = user
        self.__scenario = scenario

    def run(self):
        try:
            self.__Indicator = Indicator(self.__user)
            amenity_classes=self.__getAmenitiesClassess()
            
            amenity_classes_array="'{"+",".join(amenity_classes)+"}'"

            risk_classes=self.__getRiskClassess()
            
            risk_classes_array="'{"+",".join(risk_classes)+"}'"
            error = True
            count = 0
            while error and count < 3:
                self.__Indicator = Indicator(self.__user)
                db = self.__Indicator.get_up_calculator_connection()
                try:
                    query = """
                        select urbper_indicator_health_infrastructure_in_risk({scenario},'health_risk',{amenity_class},{risk_classes})
                        """.format(
                            scenario=self.__scenario, 
                            amenity_class=amenity_classes_array,
                            risk_classes=risk_classes_array
                        )
                    LogEvents(
                        "health infrastructure in risk",
                        "health infrastructure in risk module started: " + query,
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
                        "health infrastructure in risk",
                        "health infrastructure in risk module failed " +
                        str(count) + ": " + str(e),
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    db.close()
                    LogEvents(
                        "health infrastructure in risk",
                        "health infrastructure in risk module finished",
                        self.__scenario,
                        self.__user
                    )
        except Exception as e:
            LogEvents(
                "health infrastructure in risk",
                "unknown error " +
                str(e),
                self.__scenario,
                self.__user
            )
    
    def __getRiskClassess(self):
        try:
            error = True
            count = 0
            while error and count < 3:
                try:
                    with connection.cursor() as cursor:
                        query="""select distinct risk.fclass from risk
                            inner join classification on classification.name=risk.fclass
                            where classification.category='risk'
                            and classification.fclass='risk'
                            and risk.scenario_id={}""".format(self.__scenario)                        
                        LogEvents(
                            "risk fclasses",
                            "risk fclasses started: " + query,
                            self.__scenario,
                            self.__user
                        )
                        cursor.execute(query)

                        results_set=[list(row)[0] for row in cursor.fetchall()]
                        
                    results=results_set
                except Exception as e:
                    error = True
                    count += 1
                    time.sleep(randint(1, 3))
                    LogEvents(
                        "risk fclasses",
                        "risk fclasses failed " +
                        str(count) + ": " + str(e),
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    LogEvents(
                        "risk fclasses",
                        "risk fclasses finished",
                        self.__scenario,
                        self.__user
                    )
                    return results
        except Exception as e:
            LogEvents(
                "risk fclasses",
                "unknown error " + str(e),
                self.__scenario,
                self.__user
            )

    def __getAmenitiesClassess(self):
        try:
            error = True
            count = 0
            while error and count < 3:
                try:
                    with connection.cursor() as cursor:
                        query="""
                            select distinct amenities.fclass from amenities
                            inner join classification on classification.name=amenities.fclass
                            where classification.category='amenities'
                            and classification.fclass='health_infrastructure'
                            and amenities.scenario_id={}""".format(self.__scenario)                        
                        LogEvents(
                            "amenities fclasses",
                            "amenities fclasses started: " + query,
                            self.__scenario,
                            self.__user
                        )
                        cursor.execute(query)

                        results_set=[list(row)[0] for row in cursor.fetchall()]
                        
                    results=results_set
                except Exception as e:
                    error = True
                    count += 1
                    time.sleep(randint(1, 3))
                    LogEvents(
                        "amenities fclasses",
                        "amenities fclasses failed " +
                        str(count) + ": " + str(e),
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    LogEvents(
                        "amenities fclasses",
                        "amenities fclasses finished",
                        self.__scenario,
                        self.__user
                    )
                    return results
        except Exception as e:
            LogEvents(
                "amenities fclasses",
                "unknown error " + str(e),
                self.__scenario,
                self.__user
            )
    
    