# -*- coding: utf-8 -*-
from django.test import TestCase, Client
from django import forms
from django.contrib.auth.models import User

from routes.apps import RoutesConfig
from routes.admin import CustomAdmin, ConductorForm, ConductorAdmin, admin_site
from routes.models import Conductor, Ruta, Perfil, PerfilRuta
from routes.__init__ import default_app_config
from routes.views import SUC, FAIL, INV_NUM


class TestBase(TestCase):
    @classmethod
    def setUpTestData(self):
        self.client = Client()

    def checkJson(self, response, attribute, value):
        self.assertEquals(response.json()[attribute], value)

    def checkSuc(self, response):
        self.checkJson(response, 'result', SUC)

    def checkFail(self, response):
        self.checkJson(response, 'result', FAIL)


class TestRoute(TestBase):
    def setUp(self):
        ruta = Ruta(nombre='Test', lat='1', lng='1', conductor_id=1,
                    color='#000000')
        ruta.save()

        return ruta


class TestRouteDriver(TestRoute):
    def setUp(self):
        conductor = Conductor(nombre='TestDriver')
        conductor.save()
        super(TestRouteDriver, self).setUp()


class TestRouteProfile(TestRoute):
    def setUp(self):
        user = User.objects.create_user('testUser', 'test@example.com',
                                        'password')
        user.save()
        profile = Perfil(auth=user)
        profile.save()

        ruta = super(TestRouteProfile, self).setUp()
        perfilRuta = PerfilRuta(perfil=profile, ruta=ruta)
        perfilRuta.save()


class TestUser(TestBase):
    def setUp(self):
        user = User.objects.create_user('test', 'test@example.com', 'test')
        user.save()
        profile = Perfil(auth=user)
        profile.save()

        super(TestUser, self).setUp()


class GetSetTest(TestRoute):
    def get(self, route='Test'):
        return self.client.get('/routes/get/', {'route': route})

    def set(self, lat, lng, route='Test'):
        return self.client.get('/routes/set/', {'route': route, 'lat': lat,
                                                'lng': lng})

    def checkFailSet(self, lat, lng, errorCode):
        response = self.set(lat, lng)

        self.checkFail(response)
        self.checkJson(response, 'message', errorCode)

    def checkFailGet(self, route):
        response = self.get(route)

        self.checkFail(response)

    def checkSucGet(self):
        response = self.get()
        self.checkSuc(response)

    def checkSucSet(self, lat, lng):
        response = self.set(lat, lng)
        self.checkSuc(response)

        ruta = Ruta.objects.get(nombre='Test')

        self.assertEquals(ruta.lat, lat)
        self.assertEquals(ruta.lng, lng)

    # Right
    def testSet(self):
        self.checkSucSet(2, 2)

    def testGet(self):
        self.checkSucGet()

    # Conformance
    def testLatInvalid(self):
        self.checkFailSet('str', '2', INV_NUM)

    def testLngInvalid(self):
        self.checkFailSet('2', 'str', INV_NUM)

    # Ordering - there's no enforced order

    # Range
    def testLatLowerOut(self):
        self.checkFailSet('-200', '1', INV_NUM)

    def testLngLowerOut(self):
        self.checkFailSet('1', '-200', INV_NUM)

    def testLatLowerBound(self):
        self.checkSucSet(-90, 1)

    def testLngLowerBound(self):
        self.checkSucSet(1, -180)

    def testLatUpperOut(self):
        self.checkFailSet('200', '1', INV_NUM)

    def testLngUpperOut(self):
        self.checkFailSet('1', '200', INV_NUM)

    def testLatUpperBound(self):
        self.checkSucSet(90, 1)

    def testLngUpperBound(self):
        self.checkSucSet(1, 180)

    # Reference - nothing external to reference

    # Existence
    def testRouteEmpty(self):
        self.checkFailGet('')

    def testLatEmpty(self):
        self.checkFailSet('', '1', INV_NUM)

    def testLngEmpty(self):
        self.checkFailSet('1', '', INV_NUM)

    def testRouteNone(self):
        self.checkFailGet(None)

    def testLatNone(self):
        self.checkFailSet(None, '1', INV_NUM)

    def testLngNone(self):
        self.checkFailSet('1', None, INV_NUM)

    # Cardinality - no cardinality to check

    # Time - no order to check

    # Inverse relations
    def testSetGet(self):
        self.set(3, 3)

        response = self.get()
        self.checkJson(response, 'result', SUC)
        self.checkJson(response, 'lat', 3)
        self.checkJson(response, 'lng', 3)

    # Cross-check - no algorithm to cross-check

    # Errors - no error conditions

    # Performance - no need to check performance (no complex algorithms or time
    # limits for the interaction between server and client)


class GetRoutesTest(TestRouteDriver):
    def getRoutes(self):
        return self.client.get('/routes/getRoutes/')

    # Right
    def testGetRoutes(self):
        routes = [{'name': 'Test', 'id': 1, 'driver': 'TestDriver',
                   'color': '#000000'}]

        self.checkJson(self.getRoutes(), 'routes', routes)

    # Boundaries - no boundaries here

    # Inverse relations - no inverse relations to test

    # Cross-check - no algorithm to cross-check

    # Errors - no error conditions

    # Performance - no need to check performance


