from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import os
from ansible.plugins.callback import CallbackBase

class CallbackModule(CallbackBase):
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'task_info'

    def v2_playbook_on_task_start(self, task, is_conditional):
        path = task.get_path()
        if path:
            line_number = self._get_line_number(path, task.name)
            self._display.display(f'Task: {task.get_name()}')
            self._display.display(f'Path: {path}')
            self._display.display(f'Line Number: {line_number}')

    def _get_line_number(self, path, task_name):
        with open(path, 'r') as file:
            for num, line in enumerate(file, 1):
                if task_name in line:
                    return num
        return 'unknown'
