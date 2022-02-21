@echo off
REM ****************************************************************************
REM Vivado (TM) v2019.1.3 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Fri Feb 18 13:44:34 -0500 2022
REM SW Build 2644227 on Wed Sep  4 09:45:24 MDT 2019
REM
REM Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
echo "xsim i2c_adc_user_tb_behav -key {Behavioral:sim_1:Functional:i2c_adc_user_tb} -tclbatch i2c_adc_user_tb.tcl -view C:/Users/jones/Desktop/EE316-Lab3/Lab3/Lab3.sim/sim_1/system_controller_tb_behav.wcfg -view C:/Users/jones/Desktop/EE316-Lab3/Lab3/Lab3.sim/i2c_adc_user_behav.wcfg -log simulate.log"
call xsim  i2c_adc_user_tb_behav -key {Behavioral:sim_1:Functional:i2c_adc_user_tb} -tclbatch i2c_adc_user_tb.tcl -view C:/Users/jones/Desktop/EE316-Lab3/Lab3/Lab3.sim/sim_1/system_controller_tb_behav.wcfg -view C:/Users/jones/Desktop/EE316-Lab3/Lab3/Lab3.sim/i2c_adc_user_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0