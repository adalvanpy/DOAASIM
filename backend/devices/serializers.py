from rest_framework import serializers
from .models import Aparelho, Perfil, Candidatura
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    """Serializer para mostrar dados básicos do usuário"""
    class Meta:
        model = User
        fields = ['id', 'username', 'email']

class ProfileSerializer(serializers.ModelSerializer):
    user_details = UserSerializer(source='user', read_only=True)
    tipo_display = serializers.CharField(source='get_tipo_display', read_only=True)

    class Meta:
        model = Perfil
        fields = ['id', 'user', 'user_details', 'tipo', 'tipo_display', 'cpf_cnpj']

class DeviceSerializer(serializers.ModelSerializer):
    modelo_display = serializers.CharField(source='get_modelo_anatomico_display', read_only=True)
    perda_display = serializers.CharField(source='get_perda_indicada_display', read_only=True)
    doador_nome = serializers.CharField(source='doador.username', read_only=True)

    class Meta:
        model = Aparelho
        fields = [
            'id', 'nome', 'marca', 'modelo_anatomico', 'modelo_display', 
            'perda_indicada', 'perda_display', 'descricao', 'imagem', 
            'doador', 'doador_nome', 'status', 'criado_em'
        ]

class CandidaturaSerializer(serializers.ModelSerializer):
    """Novo Serializer para o processo de candidatura com laudo"""
    candidato_nome = serializers.CharField(source='candidato.username', read_only=True)
    aparelho_nome = serializers.CharField(source='aparelho.nome', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Candidatura
        fields = [
            'id', 'aparelho', 'aparelho_nome', 'candidato', 
            'candidato_nome', 'laudo_exame', 'status', 
            'status_display', 'data_candidatura'
        ]
        # O candidato é preenchido automaticamente pela View, então deixamos apenas leitura
        read_only_fields = ['candidato', 'status']