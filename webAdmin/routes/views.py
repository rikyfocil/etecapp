from django.http import JsonResponse
from routes.models import Ruta

SUC = 'success'
FAIL = 'failure'
NO_FIELD = 'no such field'
NO_ROUTE = 'no such expreso route'
INV_NUM = 'invalid number'

def set(request):
    result = FAIL
    message = ''

    if request.method == 'GET':
        try:
            name = request.GET.get('route')

            lat = float(request.GET.get('lat'))
            lng = float(request.GET.get('lng'))

            route = Ruta.objects.get(nombre = name)

            route.lat = lat
            route.lng = lng
            route.save()

            result = SUC

        except KeyError:
            message = NO_FIELD
        except Ruta.DoesNotExist:
            message = NO_ROUTE
        except TypeError:
            message = INV_NUM

    return JsonResponse({'result':result,'message':message})

def get(request):
    result = FAIL
    message = ''
    lat = ''
    lng = ''

    if request.method == 'GET':
        try:
            name = request.GET.get('route')

            route = Ruta.objects.get(nombre = name)

            lat = route.lat
            lng = route.lng

            result = SUC

        except KeyError:
            message = NO_FIELD
        except Ruta.DoesNotExist:
            message = NO_ROUTE

    return JsonResponse({'result':result,'message':message,'lat':lat,'lng':lng})
