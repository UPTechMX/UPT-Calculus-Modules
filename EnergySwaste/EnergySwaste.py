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
from plup.models import Amenities

class Module:
    def __init__(self, user, scenario, extra_dict_arguments=None):
        self.__user = user
        self.__scenario = scenario

    def run(self):
        try:
            error = True
            count = 0
            while error and count < 3:
                self.__Indicator = Indicator(self.__user)
                db = self.__Indicator.get_up_calculator_connection()
                try:
                    query = """
                        select urbper_indicator_energy_solid_waste({scenario})
                            """.format(scenario=self.__scenario)
                    LogEvents(
                        "energy swaste",
                        "energy swaste module started: " + query,
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
                        "energy swaste",
                        "energy swaste module failed " +
                        str(count) + ": " + str(e) ,
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    db.close()
                    LogEvents(
                        "energy swaste",
                        "energy swaste module finished",
                        self.__scenario,
                        self.__user
                    )
        except Exception as e:
            LogEvents(
                "energy swaste",
                "unknown error " +
                str(e),
                self.__scenario,
                self.__user
            )

