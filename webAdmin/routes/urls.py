"""webAdmin URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.9/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.conf.urls import url, include
    2. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""
from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^set', views.set, name='set'),
    url(r'^getUserRoutes', views.getUserRoutes, name='getUserRoutes'),
    url(r'^getRoutes', views.getRoutes, name='getRoutes'),
    url(r'^get', views.get, name='get'),
    url(r'^subscribe', views.subscribe, name='subscribe'),
    url(r'^unsubscribe', views.unsubscribe, name='unsubscribe'),
    url(r'^mobileLogin', views.mobileLogin, name='mobileLogin')
]
