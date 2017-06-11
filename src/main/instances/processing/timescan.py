import datetime
import calendar
from pmonitor import PMonitor

regions = {
#    'cairo' : 'POLYGON((30.912 29.726,30.912 30.73,32.067 30.73,32.067 29.726,30.912 29.726))',
#    'delhi' : 'POLYGON((76.39266751207894 28.012949099044146,76.39266751207894 29.360422025223436,77.9286520679992 29.360422025223436,77.9286520679992 28.012949099044146,76.39266751207894 28.012949099044146))',
#    'ho_chi_minh' : 'POLYGON((106.21001049932467 10.350689960784472,106.21001049932467 11.249005244904005,107.12452319208158 11.249005244904005,107.12452319208158 10.350689960784472,106.21001049932467 10.350689960784472))',
#    'lagos' : 'POLYGON((2.1058789021033513 5.819138620787439,2.1058789021033513 8.154758359498196,4.458968090389325 8.154758359498196,4.458968090389325 5.819138620787439,2.1058789021033513 5.819138620787439))',
#    'mexico_city' : 'POLYGON((-99.70900979233465 18.85122310111935,-99.70900979233465 20.198696027298624,-98.27933249282161 20.198696027298624,-98.27933249282161 18.85122310111935,-99.70900979233465 18.85122310111935))',
#    'sao_paulo' : 'POLYGON((-47.41538061305751 -24.16080234326242,-47.41538061305751 -22.723497888671186,-45.84878717258703 -22.723497888671186,-45.84878717258703 -24.16080234326242,-47.41538061305751 -24.16080234326242))',
#    'beijing' : 'POLYGON((116 39.6,116 40.5,117.2 40.5,117.2 39.6,116 39.6))',
    'kampala' : 'POLYGON((32.4 0,32.8 0,32.8 0.5,32.4 0.5,32.4 0))'
}
years = range(2015,2017)
months = range(1,13)
start = '2015-06-25'
stop = '2016-11-30'
period = str((datetime.datetime.strptime(stop, '%Y-%m-%d').date() -
              datetime.datetime.strptime(start, '%Y-%m-%d').date()).days + 1)

l1c_dir = '/calvalus/eodata/S2_L1C/granules-urban'
idepix_dir = '/calvalus/projects/urban-tep/msi-idepix'
timescan_seq_dir = '/calvalus/projects/urban-tep/msi-tsseq'
timescan_dir = '/calvalus/projects/urban-tep/msi-timescan'

inputs = [ l1c_dir ]

pm = PMonitor(inputs, request='timescan',
              types=[('msi-idepix',2),('msi-timescan',7),('msi-format',7)],
              hosts=[('localhost',12)], logdir='log', script='pstep.py', simulation=False)

for year in years:
    for month in months:
        if '{0:04d}-{1:02d}'.format(year, month) < start[:7] or '{0:04d}-{1:02d}'.format(year, month) > stop[:7]:
            continue
        beginning_of_month = str(datetime.date(year, month, 1))
        end_of_month = str(datetime.date(year, month, calendar.monthrange(year, month)[1]))
        
        pm.execute('msi-idepix', [ l1c_dir ], [ idepix_dir ],
                   parameters=[ 'year', '{0:04d}'.format(year), 'month', '{0:02d}'.format(month),
                                'start', beginning_of_month, 'stop', end_of_month ])

for region in regions:
    polygon = regions[region]
    pm.execute('msi-timescan', [ idepix_dir ], [ '{0}/{1}'.format(timescan_seq_dir, region) ],
               [ 'region', region, 'polygon', "'{0}'".format(polygon),
                 'start', start, 'stop', stop, 'period', period ])
    pm.execute('msi-format', [ '{0}/{1}'.format(timescan_seq_dir, region) ],
               [ '{0}/{1}'.format(timescan_dir, region) ],
               [ 'region', region, 'polygon', "'{0}'".format(polygon) ])
                
pm.wait_for_completion()

