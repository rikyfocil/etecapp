# -*- coding: utf-8 -*-
from django.contrib import admin
from django import forms

from .models import Ruta, Conductor, Perfil, PerfilRuta


class CustomAdmin(admin.AdminSite):
    site_title = 'Expreso Tec App'
    site_header = 'Expreso Tec App'
    index_title = 'Administración del sitio'


class ConductorForm(forms.ModelForm):
    class Meta:
        model = Conductor
        fields = ['nombre', 'clave']
        widgets = {
            'clave': forms.PasswordInput(),
        }


class ConductorAdmin(admin.ModelAdmin):
    form = ConductorForm

admin_site = CustomAdmin(name='customAdmin')
admin_site.register(Ruta)
admin_site.register(Conductor, ConductorAdmin)
admin_site.register(Perfil)
admin_site.register(PerfilRuta)

# Register your models here.
