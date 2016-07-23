#!/usr/bin/env python

import lcm
import time
import math
import datetime
import random

from sensors import *

class SimState:
    def __init__(self):
        self.vx= 0.0
        self.vy= 0.0
        self.vz= 0.0
        self.depth= 0.0
        self.altitude = 0.0
        self.heading= 0.0
        self.pitch= 0.0
        self.roll= 0.0
        self.gps_lat= 0.0
        self.gps_lon= 0.0
        self.hdop= 0.0
        self.vdop = 0.0
        self.gotGps= False

    def set_state(self, vx, vy, vz, depth, altitude, heading, pitch, roll, gps_lat, gps_lon, hdop, vdop, gotGps):
        self.vx= vx
        self.vy= vy
        self.vz= vz
        self.depth= depth
        self.altitude = altitude
        self.heading= heading
        self.pitch= pitch
        self.roll= roll
        self.gps_lat= gps_lat
        self.gps_lon= gps_lon
        self.hdop= hdop
        self.vdop= vdop
        self.gotGps= gotGps

lc = lcm.LCM("udpm://239.255.76.67:7667?ttl=0")

dvl        = dvl_t()
compass    = compass_t()
depths     = depth_t()
gps        = gps_t()
sim_state  = SimState()

# DVL velocities parameters - go in circles
omega      = 0.1 # rad/s
phase      = 0.0 # rad
amplitude  = 1.0 # m/s

DVL_MEAN_NOISE = 0.0
DVL_STANDARD_DEVIATION_NOISE = 0.001 # m/s
COMPASS_MEAN_NOISE = 0.0
COMPASS_STANDARD_DEVIATION_NOISE = 1.0 # degrees
GPS_MEAN_NOISE = 0.0
GPS_STANDARD_DEVIATION_NOISE = 0.000001 # decimal degrees
DEPTH_MEAN_NOISE = 0.0
DEPTH_STANDARD_DEVIATION_NOISE = 0.001 # meters
ALTITUDE_MEAN_NOISE = 0.0
ALTITUDE_STANDARD_DEVIATION_NOISE = 0.001 # meters


