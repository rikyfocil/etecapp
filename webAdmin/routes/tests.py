# -*- coding: utf-8 -*-
from django.test import TestCase, Client
from django import forms


from routes.apps import RoutesConfig
from routes.admin import CustomAdmin, ConductorForm, ConductorAdmin, admin_site
from routes.models import Conductor, Ruta
from routes.__init__ import default_app_config
from routes.views import SUC, FAIL, INV_NUM


class ViewTest(TestCase):
    def get(self, route='Test'):
        return self.client.get('/routes/get/', {'route': route})

    def set(self, lat, lng, route='Test'):
        return self.client.get('/routes/set/', {'route': route, 'lat': lat,
                                                'lng': lng})

    def checkJson(self, response, attribute, code):
        self.assertEquals(response.json()[attribute], code)

    def checkFailSet(self, lat, lng, errorCode):
        response = self.set(lat, lng)

        self.checkJson(response, 'result', FAIL)
        self.checkJson(response, 'message', errorCode)

    def checkFailGet(self, route):
        response = self.get(route)

        self.checkJson(response, 'result', FAIL)

    def checkSuc(self, response):
        self.checkJson(response, 'result', SUC)

    def checkSucGet(self):
        response = self.get()
        self.checkSuc(response)

    def checkSucSet(self, lat, lng):
        response = self.set(lat, lng)
        self.checkSuc(response)

        ruta = Ruta.objects.get(nombre='Test')

        self.assertEquals(ruta.lat, lat)
        self.assertEquals(ruta.lng, lng)

    def setUp(self):
        ruta = Ruta(nombre='Test', lat='1', lng='1', conductor_id=1)
        ruta.save()

        self.client = Client()

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
