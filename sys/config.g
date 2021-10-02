; Configuration file for Duet 3 Mini 5+ (firmware version 3.3)
; executed by the firmware on start-up
;
; generated by RepRapFirmware Configuration Tool v3.3.2 on Mon Sep 13 2021 16:36:36 GMT+0200 (centraleuropeisk sommartid)
; Based on configuration by OC-Geek

; General preferences
M111 S0                	; Debugging off
G21                    	; Work in millimetres
G90                     ; send absolute coordinates...
M83                     ; ...but relative extruder moves

M669 K1                 ; select CoreXY mode

; Limit axis				
M564 S1 H1             	; Forbid axis movements when not homed
; H1	Forbid movement of axes that have not been homed
; S1	Limit movement within axis boundaries

; Wait a moment for the CAN expansion boards to start
G4 S2

; ================================== 
; Fysetc 12864 display Color
; ==================================

M918 P2 R6 C30 E4 F200000  	; Configure direct-connect display
; P2  	128x64 display using ST7567 display driver chip
; R6  	Display resistor ratio, in range 1 to 7. Only used with ST7567-based displays. 
;		The default value of 6 is suitable for the Fysetc Mini 12864 display. 
; C30	Display contrast, in range 0 to 100
; E4	The number of pulses generated by the rotary encoder per detent. Typical values are 2 and 4
; F...	SPI clock frequency in Hz, default 2000000 (i.e. 2MHz)

M150 X2 R0 U255 B0 P200 S3   ; Set LED colours
; X2 		LED type: X0 (default) = DotStar, X1 = NeoPixel, X2 = Panel 12864
; R,U,B		Set the LED colour (note Fystec uses GRB space instead ... (Red and Green switched over)
; S3 		Number of individual LEDs to set to these colours

; ================================== 
; NETWORK
; ==================================

; Need to set up WIFI
; M587 S"SSID" P"PWD" 
; This needs to be as a first step via USB like when fw ver is checked 
; It is permanently stored in the card after that
; https://duet3d.dozuki.com/Guide/1.)+Getting+Connected+to+your+Duet

; Network
M550 P"voron2"          ; set printer name
M552 S1                                          ; enable network
M586 P0 S1                                       ; enable HTTP (for DWC)
M586 P1 S1                                       ; enable FTP (for remote backups)
M586 P2 S0                                       ; disable Telnet

; ================================== 
; DRIVERS
; ==================================

; --- Z Drive map ---
;    B_______A
;    | 1 | 2 |
;    | ----- |
;    | 0 | 3 |
;     -------
;      front
;
; (looking at the printer from the top)

; Driver directions
; M569: Set motor driver direction, enable polarity and step pulse timing
; This command has LOT of parameters ... e.g. stealthChop2 ...
; Pnnn 		Motor driver number
; Snnn		Direction of movement 0 = backwards, 1 = forwards (default 1)

M569 P121.0 S1 D2                                ; E - physical drive 121.0 goes forwards

M569 P0.0 S1                                     ; A -> Y - physical drive 0.0 goes forwards
M569 P0.1 S1                                     ; B -> X - physical drive 0.1 goes forwards

M569 P0.3 S1                                     ; Z0 - physical drive 0.3 goes forwards
M569 P0.4 S0                                     ; Z1 - physical drive 0.4 goes backwards
M569 P0.5 S1                                     ; Z2 - physical drive 0.5 goes forwards
M569 P0.6 S0                                     ; Z3 - physical drive 0.6 goes backwards


M584 X0.0 Y0.1 Z0.3:0.4:0.5:0.6 E121.0           ; set drive mapping
M350 X16 Y16 Z16 E16 I1                          ; configure microstepping with interpolation
M92 X160.00 Y160.00 Z400.00 E400.00              ; set steps per mm
M566 X900.00 Y900.00 Z60.00 E120.00              ; set maximum instantaneous speed changes (mm/min)
M203 X6000.00 Y6000.00 Z180.00 E1200.00          ; set maximum speeds (mm/min)
M201 X500.00 Y500.00 Z20.00 E250.00              ; set accelerations (mm/s^2)

; Stepper driver currents
; set motor currents (mA) and motor idle factor in per cent
M906 X800 Y800 I30
M906 Z800 I90
M906 E500 I50                     

M84 S120                                         ; Set idle timeout

; ==================================
; Endstops						
; ==================================

; Xn,Yn endstop: 0 = none, 1 = low end, 2 = high end
; Snnn 	1 = switch-type (eg microswitch) endstop input 
;		2 = Z probe (when used to home an axis other than Z)
;		3 = single motor load detection
;		4 = multiple motor load detection (see Notes)
; P"pin_name"

; Endstops
M574 X2 S1 P"^121.io0.in"                       ; configure active-high endstop for high end on X via pin ^121.io0.in
M574 Y2 S1 P"^0.io1.in"                         ; configure active-high endstop for high end on Y via pin ^io1.in
M574 Z0 p"nil"                                  ; No Z endstop
                                                ; Extruder never stops :-)

; Axis travel limits                            ; Mind this is travel NOT print area
M208 X0:300 Y0:305 Z-5:265                       ; Set axis minima - negative X is to have 0,0 on bed corner
                                                ; WARNING on Z not to hit the roof - this is set here