def send_state_to_navest(vx, vy, vz, depth, altitude, heading, pitch, roll, gps_lat, gps_lon, hdop, vdop, gotGps):
    sim_state.set_state(vx, #Vx in the vehicle frame
                        vy, #Vy in the vehicle frame
                        vz,        #Vz in the vehicle frame
                        depth,       #Depth
                        altitude,       #Altitude
                        heading,      #True heading
                        pitch,        #Pitch
                        roll,        #Roll
                        gps_lat,       #AUV GPS latitude
                        gps_lon,      #AUV GPS longitude
                        hdop,        #AUV GPS hdop
                        vdop,        #AUV GPS vdop
                        gotGps)       #AUV has a GPS fix? 



    ########### THE FOLLOWING CREATES THE LCM MESSAGES AND SHOULD NOT BE MODIFIED ############

    compass.utime = int(time.time() * 1000000)  # Insert here unixtime
    compass.heading = sim_state.heading + random.gauss(COMPASS_MEAN_NOISE,COMPASS_STANDARD_DEVIATION_NOISE);                     # Insert here True heading
    compass.pitch = sim_state.pitch + random.gauss(COMPASS_MEAN_NOISE,COMPASS_STANDARD_DEVIATION_NOISE);                         # Insert here pitch
    compass.roll = sim_state.roll + random.gauss(COMPASS_MEAN_NOISE,COMPASS_STANDARD_DEVIATION_NOISE);                          # Insert here roll
    lc.publish("COMPASS", compass.encode())

    dvl.utime = int(time.time() * 1000000)    # Insert here unixtime
    dvl.dvl_number = 0                        # Unused at the moment, leave 0
    dvl.altitude = sim_state.altitude + random.gauss(ALTITUDE_MEAN_NOISE,ALTITUDE_STANDARD_DEVIATION_NOISE)                       # ASSIGN here the AUV altitude from bottom
    dvl.bottom_vel[0] = sim_state.vx + random.gauss(DVL_MEAN_NOISE,DVL_STANDARD_DEVIATION_NOISE)     # DVL x velocity in the instrument frame
    dvl.bottom_vel[1] = sim_state.vy + random.gauss(DVL_MEAN_NOISE,DVL_STANDARD_DEVIATION_NOISE)     # DVL y velocity in the instrument frame
    dvl.bottom_vel[2] = sim_state.vz + random.gauss(DVL_MEAN_NOISE,DVL_STANDARD_DEVIATION_NOISE) # DVL z velocity in the instrument frame
    dvl.bottom_vel[3] = 0.0;   # DVL error. Leave 0 here
    dvl.bottom_rng[0] = dvl.altitude;  # DVL beam 0 bottom range.  Use the same value as altitude
    dvl.bottom_rng[1] = dvl.altitude;  # DVL beam 1 bottom range.  Use the same value as altitude
    dvl.bottom_rng[2] = dvl.altitude;  # DVL beam 2 bottom range.  Use the same value as altitude
    dvl.bottom_rng[3] = dvl.altitude;  # DVL beam 3 bottom range.  Use the same value as altitude
    dvl.bt_good_beams = 4;     # Number of DVL good beams.  Leave 4 unless you want to simulate a bad dvl bottom lock
    dvl.water_vel[0] = 0.0;    # DVL x water velocity in the instrument frame. Can be set to 0.0
    dvl.water_vel[1] = 0.0;    # DVL y water velocity in the instrument frame. Can be set to 0.0
    dvl.water_vel[2] = 0.0;    # DVL z water velocity in the instrument frame. Can be set to 0.0
    dvl.water_vel[3] = 0.0;    # DVL water lock error. Leave zero here
    dvl.wt_good_beams = 4;     # Number of good DVL water beams.  Leave 4 unless you want to experiment bad DVL water lock performance
    dvl.temp = 25.0;           # Temperature measured by the DVL. Can be left at 25.0
    dvl.sv = 1500.0;           # DVL sound velocity. Set at 1500.0 m/s
    dvl.salinity = 123.5;      # DVL salinity
    dvl.depth = sim_state.depth + random.gauss(DEPTH_MEAN_NOISE,DEPTH_STANDARD_DEVIATION_NOISE);          # DVL depth.  ASSIGN the AUV depth here
    midnight = datetime.datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    now = datetime.datetime.now()
    delta = now - midnight
    mytime = delta.seconds + (math.floor(delta.microseconds / 10000.0)) * 0.01
    dvl.sec_since_midnight = mytime # The last lines of code set the seconds and hundreths of seconds since midnight and are used to calculate the dead reckoning DT, simulating the DVL internal hardware clock.  Do not change!
    lc.publish("DVL", dvl.encode())

    depths.utime = int(time.time() * 1000000) # Insert here unixtime
    depths.depth = sim_state.depth + random.gauss(DEPTH_MEAN_NOISE,DEPTH_STANDARD_DEVIATION_NOISE)                   # ASSIGN the AUV depth here
    lc.publish("DEPTH", depths.encode())

    gps.utime = int(time.time() * 1000000) # Insert here unixtime
    gps.lat = sim_state.gps_lat + random.gauss(GPS_MEAN_NOISE,sim_state.hdop * GPS_STANDARD_DEVIATION_NOISE)                  # GPS reading of AUV latitude
    gps.lon = sim_state.gps_lon + random.gauss(GPS_MEAN_NOISE,sim_state.hdop * GPS_STANDARD_DEVIATION_NOISE)                 # GPS reading of AUV longitude
    gps.height = 0.0                # GPS reading of AUV height over sea level. Can leave at 0.0
    gps.hdop = sim_state.hdop                  # AUV GPS horizontal dilution of precision. Set between 1.0 and 2.0 for most common operational values. 1.0=GPS fix with low error, 2.0=GPS fix with higher error 
    gps.vdop = sim_state.vdop                  # AUV GPS vertical dilution of precision.  Set this too between 1.0 and 2.0
    if (sim_state.gotGps == True):
        lc.publish("GPS", gps.encode())



if __name__ == "__main__":

    while True:
        
        t = time.time()
        circles_vx = amplitude * math.cos(omega * t + phase)
        circles_vy = amplitude * math.sin(omega * t + phase)

        send_state_to_navest(circles_vx, #Vx in the vehicle frame
                             circles_vy, #Vy in the vehicle frame
                             0.0,        #Vz in the vehicle frame
                             10.0,       #Depth
                             35.0,       #Altitude
                             275.0,      #True heading
                             0.0,        #Pitch
                             0.0,        #Roll
                             30.0,       #AUV GPS latitude
                             -60.0,      #AUV GPS longitude
                             1.4,        #AUV GPS hdop
                             1.8,        #AUV GPS vdop
                             True)       #AUV has a GPS fix?

        time.sleep(0.5)
