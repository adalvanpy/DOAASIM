from django.contrib import admin

from django.contrib import admin
from .models import Aparelho, Candidatura, Perfil

admin.site.register(Aparelho)
admin.site.register(Perfil)
admin.site.register(Candidatura)
