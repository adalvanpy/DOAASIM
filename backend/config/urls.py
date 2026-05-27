from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter

# Importação das suas Views
from devices.views import DeviceViewSet, ProfileViewSet, CandidaturaViewSet 

# Importação das Views do JWT
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

# Configuração do Router para rotas automáticas
# O router cria as URLs de listar, criar, detalhar e deletar sozinho.
router = DefaultRouter()
router.register(r'devices', DeviceViewSet)
router.register(r'profiles', ProfileViewSet)
router.register(r'candidaturas', CandidaturaViewSet)    

urlpatterns = [
    # Painel Administrativo
    path('admin/', admin.site.urls),

    # Endpoints de Autenticação JWT
    # Use esses para pegar o Token no Postman
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # Endpoints da API (Aparelhos, Perfis e Candidaturas)
    # Todas as rotas registradas no router acima ficam acessíveis aqui
    path('api/', include(router.urls)),
]

# Configuração para servir as imagens e laudos em ambiente de desenvolvimento
# Isso permite que você clique no link da imagem/PDF na API e consiga visualizá-lo
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
