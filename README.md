# EE316-Lab3
## Aaron R. Jones, Connor Clappin, Gianna Citriniti 
This repository holds our project for EE316 (Computer Engineering Junior Lab) Lab 3 - Signal Generation using sensors with I<sup>2</sup>C interface.  The project was developed on Digilent's Cora Z7 FPGA using VHDL.

The system described in this project used an I<sup>2</sup>C four-channel ADC, with channels connected as follows:
1. ADC0 - Light Dependent Resistor
2. ADC1 - Thermistor
3. ADC2 - Analog Input
4. ADC3 - Potentiometer

The system also included an I<sup>2</sup>C LCD display, which was used to display the current state of the system.  The system is able to output a PWM signal and a Clock signal (frequency ranging from 500-1500 Hz) based on the ADC's input.  The Analog input of the ADC (ADC2) was connected to a sine wave (amplitude 3.3 V, run through a summer and an inverter to ensure that the ADC input ranged from 0 V - 3.3 V).  The PWM output signal was then passed through a second-order filter, which could re-create the input frequency.

Two separate I<sup>2</sup>C buses are used to ensure maximum sampling speed from the ADC.

As the input frequency of the analog signal increases, the accuracy of the re-created sine wave decreases, due to limitations with the I<sup>2</sup>C ADC sampling speed.
