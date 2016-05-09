# -*- coding: utf-8 -*-
from django.core import exceptions


def validateConductorUsername(value):
    if len(value) != 9:
        raise exceptions.ValidationError(('Debe contener una D y 8 dígitos'))
    if value[0] != 'D':
        raise exceptions.ValidationError(('Debe empezar con D'))
    for digit in value[1:]:
        try:
            int(digit)
        except ValueError:
            raise exceptions.ValidationError(('Debe contener 8 dígitos después\
            de la D'))
