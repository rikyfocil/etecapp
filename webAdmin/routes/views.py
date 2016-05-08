from django.http import JsonResponse
from django.views.decorators.http import require_GET, require_POST
from django.contrib.auth import authenticate
from django.views.decorators.csrf import csrf_exempt

from routes.models import Ruta, Perfil, PerfilRuta

SUC = 'success'
FAIL = 'failure'
NO_FIELD = 'no such field'
NO_ROUTE = 'no such expreso route'
NO_PROFILE = 'no such profile'
NO_USER = 'no such user'
NO_REGISTER = 'no such register'
INV_NUM = 'invalid number'
DUPLICATE = 'that subscription already exists'


@require_GET
def set(request):
    """Uzh"""
    result = FAIL
    message = ''

    try:
        name = request.GET.get('route')

        lat = float(request.GET.get('lat'))
        if lat < -90 or lat > 90:
            raise ValueError

        lng = float(request.GET.get('lng'))
        if lng < -180 or lng > 180:
            raise ValueError

        route = Ruta.objects.get(nombre=name)

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

    return JsonResponse({'result': result, 'message': message})


@require_GET
def get(request):
    result = FAIL
    message = ''
    lat = ''
    lng = ''

    try:
        name = request.GET.get('route')

        route = Ruta.objects.get(nombre=name)

        lat = route.lat
        lng = route.lng

        result = SUC

    except KeyError:
        message = NO_FIELD
    except Ruta.DoesNotExist:
        message = NO_ROUTE

    return JsonResponse({'result': result, 'message': message, 'lat': lat,
                         'lng': lng})


def getRoutes(request):
    routes = Ruta.objects.all()

    jsonRoutes = []
    for route in routes:
        routeDictionary = {'name': route.nombre, 'id': route.id,
                           'driver': route.conductor.nombre,
                           'color': route.color}
        jsonRoutes.append(routeDictionary)

    return JsonResponse({'routes': jsonRoutes})


@require_GET
def subscribe(request):
    result = FAIL
    message = ''

    try:
        profileId = request.GET.get('profileId')
        routeId = request.GET.get('routeId')

        profile = Perfil.objects.get(id=profileId)
        route = Ruta.objects.get(id=routeId)

        try:
            PerfilRuta.objects.get(perfil=profileId, ruta=routeId)
        except PerfilRuta.DoesNotExist:
            perfilRuta = PerfilRuta()
            perfilRuta.perfil = profile
            perfilRuta.ruta = route
            perfilRuta.save()

            result = SUC
        else:
            message = DUPLICATE

    except Perfil.DoesNotExist:
        message = NO_PROFILE
    except Ruta.DoesNotExist:
        message = NO_ROUTE
    except ValueError:
        message = INV_NUM

    return JsonResponse({'result': result, 'message': message})


@require_GET
def unsubscribe(request):
    result = FAIL
    message = ''

    try:
        profileId = request.GET.get('profileId')
        routeId = request.GET.get('routeId')

        perfilRuta = PerfilRuta.objects.get(perfil=profileId, ruta=routeId)
        perfilRuta.delete()

        result = SUC
    except PerfilRuta.DoesNotExist:
        message = NO_REGISTER

    return JsonResponse({'result': result, 'message': message})


def _getSubscriptions(profileId, routes):
    profile = Perfil.objects.get(id=profileId)
    profileRoutes = PerfilRuta.objects.filter(perfil=profile)

    for profileRoute in profileRoutes:
        route = profileRoute.ruta
        routeDictionary = {'id': route.id, 'name': route.nombre}
        routes.append(routeDictionary)


@require_GET
def getUserRoutes(request):
    result = FAIL
    message = ''
    routes = []

    profileId = request.GET.get('profileId')

    try:
        _getSubscriptions(profileId, routes)
        result = SUC

    except Perfil.DoesNotExist:
        message = NO_PROFILE

    return JsonResponse({'result': result, 'message': message,
                         'routes': routes})


@csrf_exempt
@require_POST
def mobileLogin(request):
    result = FAIL
    message = ''
    routes = []
    profileId = -1
    first_name = ''

    username = request.POST.get('username')
    password = request.POST.get('password')

    user = authenticate(username=username, password=password)

    if user is not None:
        try:
            profileId = Perfil.objects.get(auth=user).id
        except Perfil.DoesNotExist:
            message = NO_PROFILE

        first_name = user.first_name
        _getSubscriptions(profileId, routes)
        result = SUC
    else:
        message = NO_USER

    return JsonResponse({'result': result, 'message': message,
                         'routes': routes, 'id': profileId,
                         'name': first_name})
