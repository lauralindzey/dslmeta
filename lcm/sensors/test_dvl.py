#!/usr/bin/env python

import lcm
import time
import math
import datetime
import random

from sensors import *


lc = lcm.LCM("udpm://239.255.76.67:7667?ttl=0")

dvl        = dvl_t()

DVL_MEAN_NOISE = 0.0
DVL_STANDARD_DEVIATION_NOISE = 0.001 # m/s
DEPTH_MEAN_NOISE = 0.0
DEPTH_STANDARD_DEVIATION_NOISE = 0.001 # meters
ALTITUDE_MEAN_NOISE = 0.0
ALTITUDE_STANDARD_DEVIATION_NOISE = 0.001 # meters



while True:

    vx = 1.0;
    vy = 1.0;
    vz = 0.000001;
    altitude = 35.0;
    depth = 500.0;

    dvl.utime = int(time.time() * 1000000)    # Insert here unixtime
    dvl.dvl_number = 0                        # Unused at the moment, leave 0
    dvl.altitude = altitude + random.gauss(ALTITUDE_MEAN_NOISE,ALTITUDE_STANDARD_DEVIATION_NOISE)                       # ASSIGN here the AUV altitude from bottom
    dvl.bottom_vel[0] = vx + random.gauss(DVL_MEAN_NOISE,DVL_STANDARD_DEVIATION_NOISE)     # DVL x velocity in the instrument frame
    dvl.bottom_vel[1] = vy + random.gauss(DVL_MEAN_NOISE,DVL_STANDARD_DEVIATION_NOISE)     # DVL y velocity in the instrument frame
    dvl.bottom_vel[2] = vz + random.gauss(DVL_MEAN_NOISE,DVL_STANDARD_DEVIATION_NOISE) # DVL z velocity in the instrument frame
    dvl.bottom_vel[3] = 0.0;   # DVL error. Leave 0 here
    dvl.bottom_rng[0] = altitude;  # DVL beam 0 bottom range.  Use the same value as altitude
    dvl.bottom_rng[1] = altitude;  # DVL beam 1 bottom range.  Use the same value as altitude
    dvl.bottom_rng[2] = altitude;  # DVL beam 2 bottom range.  Use the same value as altitude
    dvl.bottom_rng[3] = altitude;  # DVL beam 3 bottom range.  Use the same value as altitude
    dvl.bt_good_beams = 4;     # Number of DVL good beams.  Leave 4 unless you want to simulate a bad dvl bottom lock
    dvl.water_vel[0] = 0.0;    # DVL x water velocity in the instrument frame. Can be set to 0.0
    dvl.water_vel[1] = 0.0;    # DVL y water velocity in the instrument frame. Can be set to 0.0
    dvl.water_vel[2] = 0.0;    # DVL z water velocity in the instrument frame. Can be set to 0.0
    dvl.water_vel[3] = 0.0;    # DVL water lock error. Leave zero here
    dvl.wt_good_beams = 4;     # Number of good DVL water beams.  Leave 4 unless you want to experiment bad DVL water lock performance
    dvl.temp = 25.0;           # Temperature measured by the DVL. Can be left at 25.0
    dvl.sv = 1500.0;           # DVL sound velocity. Set at 1500.0 m/s
    dvl.salinity = 123.5;      # DVL salinity
    dvl.depth = depth + random.gauss(DEPTH_MEAN_NOISE,DEPTH_STANDARD_DEVIATION_NOISE);          # DVL depth.  ASSIGN the AUV depth here
    midnight = datetime.datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    now = datetime.datetime.now()
    delta = now - midnight
    mytime = delta.seconds + (math.floor(delta.microseconds / 10000.0)) * 0.01
    dvl.sec_since_midnight = mytime # The last lines of code set the seconds and hundreths of seconds since midnight and are used to calculate the dead reckoning DT, simulating the DVL internal hardware clock.  Do not change!
    lc.publish("DVL", dvl.encode())

    time.sleep(0.2)
