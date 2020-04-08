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

class Module:
    def __init__(self, user, scenario, extra_dict_arguments=None):
        self.__user = user
        self.__scenario = scenario

    def run(self):
        try:
            self.__Indicator = Indicator(self.__user)
            heritage_area_classes_set=assumptions.objects.filter(category='heritage').values("name")
            heritage_area_classes=[]
            for heritage_area in list(heritage_area_classes_set):
                heritage_area_classes.append(heritage_area["name"])
            
            heritage_area_array="'{"+",".join(heritage_area_classes)+"}'"

            error = True
            count = 0
            while error and count < 3:
                self.__Indicator = Indicator(self.__user)
                db = self.__Indicator.get_up_calculator_connection()
                try:
                    query = """
                        select urbper_indicator_solid_waste_management_coverage({scenario},'solidw_coverage')
                        """.format(
                            scenario=self.__scenario, 
                            heritage_area=heritage_area_array,
                        )
                    LogEvents(
                        "solid waste management coverage",
                        "solid waste management coverage module started: " + query,
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
                        "solid waste management coverage",
                        "solid waste management coverage module failed " +
                        str(count) + ": " + str(e),
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    db.close()
                    LogEvents(
                        "solid waste management coverage",
                        "solid waste management coverage module finished",
                        self.__scenario,
                        self.__user
                    )
        except Exception as e:
            LogEvents(
                "solid waste management coverage",
                "unknown error " +
                str(e),
                self.__scenario,
                self.__user
            )