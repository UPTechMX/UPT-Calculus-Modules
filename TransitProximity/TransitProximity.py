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
            error = True
            count = 0
            while error and count < 3:
                self.__Indicator = Indicator(self.__user)
                db = self.__Indicator.get_up_calculator_connection()
                try:
                    query = """
                        select urbper_indicator_pop_transit_prox({scenario},'pop_prox_{fclass}'::varchar(30),'{fclass}_proximity'::varchar(30))
                        """.format(scenario=self.__scenario, fclass='transit')
                    LogEvents(
                        "transit proximity",
                        "transit proximity module started: " + query,
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
                        "transit proximity",
                        "transit proximity module failed " +
                        str(count) + ": " + str(e),
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    db.close()
                    LogEvents(
                        "transit proximity",
                        "transit proximity module finished",
                        self.__scenario,
                        self.__user
                    )
        except Exception as e:
            LogEvents(
                "transit proximity",
                "unknown error " +
                str(e),
                self.__scenario,
                self.__user
            )