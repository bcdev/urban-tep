#!/usr/bin/python

import os
import sys
from string import Template

__author__ = 'boe'

class PStep:
    """
    Utility class for PMonitor step scripts written in Python, for request generation from template and request submission.
    Usage:
        #!/usr/bin/python

        from pstep import PStep
        import sys

        cmd = sys.argv[1]
        ps = PStep('CALVALUS')

        if cmd == 'subset':

            variables = {
                'regionname' : sys.argv[2].replace('-',' '),
                'regionid' : sys.argv[2],
                'regionwkt' : sys.argv[3],
                'input' : sys.argv[4],
                'output' : sys.argv[5]
            }
            request = ps.apply_template(cmd, variables, variables['regionid'])
            ps.submit_request(request)

        elif ...

    """

    def __init__(self, env_prefix):
        self._env_prefix = env_prefix

    def apply_template(self, cmd, variables, id):
        template = os.environ[self._env_prefix + '_INST'] + '/etc/' + cmd + '-template.xml'
        request = os.environ[self._env_prefix + '_INST'] + '/requests/' + cmd + '-' + id + '.xml'
        with open(template, 'r') as t:
            template_content = t.read()
        request_content = Template(template_content).safe_substitute(variables)
        with open(request, 'w') as r:
            r.write(request_content)
        return request

    def submit_request(self, request):
        os.execlp('java',
                  'java',
                  '-Xmx256m',
                  '-jar', os.environ[self._env_prefix + '_PRODUCTION_JAR'],
                  '-e',
                  '--snap' if 'snap' in os.environ[self._env_prefix + '_BEAM_VERSION'] else '--beam', os.environ[self._env_prefix + '_BEAM_VERSION'],
                  '--calvalus', os.environ[self._env_prefix + '_CALVALUS_VERSION'],
                  request)

if __name__ == '__main__':
    cmd = sys.argv[1]
    ps = PStep('CALVALUS')

    variables = {}
    id = ''
    for i in range(2, len(sys.argv)-2, 2):
        variables[sys.argv[i]] = sys.argv[i+1]
        if sys.argv[i] != 'stop' and sys.argv[i] != 'polygon':
            id += '-' + sys.argv[i+1]
    if id == '':
        id = '-' + sys.argv[-2][sys.argv[-2].rfind('/')+1:]
    variables['input'] = sys.argv[-2]
    variables['output'] = sys.argv[-1]
    request = ps.apply_template(cmd, variables, id[1:])
    ps.submit_request(request)
