import sys
sys.path.insert(0, 'pygtfs')
import pygtfs

sched = pygtfs.Schedule("gtfs.sqlite")
pygtfs.append_feed(sched, "Trimet_2016-02-13")
