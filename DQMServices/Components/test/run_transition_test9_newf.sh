#!/bin/bash

function die { echo Failure $1: status $2 ; exit $2 ; }

export LOCAL_TEST_DIR=$CMSSW_BASE/src/DQMServices/Components/python/test/
echo ${LOCAL_TEST_DIR}

for bookIn in CTOR BJ BR

do
  #OLD file1
  testConfig=create_file1_cfg.py
  rm -f dqm_file1.root
  echo ${testConfig} ------------------------------------------------------------
  cmsRun ${LOCAL_TEST_DIR}/${testConfig} $bookIn || die "cmsRun ${testConfig}" $?

  #OLD file2
  testConfig=create_file2_cfg.py
  rm -f dqm_file2.root
  echo ${testConfig} ------------------------------------------------------------
  cmsRun ${LOCAL_TEST_DIR}/${testConfig} $bookIn || die "cmsRun ${testConfig}" $?

  #OLD file3
  testConfig=create_file3_cfg.py
  rm -f dqm_file3.root
  echo ${testConfig} ------------------------------------------------------------
  cmsRun ${LOCAL_TEST_DIR}/${testConfig} $bookIn || die "cmsRun ${testConfig}" $?

  #MERGE file1file2file3
  testConfig=merge_file1_file2_file3_cfg.py
  rm -f dqm_merged_file1_file2_file3.root
  echo ${testConfig} ------------------------------------------------------------
  cmsRun ${LOCAL_TEST_DIR}/${testConfig} || die "cmsRun ${testConfig}" $?

  #check merged
  testConfig=check_merged_file1_file2_file3_cfg.py
  echo ${testConfig} ------------------------------------------------------------
  python ${LOCAL_TEST_DIR}/${testConfig} || die "cmsRun ${testConfig}" $?

  #HARVEST MERGED FILE
  testConfig=harv_merged_file1_file2_file3_cfg.py
  rm -f DQM_V0001_R00000000?__Test__Merged_File1_File2_File3__DQM.root
  echo ${testConfig} ------------------------------------------------------------
  cmsRun ${LOCAL_TEST_DIR}/${testConfig} Collate || die "cmsRun ${testConfig}" $?

  #HARVEST SINGLE FILES 
  testConfig=harv_file1_file2_file3_cfg.py
  rm -f DQM_V0001_R00000000?__Test__File1_File2_File3__DQM.root
  echo ${testConfig} ------------------------------------------------------------
  cmsRun ${LOCAL_TEST_DIR}/${testConfig} Collate || die "cmsRun ${testConfig}" $?

  #CHECK HARVESTED FILE
  echo COMPARING: single vs merged ------------------------------------------------------------
  compare_using_files.py DQM_V0001_R000999999__Test__{,Merged_}File1_File2_File3__DQM.root -C -s b2b -t 0.999999 


done

exit 0
