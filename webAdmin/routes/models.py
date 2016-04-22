from colorful.fields import RGBColorField

from django.db import models
from django.forms import PasswordInput
from django.contrib.auth.models import User

# Create your models here.

class Conductor(models.Model):
    nombre=models.CharField(max_length=80)
    clave=models.CharField(max_length=50,verbose_name='nueva clave',blank=True)
    def __str__(self):
        return self.nombre

    class Meta:
        verbose_name_plural = 'conductores'

class Ruta(models.Model):
    nombre=models.CharField(max_length=40)
    conductor=models.ForeignKey(Conductor)
    pagina=models.URLField(max_length=100)
    lat=models.FloatField()
    lng=models.FloatField()
    color=RGBColorField()
    def __str__(self):
        return self.nombre

class Perfil(models.Model):
    auth=models.OneToOneField(User)

class PerfilRuta(models.Model):
    perfil=models.ForeignKey(Perfil)
    ruta=models.ForeignKey(Ruta)
