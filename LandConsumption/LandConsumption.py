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
from plup.models import mmu
from django.db.models import Max, Min


class Module:
    def __init__(self, user, scenario, extra_dict_arguments=None):
        self.__user = user
        self.__scenario = scenario
        self.__base_scenario = extra_dict_arguments["base_scenario"]

    def run(self):
        self.__Indicator = Indicator(self.__user)
        vacuum(self.__Indicator.get_uri(), "mmu")
        self.__urbper_base_total_population()

    def __urbper_base_total_population(self):
        try:
            error = True
            count = 0
            while error and count < 3:
                self.__Indicator = Indicator(self.__user)
                db = self.__Indicator.get_up_calculator_connection()
                try:
                    with transaction.atomic():
                        self.__Indicator = Indicator(self.__user)
                        db = self.__Indicator.get_up_calculator_connection()
                        query = """select urbper_indicator_land_consumption({scenario})""".format(
                            scenario=self.__scenario)
                        LogEvents("land consumption", "land consumption module started: " + query,
                                  self.__scenario, self.__user)
                        db.execute(query)
                except Exception as e:
                    db.close()
                    error = True
                    count += 1
                    time.sleep(randint(1, 3))
                    LogEvents("land consumption", "land consumption module failed " +
                              str(count) + ": " + str(e), self.__scenario, self.__user, True)
                else:
                    error = False
                    
                    db.close()
                    LogEvents("land consumption", "land consumption module finished",
                              self.__scenario, self.__user)
        except Exception as e:
            LogEvents("land consumption", "unknown error " +
                      str(e), self.__scenario, self.__user, True)

    

