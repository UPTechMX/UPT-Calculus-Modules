# -*- coding: utf-8 -*-
import threading
import time
from random import randint
import math
from plup.indicators.Indicator import Indicator
from plup.Helpers.LogEvents import LogEvents
from django.db import transaction,connection
from plup.models import jobs
from django.db.models import Max, Min


class Module:
    def __init__(self, user, scenario, extra_dict_arguments=None):
        self.__user = user
        self.__scenario = scenario
        self.__base_scenario = extra_dict_arguments["base_scenario"]

    def run(self):
        
        query = """
            delete from mmu_info where mmu_id in (
                select mmu_id 
                from mmu 
                where scenario_id={scenario} and not st_contains(
                    (
                        select location 
                        from footprint 
                        inner join classification on classification.name=footprint.name
                        where 
                            classification.category='footprint'
                            and classification.fclass in ('political_boundary','study_area')
                            and scenario_id={scenario} 
                    ),mmu.location
                )
            );
            delete from mmu 
            where scenario_id={scenario} and not st_contains(
                (
                    select location 
                    from footprint 
                    inner join classification on classification.name=footprint.name
                    where 
                        classification.category='footprint'
                        and classification.fclass in ('political_boundary','study_area')
                        and scenario_id={scenario} 
                ),mmu.location
            );
            """.format(scenario=self.__scenario)
        self.__Indicator = Indicator(self.__user)
        db = self.__Indicator.get_up_calculator_connection()
        db.execute(query)
        db.close()
        self.__evaluateRoadsBuffers()
    
    def __evaluateRoadsBuffers(self):
        import psycopg2
        import psycopg2.extras
        try:
            error = True
            count = 0
            while error and count < 3:
                
                
                try:
                    query = """
                        select urbper_buffer_roads({scenario})
                            """.format(scenario=self.__scenario)
                    LogEvents(
                        "roads buffers",
                        "roads buffer module started: " + query,
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
                    error = True
                    count += 1
                    time.sleep(randint(1, 3))
                    
                    LogEvents(
                        "roads buffers",
                        "roads buffers module failed " +
                        str(count) + ": " + str(e),
                        self.__scenario,
                        self.__user
                    )
                else:
                    error = False
                    
                    LogEvents(
                        "roads buffers",
                        "roads buffers module finished",
                        self.__scenario,
                        self.__user
                    )
        except Exception as e:
            LogEvents(
                "roads buffers",
                "unknown error " +
                str(e),
                self.__scenario,
                self.__user
            )
    
    