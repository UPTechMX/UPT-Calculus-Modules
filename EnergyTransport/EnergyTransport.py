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
        
        self.__limits = {"inferior": 0, "superior": 0}
        self.__mmu_limit_offset()  
        self.__energy_transport_threads()
        
        self.__energy_transport()

    def __mmu_limit_offset(self):
        try:
            self.__Indicator = Indicator(self.__user)
            db = self.__Indicator.get_up_calculator_connection()
            try:
                # get the max an min of pk
                self.__limits["inferior"] = mmu.objects.filter(
                    scenario_id=self.__scenario).aggregate(Min('mmu_id'))["mmu_id__min"]
                self.__limits["superior"] = mmu.objects.filter(
                    scenario_id=self.__scenario).aggregate(Max('mmu_id'))["mmu_id__max"]
            except Exception as e:
                LogEvents("squares max min", "unknown error " +
                          str(e), self.__scenario, self.__user, True)
            db.close()
        except Exception as e:
            LogEvents("squares max min", "unknown error " +
                      str(e), self.__scenario, self.__user, True)

    def __energy_transport_threads(self):
        self.__scenario_t = {}
        self.__scenario_t["limit"] = 0
        self.__scenario_t["offset"] = 0

        inferior = self.__limits["inferior"]
        superior = self.__limits["superior"]
        _threads = {}

        self.max_threads = min(self.__Indicator.get_max_threads(), int(math.ceil(
            (superior - inferior) / self.__Indicator.get_max_rows())))
        num_partitions = self.max_threads
        partition_size = (int)(
            math.ceil((superior - inferior) / self.max_threads))  

        for h in range(0, num_partitions):
            self.__scenario_t["offset"] = inferior
            self.__scenario_t["limit"] = self.__scenario_t["offset"] + \
                partition_size
            inferior = self.__scenario_t["limit"] + 1
            _threads[h] = threading.Thread(target=self.__ModuleEnergyTransport, args=(
                self.__scenario, self.__scenario_t["offset"], self.__scenario_t["limit"]))

        for process in _threads:
            _threads[process].start()

        for process in _threads:
            if _threads[process].is_alive():
                _threads[process].join()

    def __ModuleEnergyTransport(self, scenario_id, offset=0, limit=0):
        try:
            error = True
            count = 0

            while error and count < 3:
                self.__Indicator = Indicator(self.__user)
                db = self.__Indicator.get_up_calculator_connection()
                try:
                    with transaction.atomic():
                        query = """select urbper_indicator_energy_transport({scenario},{offset},{limit})""".format(
                            scenario=scenario_id, offset=offset, limit=limit)
                        LogEvents("energy transport", "energy transport  module started: " + query,
                                  scenario_id, self.__user)
                        db.execute(query)
                except Exception as e:
                    
                    error = True
                    count += 1
                    LogEvents("energy transport ", "energy transport  module failed " +
                              str(count) + ": " + str(e), scenario_id, self.__user, True)
                    db.close()
                else:
                    error = False
                    LogEvents("energy transport ", "energy transport  module finished",
                              scenario_id, self.__user)
                    db.close()
        except Exception as e:
            LogEvents("Running scenarios", "Unknown error " +
                      str(e), scenario_id, self.__user, True)
    
    def __energy_transport(self):
        try:
            error = True
            count = 0
            while error and count < 3:
                self.__Indicator = Indicator(self.__user)
                db = self.__Indicator.get_up_calculator_connection()
                try:
                    query = """
                        select urbper_indicator_energy_transport_t({scenario})
                            """.format(scenario=self.__scenario)
                    LogEvents(
                        "energy transport",
                        "energy transport module started: " + query,
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
                        "energy transport",
                        "energy transport module failed " +
                        str(count) + ": " + str(e) ,
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    db.close()
                    LogEvents(
                        "energy transport",
                        "energy transport module finished",
                        self.__scenario,
                        self.__user
                    )
        except Exception as e:
            LogEvents(
                "energy transport",
                "unknown error " +
                str(e),
                self.__scenario,
                self.__user
            )

