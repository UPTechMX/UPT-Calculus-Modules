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
        self.__EvaluateJobsBuffer()
    
    def __EvaluateJobsBuffer(self):
        
        self.__limits = {"inferior": 0, "superior": 0}
        self.__jobs_limit_offset()  
        self.__jobs_preprocessing_threads()

    def __jobs_limit_offset(self):
        try:
            
            
            try:
                # get the max an min of pk
                self.__limits["inferior"] = jobs.objects.filter(
                    scenario_id=self.__scenario).aggregate(Min('jobs_id'))["jobs_id__min"]
                self.__limits["superior"] = jobs.objects.filter(
                    scenario_id=self.__scenario).aggregate(Max('jobs_id'))["jobs_id__max"]
            except Exception as e:
                LogEvents("jobs max min", "unknown error " +
                          str(e), self.__scenario, self.__user, True)
            
        except Exception as e:
            LogEvents("jobs max min", "unknown error " +
                      str(e), self.__scenario, self.__user, True)

    def __jobs_preprocessing_threads(self):
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
            _threads[h] = threading.Thread(target=self.__ModuleJobsDensity, args=(
                self.__scenario, self.__scenario_t["offset"], self.__scenario_t["limit"]))

        for process in _threads:
            _threads[process].start()

        for process in _threads:
            if _threads[process].is_alive():
                _threads[process].join()
    
    
    def __ModuleJobsDensity(self, scenario_id, offset=0, limit=0):
        import psycopg2
        import psycopg2.extras
        try:
            error = True
            count = 0

            while error and count < 3:
                
                
                try:
                    query = """select urbper_buffer_job_and_job_density({scenario},{offset},{limit})""".format(
                        scenario=scenario_id, offset=offset, limit=limit)
                    LogEvents("job buffers and density", "job buffers and density  module started: " + query,
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
                    LogEvents("job buffers and density ", "job buffers and density  module failed " +
                              str(count) + ": " + str(e), scenario_id, self.__user, True)
                    
                else:
                    error = False
                    # db.commit()
                    LogEvents("job buffers and density ", "job buffers and density  module finished",
                              scenario_id, self.__user)
                    
        except Exception as e:
            LogEvents("Running scenarios", "Unknown error " +
                      str(e), scenario_id, self.__user, True)
