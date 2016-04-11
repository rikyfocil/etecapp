from django.db import models

# Create your models here.

class Ruta(models.Model):
    nombre=models.CharField(max_length=40)
    conductor=models.CharField(max_length=80)
    pagina=models.URLField(max_length=100)
    def __str__(self):
        return self.nombre
