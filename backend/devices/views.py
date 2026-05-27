from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated, IsAuthenticatedOrReadOnly
from .models import Aparelho, Perfil, Candidatura
from .serializers import DeviceSerializer, ProfileSerializer, CandidaturaSerializer

class DeviceViewSet(viewsets.ModelViewSet):
    queryset = Aparelho.objects.all().order_by('-criado_em')
    serializer_class = DeviceSerializer
    # Permite que qualquer um veja os aparelhos, mas apenas logados criem/editem
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        # Associa o aparelho ao usuário autenticado (doador)
        serializer.save(doador=self.request.user)

class ProfileViewSet(viewsets.ModelViewSet):
    queryset = Perfil.objects.all()
    serializer_class = ProfileSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]

class CandidaturaViewSet(viewsets.ModelViewSet):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer
    permission_classes = [IsAuthenticated]  # Permite que qualquer um veja as candidaturas, mas apenas logados criem

    def perform_create(self, serializer):
        aparelho = serializer.validated_data['aparelho']
        
        # Tenta buscar a perda auditiva no perfil do usuário
        try:
            perfil_usuario = self.request.user.perfil
            candidato_perda = perfil_usuario.perda_indicada # Ajuste para o nome do campo no seu Perfil
        except AttributeError:
            candidato_perda = None

        # Lógica de validação automática:
        # Se a perda do candidato for EXATAMENTE a mesma do aparelho, já pré-aprova
        if candidato_perda and aparelho.perda_indicada == candidato_perda:
            serializer.save(candidato=self.request.user, status='APROVADO')
        else:
            # Caso contrário, fica aguardando análise humana (da Empresa)
            serializer.save(candidato=self.request.user, status='AGUARDANDO')