from django.contrib import admin

from .models import Ruta

class CustomAdmin(admin.AdminSite):
    site_title  = 'Expreso Tec App'
    site_header = 'Expreso Tec App'
    index_title = 'Administración del sitio'

admin_site = CustomAdmin(name='customAdmin')
admin_site.register(Ruta)

# Register your models here.
