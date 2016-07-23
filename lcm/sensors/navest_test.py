#!/usr/bin/env python

from test_sensors import *

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
