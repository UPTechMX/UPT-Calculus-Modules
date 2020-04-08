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
import psycopg2
import psycopg2.extras


class Module:
    def __init__(self, user, scenario, extra_dict_arguments=None):
        self.__user = user
        self.__scenario = scenario
        self.__base_scenario = extra_dict_arguments["base_scenario"]
        

    def run(self):
        self.__general_calculus()
        self.__limits = {"inferior": 0, "superior": 0}
        self.__mmu_limit_offset() 
        self.__pop_density_threads()
        self.__area_density_threads()

    def __general_calculus(self):
        self.__Indicator = Indicator(self.__user)
        vacuum(self.__Indicator.get_uri(), "mmu")
        self.__urbper_base_footprint_area()
        self.__urbper_base_total_population()
        self.__urbper_base_footprint_km2()

    def __urbper_base_footprint_area(self):
        try:
            error = True
            count = 0
            while error and count < 3:
                try:
                    self.__Indicator = Indicator(self.__user)
                    
                    query = """select urbper_indicator_footprints_area({scenario})""".format(
                            scenario=self.__scenario)
                    LogEvents(
                        "footprints area",
                        "footprints area module started: " + query,
                        self.__scenario,
                        self.__user
                    )
                    conn = psycopg2.connect(self.__Indicator.get_uri())
                    cursor = conn.cursor(
                    cursor_factory=psycopg2.extras.DictCursor)
                    old_isolation_level = conn.isolation_level
                    conn.set_isolation_level(0)
                    cursor.execute(query)
                    conn.commit()
                    conn.set_isolation_level(old_isolation_level)
                except Exception as e:
                    
                    conn.rollback()
                    conn.close()
                    error = True
                    count += 1
                    time.sleep(randint(1, 3))
                    LogEvents("footprints area", "footprints area module failed " +
                              str(count) + ": " + str(e), self.__scenario, self.__user, True)
                else:
                    error = False
                    
                    conn.close()
                    LogEvents("footprints area", "footprints area module finished",
                              self.__scenario, self.__user)
        except Exception as e:
            LogEvents("footprints area", "unknown error+ " +
                      str(e), self.__scenario, self.__user, True)

    def __urbper_base_footprint_km2(self):
        try:
            error = True
            count = 0
            while error and count < 3:
                try:
                    self.__Indicator = Indicator(self.__user)
                    query = """select urbper_indicator_footprint_km2({scenario})""".format(
                            scenario=self.__scenario)
                    LogEvents(
                        "footprints area",
                        "footprints area module started: " + query,
                        self.__scenario,
                        self.__user
                    )
                    conn = psycopg2.connect(self.__Indicator.get_uri())
                    cursor = conn.cursor(
                    cursor_factory=psycopg2.extras.DictCursor)
                    old_isolation_level = conn.isolation_level
                    conn.set_isolation_level(0)
                    cursor.execute(query)
                    conn.commit()
                    conn.set_isolation_level(old_isolation_level)
                except Exception as e:
                    
                    conn.rollback()
                    conn.close()
                    error = True
                    count += 1
                    time.sleep(randint(1, 3))
                    LogEvents("footprint_km2", "footprint_km2 module failed " +
                              str(count) + ": " + str(e), self.__scenario, self.__user, True)
                else:
                    error = False
                    
                    conn.close()
                    LogEvents("footprint_km2", "footprint_km2 module finished",
                              self.__scenario, self.__user)
        except Exception as e:
            LogEvents("footprint_km2", "unknown error+ " +
                      str(e), self.__scenario, self.__user, True)

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
                        query = """select urbper_indicator_base_calculus_total_population({scenario},{base_scenario})""".format(
                            scenario=self.__scenario, base_scenario=self.__base_scenario)
                        LogEvents("total population", "total population module started: " + query,
                                  self.__scenario, self.__user)
                        db.execute(query)
                except Exception as e:
                    db.close()
                    error = True
                    count += 1
                    time.sleep(randint(1, 3))
                    LogEvents("total population", "total population module failed " +
                              str(count) + ": " + str(e), self.__scenario, self.__user, True)
                else:
                    error = False
                    
                    db.close()
                    LogEvents("total population", "total population module finished",
                              self.__scenario, self.__user)
        except Exception as e:
            LogEvents("total population", "unknown error " +
                      str(e), self.__scenario, self.__user, True)

    def __mmu_limit_offset(self):
        try:
            self.__Indicator = Indicator(self.__user)
            db = self.__Indicator.get_up_calculator_connection()
            try:
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

    def __pop_density_threads(self):
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
            _threads[h] = threading.Thread(target=self.__ModulePopulationDensity, args=(
                self.__scenario, self.__scenario_t["offset"], self.__scenario_t["limit"]))

        for process in _threads:
            _threads[process].start()

        for process in _threads:
            if _threads[process].is_alive():
                _threads[process].join()

    def __area_density_threads(self):
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
            _threads[h] = threading.Thread(target=self.__ModuleAreaDensity, args=(
                self.__scenario, self.__scenario_t["offset"], self.__scenario_t["limit"]))

        for process in _threads:
            _threads[process].start()

        for process in _threads:
            if _threads[process].is_alive():
                _threads[process].join()

    def __ModuleAreaDensity(self, scenario_id, offset=0, limit=0):
        try:
            error = True
            count = 0
            while error and count < 3:
                self.__Indicator = Indicator(self.__user)
                db = self.__Indicator.get_up_calculator_connection()
                try:
                    
                        query = """select urbper_indicator_area_den_avg({scenario},{offset},{limit})""".format(
                            scenario=scenario_id, offset=offset, limit=limit)
                        LogEvents("area density avg", "area density avg module started: " + query,
                                    scenario_id, self.__user)
                        
                        conn = psycopg2.connect(self.__Indicator.get_uri())
                        cursor = conn.cursor(
                        cursor_factory=psycopg2.extras.DictCursor)
                        old_isolation_level = conn.isolation_level
                        conn.set_isolation_level(0)
                        cursor.execute(query)
                        conn.commit()
                        conn.set_isolation_level(old_isolation_level)
                except Exception as e:
                    
                    error = True
                    count += 1
                    time.sleep(randint(1, 3))
                    LogEvents("area density avg", "area density avg module failed " +
                              str(count) + ": " + str(e), scenario_id, self.__user, True)
                    conn.close()
                else:
                    error = False
                    
                    LogEvents("area density avg", "area density avg module finished",
                              scenario_id, self.__user)
                    conn.close()
        except Exception as e:
            LogEvents("Running scenarios", "Unknown error " +
                      str(e), scenario_id, self.__user, True)

    def __ModulePopulationDensity(self, scenario_id, offset=0, limit=0):
        try:
            error = True
            count = 0

            while error and count < 3:
                self.__Indicator = Indicator(self.__user)
                db = self.__Indicator.get_up_calculator_connection()
                try:
                        query = """select urbper_indicator_pop_den_avg({scenario},{offset},{limit})""".format(
                            scenario=scenario_id, offset=offset, limit=limit)
                        LogEvents("population density avg", "population density avg module started: " + query,
                                  scenario_id, self.__user)
                        conn = psycopg2.connect(self.__Indicator.get_uri())
                        cursor = conn.cursor(
                        cursor_factory=psycopg2.extras.DictCursor)
                        old_isolation_level = conn.isolation_level
                        conn.set_isolation_level(0)
                        cursor.execute(query)
                        conn.commit()
                        conn.set_isolation_level(old_isolation_level)
                except Exception as e:
                    
                    error = True
                    count += 1
                    LogEvents("population density avg", "population density avg module failed " +
                              str(count) + ": " + str(e), scenario_id, self.__user, True)
                    conn.close()
                else:
                    error = False
                    
                    LogEvents("population density avg", "population density avg module finished",
                              scenario_id, self.__user)
                    conn.close()
        except Exception as e:
            LogEvents("Running scenarios", "Unknown error " +
                      str(e), scenario_id, self.__user, True)

