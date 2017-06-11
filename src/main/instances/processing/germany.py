import datetime
import calendar
from pmonitor import PMonitor

start = '2015-06-25'
stop = '2016-11-30'
period = str((datetime.datetime.strptime(stop, '%Y-%m-%d').date() -
              datetime.datetime.strptime(start, '%Y-%m-%d').date()).days + 1)

idepix_dir = '/calvalus/projects/urban-tep/s2-idepix/germany '
timescan_seq_dir = '/calvalus/projects/urban-tep/msi-germany-'
timescan_dir = '/calvalus/projects/urban-tep/msi-germany-20m'

inputs = [ idepix_dir ]

pm = PMonitor(inputs, request='germany',
              types=[('msi-timescan',4),('msi-format',7)],
              hosts=[('localhost',12)], logdir='log', script='pstep.py', simulation=False)

for lat in range(47,55):
    for lon in range(6,15):
#for lat in range(47,49):
#    for lon in range(6,8):
        polygon = "POLYGON(({0} {2},{0} {3},{1} {3},{1} {2},{0} {2}))".format(lon,lon+1, lat,lat+1)
        region = "h{0:03d}v{1:03d}".format(lon+180, 90-lat-1)
        pm.execute('msi-timescan', [ idepix_dir ], [ timescan_seq_dir+region ],
                   [ 'polygon', "'{0}'".format(polygon),
                     'start', start, 'stop', stop, 'period', period, 'region', region ])
        pm.execute('msi-format', [ timescan_seq_dir+region ], [ timescan_dir ],
                   [ 'region', region, 'polygon', "'{0}'".format(polygon) ])
                
pm.wait_for_completion()

