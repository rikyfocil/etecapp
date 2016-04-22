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
            if lat < -90 or lat > 90:
                raise ValueError

            lng = float(request.GET.get('lng'))
            if lng < -180 or lng > 180:
                raise ValueError

            route = Ruta.objects.get(nombre = name)

            route.lat = lat
            route.lng = lng
            route.save()

            result = SUC

        except KeyError:
            message = NO_FIELD
        except Ruta.DoesNotExist:
            message = NO_ROUTE
        except ValueError:
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

def getRoutes(request):
    routes = Ruta.objects.all()

    jsonRoutes = []
    for route in routes:
        routeDictionary = {'name':route.nombre, 'id':route.id, 
                'driver':route.conductor.nombre, 'color':route.color}
        jsonRoutes.append(routeDictionary)

    return JsonResponse({'routes':jsonRoutes})
