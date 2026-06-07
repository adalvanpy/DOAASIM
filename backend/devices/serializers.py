from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Aparelho, Perfil, Candidatura


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email']


class ProfileSerializer(serializers.ModelSerializer):
    user_details = UserSerializer(source='user', read_only=True)
    tipo_display = serializers.CharField(
        source='get_tipo_display',
        read_only=True
    )

    class Meta:
        model = Perfil
        fields = [
            'id',
            'user',
            'user_details',
            'tipo',
            'tipo_display',
            'cpf_cnpj'
        ]


class RegisterSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=150)
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True, min_length=6)
    tipo = serializers.ChoiceField(choices=Perfil.TIPO_USUARIO)
    cpf_cnpj = serializers.CharField(max_length=20)

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError(
                'Este nome de usuário já está em uso.'
            )
        return value

    def validate_cpf_cnpj(self, value):
        if Perfil.objects.filter(cpf_cnpj=value).exists():
            raise serializers.ValidationError(
                'Este CPF/CNPJ já está cadastrado.'
            )
        return value

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password']
        )

        perfil = Perfil.objects.create(
            user=user,
            tipo=validated_data['tipo'],
            cpf_cnpj=validated_data['cpf_cnpj']
        )

        return perfil

    def to_representation(self, instance):
        return ProfileSerializer(instance).data


class DeviceSerializer(serializers.ModelSerializer):

    modelo_display = serializers.CharField(
        source='get_modelo_anatomico_display',
        read_only=True
    )

    perda_display = serializers.CharField(
        source='get_perda_indicada_display',
        read_only=True
    )

    doador_nome = serializers.CharField(
        source='doador.username',
        read_only=True
    )

    class Meta:
        model = Aparelho
        fields = [
            'id',
            'nome',
            'marca',
            'modelo_anatomico',
            'modelo_display',
            'perda_indicada',
            'perda_display',
            'descricao',
            'imagem',
            'doador',
            'doador_nome',
            'status',
            'criado_em'
        ]

        read_only_fields = [
            'doador',
            'criado_em'
            
        ]

    def validate(self, attrs):
        user = self.context['request'].user
        request_method = self.context['request'].method
        
       
        if request_method == 'POST':
            if user.perfil.tipo != 'DOADOR':
                raise serializers.ValidationError(
                    'Somente usuários DOADOR podem cadastrar aparelhos.'
                )
        
       
        if request_method in ['PUT', 'PATCH']:
            if 'status' in attrs and user.perfil.tipo != 'EMPRESA':
                raise serializers.ValidationError(
                    'Apenas EMPRESAS podem alterar o status do aparelho.'
                )

        return attrs


class CandidaturaSerializer(serializers.ModelSerializer):

    candidato_nome = serializers.CharField(
        source='candidato.username',
        read_only=True
    )

    aparelho_nome = serializers.CharField(
        source='aparelho.nome',
        read_only=True
    )

    status_display = serializers.CharField(
        source='get_status_display',
        read_only=True
    )

    class Meta:
        model = Candidatura
        fields = [
            'id',
            'aparelho',
            'aparelho_nome',
            'candidato',
            'candidato_nome',
            'laudo_exame',
            'status',
            'status_display',
            'data_candidatura'
        ]

        read_only_fields = [
            'candidato',
            'status',
            'data_candidatura'
        ]

    def validate(self, attrs):
        user = self.context['request'].user
        request_method = self.context['request'].method
        
      
        if request_method == 'POST':
            if user.perfil.tipo != 'CANDIDATO':
                raise serializers.ValidationError(
                    'Somente usuários CANDIDATO podem se candidatar.'
                )
            
           
            aparelho = attrs.get('aparelho')
            if aparelho and aparelho.status != 'DISPONIVEL':
                raise serializers.ValidationError(
                    'Este aparelho não está disponível para candidatura.'
                )
        
       
        if request_method in ['PUT', 'PATCH']:
            if 'status' in attrs and user.perfil.tipo != 'EMPRESA':
                raise serializers.ValidationError(
                    'Apenas EMPRESAS podem alterar o status da candidatura.'
                )

        return attrs