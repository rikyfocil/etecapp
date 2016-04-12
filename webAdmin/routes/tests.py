from django.test import TestCase
from django import forms
from django.contrib.admin import ModelAdmin

from routes.apps import RoutesConfig
from routes.admin import CustomAdmin, ConductorForm, ConductorAdmin, admin_site
from routes.models import Conductor, Ruta
from routes.__init__ import default_app_config

class RoutesTest(TestCase):
    # Right
    def testRoutesConfig(self):
        self.assertEquals(RoutesConfig.name,'routes')
        self.assertEquals(RoutesConfig.verbose_name,'Rutas')

    def testCorrectConfigUsed(self):
        self.assertEquals(default_app_config,'routes.apps.RoutesConfig')

    # Boundaries - no boundaries here

    # Inverse relations - no inverse relations to test

    # Cross-check - no algorithm to cross-check

    # Errors - no error conditions

    # Performance - no need to check performance

class AdminTest(TestCase):
    # Right
    def testCustomAdmin(self):
        self.assertEquals(CustomAdmin.site_title,'Expreso Tec App') 
        self.assertEquals(CustomAdmin.site_header,'Expreso Tec App') 
        self.assertEquals(CustomAdmin.index_title,'Administración del sitio') 

    def testConductorForm(self):
        self.assertEquals(ConductorForm.Meta.model,Conductor) 
        self.assertEquals(ConductorForm.Meta.fields,['nombre','clave']) 
        self.assertIsInstance(ConductorForm.Meta.widgets['clave'],forms.PasswordInput) 

    def testConductorAdmin(self):
        self.assertEquals(ConductorAdmin.form,ConductorForm) 

    def testAdminSite(self):
        try:
            admin_site._registry[Ruta]
            self.assertIsInstance(admin_site._registry[Conductor],ConductorAdmin)
        except KeyError:
            self.fail('Missing keys in admin_site')

    # Boundaries - no boundaries here

    # Inverse relations - no inverse relations to test

    # Cross-check - no algorithm to cross-check

    # Errors - no error conditions

    # Performance - no need to check performance
