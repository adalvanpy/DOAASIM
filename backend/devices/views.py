from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.permissions import (
    AllowAny,
    IsAuthenticated,
    IsAuthenticatedOrReadOnly
)
from rest_framework.views import APIView
from rest_framework.exceptions import PermissionDenied
from rest_framework.decorators import action

from .models import Aparelho, Perfil, Candidatura
from .serializers import (
    RegisterSerializer,
    DeviceSerializer,
    ProfileSerializer,
    CandidaturaSerializer
)


@method_decorator(csrf_exempt, name='dispatch')
class DeviceViewSet(viewsets.ModelViewSet):
    queryset = Aparelho.objects.all().order_by('-criado_em')
    serializer_class = DeviceSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]

    def perform_create(self, serializer):
        if self.request.user.perfil.tipo != 'DOADOR':
            raise PermissionDenied(
                'Somente usuários DOADOR podem cadastrar aparelhos.'
            )
        serializer.save(doador=self.request.user)

    def perform_update(self, serializer):
        if self.request.user.perfil.tipo != 'EMPRESA':
            raise PermissionDenied(
                'Apenas EMPRESAS podem alterar aparelhos.'
            )
        serializer.save()

    @action(detail=True, methods=['patch'], url_path='aprovar')
    def aprovar(self, request, pk=None):
        """Endpoint: /api/devices/{id}/aprovar/"""
        aparelho = self.get_object()
        
        if request.user.perfil.tipo != 'EMPRESA':
            raise PermissionDenied('Apenas empresas podem aprovar aparelhos.')
        
        aparelho.status = 'DISPONIVEL'
        aparelho.save()
        
        serializer = self.get_serializer(aparelho)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['patch'], url_path='reprovar')
    def reprovar(self, request, pk=None):
        """Endpoint: /api/devices/{id}/reprovar/"""
        aparelho = self.get_object()
        
        if request.user.perfil.tipo != 'EMPRESA':
            raise PermissionDenied('Apenas empresas podem reprovar aparelhos.')
        
        aparelho.status = 'REPROVADO'
        aparelho.save()
        
        serializer = self.get_serializer(aparelho)
        return Response(serializer.data, status=status.HTTP_200_OK)


@method_decorator(csrf_exempt, name='dispatch')
class ProfileViewSet(viewsets.ModelViewSet):
    queryset = Perfil.objects.all()
    serializer_class = ProfileSerializer
    permission_classes = [IsAuthenticated]


@method_decorator(csrf_exempt, name='dispatch')
class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        perfil = serializer.save()
        return Response(
            serializer.to_representation(perfil),
            status=status.HTTP_201_CREATED
        )


@method_decorator(csrf_exempt, name='dispatch')
class CandidaturaViewSet(viewsets.ModelViewSet):
    queryset = Candidatura.objects.all().order_by('-data_candidatura')
    serializer_class = CandidaturaSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        if self.request.user.perfil.tipo != 'CANDIDATO':
            raise PermissionDenied(
                'Somente candidatos podem se candidatar.'
            )
        aparelho = serializer.validated_data['aparelho']
        if aparelho.status != 'DISPONIVEL':
            raise PermissionDenied(
                'Este aparelho não está disponível.'
            )
        serializer.save(
            candidato=self.request.user,
            status='AGUARDANDO'
        )

    def perform_update(self, serializer):
        if self.request.user.perfil.tipo != 'EMPRESA':
            raise PermissionDenied(
                'Apenas empresas podem aprovar candidaturas.'
            )
        serializer.save()

    @action(detail=True, methods=['patch'], url_path='aprovar')
    def aprovar_candidatura(self, request, pk=None):
        """Endpoint: /api/candidaturas/{id}/aprovar/
        Empresa aprova uma candidatura
        """
        candidatura = self.get_object()
        
        if request.user.perfil.tipo != 'EMPRESA':
            raise PermissionDenied('Apenas empresas podem aprovar candidaturas.')
        
        if candidatura.status != 'AGUARDANDO':
            raise PermissionDenied(
                'Apenas candidaturas em análise podem ser aprovadas.'
            )
        
        candidatura.status = 'APROVADO'
        candidatura.save()
        
        serializer = self.get_serializer(candidatura)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=True, methods=['patch'], url_path='reprovar')
    def reprovar_candidatura(self, request, pk=None):
        """Endpoint: /api/candidaturas/{id}/reprovar/
        Empresa reprova uma candidatura
        """
        candidatura = self.get_object()
        
        if request.user.perfil.tipo != 'EMPRESA':
            raise PermissionDenied('Apenas empresas podem reprovar candidaturas.')
        
        if candidatura.status != 'AGUARDANDO':
            raise PermissionDenied(
                'Apenas candidaturas em análise podem ser reprovadas.'
            )
        
        candidatura.status = 'REPROVADO'
        candidatura.save()
        
        serializer = self.get_serializer(candidatura)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @action(detail=True, methods=['patch'], url_path='escolher')
    def escolher_candidato(self, request, pk=None):
        """Endpoint: /api/candidaturas/{id}/escolher/
        Empresa escolhe um candidato para receber o aparelho
        """
        candidatura = self.get_object()
        
        
        if request.user.perfil.tipo != 'EMPRESA':
            raise PermissionDenied('Apenas empresas podem escolher candidatos.')
        
        if candidatura.status != 'APROVADO':
            raise PermissionDenied(
                'Só é possível escolher candidaturas que já foram aprovadas.'
            )
        
        
        candidatura.status = 'ESCOLHIDO'
        candidatura.save()
        
       
        aparelho = candidatura.aparelho
        aparelho.status = 'DOADO'
        aparelho.save()
        
       
        outras_candidaturas = Candidatura.objects.filter(
            aparelho=aparelho
        ).exclude(id=candidatura.id)
        
        for outra in outras_candidaturas:
            if outra.status == 'APROVADO':
                outra.status = 'REPROVADO'
                outra.save()
        
        serializer = self.get_serializer(candidatura)
        return Response(serializer.data, status=status.HTTP_200_OK)