class SubscribeUnsubscribeTest(TestRouteProfile):
    def subscribe(self, profileId=1, routeId=1):
        return self.client.get('/routes/subscribe/', {'profileId': profileId,
                                                      'routeId': routeId})

    def unsubscribe(self, profileId=1, routeId=1):
        return self.client.get('/routes/unsubscribe/', {'profileId': profileId,
                                                        'routeId': routeId})

    def checkSubscribeFail(self, profile, route):
        response = self.subscribe(profile, route)
        self.checkFail(response)

    def checkSubscribeSuc(self, profile=1, route=1):
        response = self.subscribe(profile, route)
        self.checkSuc(response)

    def checkUnsubscribeFail(self, profile, route):
        response = self.unsubscribe(profile, route)
        self.checkFail(response)

    def checkUnsubscribeSuc(self, profile=1, route=1):
        response = self.unsubscribe(profile, route)
        self.checkSuc(response)

    def checkSubsUnsSuc(self, profile=1, route=1):
        self.checkSubscribeSuc(profile, route)
        self.checkUnsubscribeSuc(profile, route)

    # Right
    def testSubscribeUnsubscribe(self):
        self.checkUnsubscribeSuc(1, 1)
        self.checkSubsUnsSuc(1, 1)

    # Boundaries

    # Conformance
    def testSubscribeProfileConformance(self):
        self.checkSubscribeFail('a', 1)

    def testSubscribeRouteConformance(self):
        self.checkSubscribeFail(1, 'a')

    # Order - no order to check

    # Range - no range to check

    # Reference - nothing external is referenced

    # Existence
    def testSubscribeProfileExistence(self):
        self.checkSubscribeFail(1, '')

    def testSubscribeRouteExistence(self):
        self.checkSubscribeFail('', 1)

    # Cardinality
    def testSubscribeCardinality(self):
        response = self.client.get('/routes/subscribe/', {
            'profileId': '1'})
        self.checkFail(response)

    # Time
    def testInvalidUnsubscribe(self):
        self.checkUnsubscribeSuc(1, 1)
        self.checkUnsubscribeFail(1, 1)

    # Inverse relations - already checked in right

    # Cross-check - no algorithm to cross-check

    # Errors - no error conditions

    # Performance - no need to check performance


class getUserRoutesTest(TestRouteProfile):
    # Right
    def testGetUserRoutes(self):
        routes = [{'name': 'Test', 'id': 1}]

        routesDict = {'result': SUC, 'message': '', 'routes': routes}

        response = self.client.get('/routes/getUserRoutes',
                                   {'profileId': 1})

        self.checkSuc(response)
        self.assertEquals(response.json(), routesDict)

    # Boundaries - no boundary

    # Inverse relations - no inverse

    # Cross-check - no algorithm to cross checkFail

    # Errors
    def testGetUserRoutesEmptyList(self):
        self.client.get('/routes/unsubscribe/', {'profileId': 1,
                                                 'routeId': 1})

        routes = []

        routesDict = {'result': SUC, 'message': '', 'routes': routes}

        response = self.client.get('/routes/getUserRoutes',
                                   {'profileId': 1})

        self.checkSuc(response)
        self.assertEquals(response.json(), routesDict)

    # Performance - no need


class MobileLoginTest(TestUser):
    def login(self, username='test', password='test'):
        return self.client.get('/routes/mobileLogin/', {'username': username,
                                                        'password': password})

    def checkSucLogin(self, username='test', password='test'):
        self.checkSuc(self.login(username, password))

    def checkFailLogin(self, username, password):
        self.checkFail(self.login(username, password))

    # Right
    def testLogin(self):
        self.checkSucLogin()

    # Boundaries - no boundaries

    # Inverse - no inverse

    # Cross - no algorithm to cross-checkFail

    # Error
    def testLoginBadPassword(self):
        self.checkFailLogin('test', 'test1')

    def testLoginBadUsername(self):
        self.checkFailLogin('test1', 'test')

    # Performance - no need to check performance


class RoutesTest(TestCase):
    # Right
    def testRoutesConfig(self):
        self.assertEquals(RoutesConfig.name, 'routes')
        self.assertEquals(RoutesConfig.verbose_name, 'Rutas')

    def testCorrectConfigUsed(self):
        self.assertEquals(default_app_config, 'routes.apps.RoutesConfig')

    # Boundaries - no boundaries here

    # Inverse relations - no inverse relations to test

    # Cross-check - no algorithm to cross-check

    # Errors - no error conditions

    # Performance - no need to check performance


class AdminTest(TestCase):
    # Right
    def testCustomAdmin(self):
        self.assertEquals(CustomAdmin.site_title, 'Expreso Tec App')
        self.assertEquals(CustomAdmin.site_header, 'Expreso Tec App')
        self.assertEquals(CustomAdmin.index_title, 'Administración del sitio')

    def testConductorForm(self):
        self.assertEquals(ConductorForm.Meta.model, Conductor)
        self.assertEquals(ConductorForm.Meta.fields, ['nombre', 'clave'])
        self.assertIsInstance(ConductorForm.Meta.widgets['clave'],
                              forms.PasswordInput)

    def testConductorAdmin(self):
        self.assertEquals(ConductorAdmin.form, ConductorForm)

    def testAdminSite(self):
        try:
            admin_site._registry[Ruta]
            self.assertIsInstance(admin_site._registry[Conductor],
                                  ConductorAdmin)
        except KeyError:
            self.fail('Missing keys in admin_site')

    # Boundaries - no boundaries here

    # Inverse relations - no inverse relations to test

    # Cross-check - no algorithm to cross-check

    # Errors - no error conditions

    # Performance - no need to check performance