; Belt Locations
M671 X-65:-65:365:365 Y0:395:395:0 S20      ; Define Z belts locations (Front_Left, Back_Left, Back_Right, Front_Right)
											; Position of the bed leadscrews.. 4 Coordinates
											; Snn Maximum correction to apply to each leadscrew in mm (optional, default 1.0)
											; S20 - 20 mm spacing
M557 X30:270 Y30:270 S40					; Define bed mesh grid (inductive probe, positions include the Y offset!)

; Accelerations and speed are set in a file
M98 P"/macros/speed_printing.g"

; ==================================
; Bed heater
; ==================================
M308 S0 P"temp0" Y"thermistor" T100000 B3950     ; configure sensor 0 as thermistor on pin temp0
M950 H0 C"out0" Q10 T0                               ; create bed heater output on out0 and map it to sensor 0
M307 H0 B0 R0.607 C340.7 D1.16 S1.00 V24.1
;M307 H0 B1 S1.00                                 ; Enable bang-bang mode for the bed heater and set PWM limit
M140 H0                                          ; map heated bed to heater 0
M143 H0 S120                                     ; set temperature limit for heater 0 to 120C

; ==================================
; Hotend heater 
; ==================================
M308 S1 P"121.temp0" Y"thermistor" T100000 B3950 ; configure sensor 1 as thermistor on pin 121.temp0
M950 H1 C"121.out0" T1                           ; create nozzle heater output on 121.out0 and map it to sensor 1
M307 H1 B0 R3.391 C160.1:134.1 D4.20 S1.00 V23.8
;M307 H1 B0 S1.00                                 ; disable bang-bang mode for heater  and set PWM limit
M143 H1 S280                                     ; set temperature limit for heater 1 to 280C

; ==================================
; SENSORS MISC 
; ==================================

; Define MCU sensors which will be available in DWC Extra View
M308 S3 A"MCU" Y"mcu-temp" 				; Officially NOT supported on Mini 3 5+ however seem to work
M308 S4 A"Duet Drivers" Y"drivers" 		; This is not really working as it is just a threshold crossing

; ==================================
; CHAMBER SENSOR 
; ==================================
M308 S10 A"Chamber" P"0.temp2" Y"thermistor" T100000 B3950

; ==================================
; Z PROBES K0 (Klicky mag probe) and K1 (Microswitch Z0)
; ==================================

; M558: Set Z probe type
	; P5/P8 	select a switch by default (normally closed) for bed probing between the In and Gnd pins of the Z-probe connector
	; C			specifies the input pin and the optional modulation pin. This parameter is mandatory
	; Tnnn 		Travel speed to and between probe points (mm/min)
	; Fnnn 		Feed rate (i.e. probing speed, mm/min) e.g. 60 is one mm per second
	; Hnnn 		Dive height (mm)
	; Annn 		Maximum number of times to probe each point, default 1
	; Snnn 		Tolerance when probing multiple times, default 0.03mm
	; Rnnn 		Z probe recovery time before the probing move is started , default zero (seconds)
	; B0		B1 Turn off all heaters while probing, default (B0) leaves heaters on.
	; I0		Invert (I1) or do not invert (I0, default) the Z probe reading

; G31: Set Current Probe status
	; K0		Z Probe Number
	; Pnnn 		Trigger value
	; Xnn Ynn 	Probe offset (from Noozle)
	; Znnn 		Trigger Z height - Set the said Z when the probe triggers !!

; MAG PROBE (GND, IO)
; -----------
; This is the mag probe with microswitch in Afterburner
M558 K0 P8 C"^121.io2.in" T18000 F180 H10 A10 S0.0025
G31 K0 P500 X0 Y20 Z7.612

; Z-SWITCH
; -----------
; This is the microswitch which is pressed by the Noozle
M558 K1 P8 C"^io5.in" T18000 F180 H3 A10 S0.0025 R0
; Omron micro switch
G31 K1 P500 X0 Y0 Z1.20

; Part cooling fan
M950 F0 C"121.out1"                              ; create fan 0 on pin 121.out1 and set its frequency
M106 P0 S0 H-1                                   ; set fan 0 value. Thermostatic control is turned off

; Hotend fan
M950 F1 C"121.out2"                              ; create fan 1 on pin 121.out2 and set its frequency
M106 P1 S1 H1 T45                                ; set fan 1 value. Thermostatic control is turned on

; Controller fan 1
M950 F2 C"out6"                                  ; create fan 2 on pin out5 and set its frequency
M106 P2 S1.0 H3:4 T30 C"Controller fan 1"             ; controlled by Sensor 3 - MCU

; Controller fan 2
M950 F3 C"out5"                                  ; create fan 3 on pin out6 and set its frequency
M106 P3 S1 H0 T45                                ; set fan 3 value. Thermostatic control is turned on

; Tools
M563 P0 D0 H1                                    ; define tool 0
G10 P0 X0 Y0 Z0                                  ; set tool 0 axis offsets
G10 P0 R0 S0                                     ; set initial tool 0 active and standby temperatures to 0C

; Custom settings are not defined

; defines global variables
M98 P"/macros/define_global_vars.g"

; Load override parameters
M501
