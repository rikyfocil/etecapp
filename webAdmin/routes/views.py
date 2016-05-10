"""This module defines possible views for the Django app.

==================
Things to consider
==================

- Their responses are valid JSON because XML should die a slow and painful
  death.
- Except for getRoutes, they all return a **result**, which can be *success*
  or *failure*, and a message, which can be an empty string if the result was
  *success* or a string describing an error if the result was *failure*.
- A route is composed of the following properties: name (string),
  id (integer), driver (string), color (string) and page (string). They can be
  included in arrays.

----

==========================
List of non-empty messages
==========================

**no such field**
   The route is probably missing a latitude and/or longitude value.
**no such expreso route**
   The route id does not match any known route.
**no such profile**
   The profile id or user provided does not match any known profile (remember
   to associate the user with a profile if you are trying to authenticate).
**no such user**
   A user with that combination of username and password doesn't exist.
**no such register**
   The request tried to unsubscribe the user from a route he did not subscribe
   to.
**invalid number**
   The value sent to the view is not an actual number.
**subscription already exists**
   The request tried to resubscribe a user to a route.

----

=============
List of views
=============
"""
from django.http import JsonResponse
from django.views.decorators.http import require_GET, require_POST
from django.contrib.auth import authenticate
from django.views.decorators.csrf import csrf_exempt

from routes.models import Ruta, Perfil, PerfilRuta, Conductor

SUC = 'success'
FAIL = 'failure'
NO_FIELD = 'no such field'
NO_ROUTE = 'no such expreso route'
NO_PROFILE = 'no such profile'
NO_USER = 'no such user'
NO_REGISTER = 'no such register'
INV_NUM = 'invalid number'
DUPLICATE = 'subscription already exists'


@require_GET
def set(request):
    """| **Parameters**: route (string), lat (float) and lng (float)

    **Returns**: result and message.

    The set view sets the latitude and longitude of *route* to *lat* and *lng*.
    """
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
    """| **Parameters**: route (string)

    **Returns**: result, message, lat (float) and lng (float).

    The get view gets the latitude and longitude from *route* as *lat* and
    *lng*.
    """
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


@require_GET
def subscribe(request):
    """| **Parameters**: profileId (integer) and routeId (integer)

    **Returns**: result and message.

    The subscribe view subscribes a profile matching *profileId* to a route
    matching *routeId*.
    """
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
    """| **Parameters**: profileId (integer) and routeId (integer)

    **Returns**: result and message.

    The unsubscribe view unsubscribes a profile matching *profileId* from a
    route matching *routeId*.
    """
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


def _getRouteDictionary(route):
    """Add route to the routes list"""
    try:
        driver = route.conductor.nombre
    except Conductor.DoesNotExist:
        driver = ''

    routeDictionary = {'id': route.id, 'name': route.nombre,
                       'driver': driver, 'page': route.pagina,
                       'color': route.color}
    return routeDictionary


def _getSubscriptions(profileId, routes):
    """Put profileId subscriptions in routes.

    This method appends the routes to which the profile matching profileId is
    subscribed to the routes list provided.
    """
    profile = Perfil.objects.get(id=profileId)
    profileRoutes = PerfilRuta.objects.filter(perfil=profile)

    for profileRoute in profileRoutes:
        route = profileRoute.ruta
        routes.append(_getRouteDictionary(route))


def getRoutes(request):
    """| **Parameters**: NONE

    **Returns**: routes (array).

    The getRoutes view returns a list of all the routes as *routes*.
    """
    routes = Ruta.objects.all().order_by('id')

    jsonRoutes = []
    for route in routes:
        jsonRoutes.append(_getRouteDictionary(route))

    return JsonResponse({'routes': jsonRoutes})


@require_GET
def getUserRoutes(request):
    """| **Parameters**: profileId (integer)

    **Returns**: result, message and routes (array).

    The getUserRoutes view returns the routes from the profile matching
    *profileId* inside a *routes* array.
    .
    """
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
    """| **Parameters**: username (string) and password (string)

    **Returns**: result, message, id (integer), name (string) and routes
    (array).

    The mobileLogin view returns whether *username* and *password* are a valid
    combination for an existing user and, if so, also returns its *routes*,
    *name*, *username* and profile *id*.
    """
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
            first_name = user.first_name
            _getSubscriptions(profileId, routes)
            result = SUC
        except Perfil.DoesNotExist:
            message = NO_PROFILE
    else:
        message = NO_USER

    return JsonResponse({'result': result, 'message': message,
                         'routes': routes, 'id': profileId,
                         'name': first_name, 'username': username})


@csrf_exempt
@require_POST
def driverLogin(request):
    """| **Parameters**: username (string) and password (string)

    **Returns**: result, message, id (integer), name (string) and route.

    The driverLogin view returns whether *username* and *password* are a valid
    combination for a driver and also returns its *route*, *name*, *id* and
    *username*.
    """
    result = FAIL
    message = ''
    id = -1
    name = ''
    route = {}

    username = request.POST.get('username')
    password = request.POST.get('password')

    try:
        driver = Conductor.objects.get(usuario=username, clave=password)

        route = _getRouteDictionary(Ruta.objects.get(conductor=driver))

        id = driver.id
        name = driver.nombre
        result = SUC
    except Conductor.DoesNotExist:
        message = NO_USER
    except Ruta.DoesNotExist:
        message = NO_ROUTE

    return JsonResponse({'result': result, 'message': message,
                         'route': route, 'id': id, 'name': name,
                         'username': username})
