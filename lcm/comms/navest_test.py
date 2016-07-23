#!/usr/bin/env python

import lcm
import time

from acomms import asv_to_auv_gps_owtt_t
from acomms import cmd_ping_t

lc = lcm.LCM("udpm://239.255.76.67:7667?ttl=0")

msgasv = asv_to_auv_gps_owtt_t()
msgowtt = cmd_ping_t()

while True:

    msgasv.utime = int(time.time() * 1000000)
    msgasv.lat = 72.5
    msgasv.lon = -40.2
    msgasv.owtt = 1.354533
    msgasv.hdop = 1.6
    lc.publish("ACOMM_RX", msgasv.encode())
    time.sleep(2)


