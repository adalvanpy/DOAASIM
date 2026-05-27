from django.db import models
from django.db import models
from django.contrib.auth.models import User

class Perfil(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='perfil')
    TIPO_USUARIO = [
        ('EMPRESA', 'Empresa'),
        ('DOADOR', 'Doador'),
        ('CANDIDATO', 'Candidato'),
    ]
    tipo = models.CharField(max_length=20, choices=TIPO_USUARIO)
    cpf_cnpj = models.CharField(max_length=20, unique=True)

    def __str__(self):
        return f"{self.user.username} ({self.tipo})"

class Aparelho(models.Model):
    MODELO_ANATOMICO_CHOICES = [
        ('RETRO', 'Retroauricular (BTE)'),
        ('INTRA', 'Intra-auricular (ITE/CIC)'),
        ('RIC', 'Receptor no Canal (RIC)'),
    ]

    NIVEL_PERDA_CHOICES = [
        ('LEVE', 'Leve'),
        ('LEVE_MODERADA', 'Leve a Moderada'),
        ('MODERADA', 'Moderada'),
        ('MODERADA_SEVERA', 'Moderada a Severa'),
        ('SEVERA', 'Severa'),
        ('SEVERA_PROFUNDA', 'Severa a Profunda'),
        ('PROFUNDA', 'Profunda'),
    ]

    nome = models.CharField(max_length=100)
    marca = models.CharField(max_length=50, blank=True, null=True)
    
    modelo_anatomico = models.CharField(max_length=10, choices=MODELO_ANATOMICO_CHOICES)
    perda_indicada = models.CharField(max_length=20, choices=NIVEL_PERDA_CHOICES)
    
    descricao = models.TextField()
    imagem = models.ImageField(upload_to='aparelhos/', null=True, blank=True)
    
    doador = models.ForeignKey(User, on_delete=models.CASCADE, related_name='doacoes')
    candidato = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='pedidos')
    
    status = models.CharField(max_length=20, default='DISPONIVEL')
    criado_em = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.nome} - {self.get_perda_indicada_display()}"
    
class Candidatura(models.Model):
    STATUS_CHOICES = [
        ('AGUARDANDO', 'Aguardando Análise'),
        ('APROVADO', 'Aprovado (Compatível)'),
        ('REPROVADO', 'Não Compatível'),
    ]

    aparelho = models.ForeignKey(Aparelho, on_delete=models.CASCADE, related_name='candidaturas')
    candidato = models.ForeignKey(User, on_delete=models.CASCADE)
    
    # O arquivo do laudo médico/audiometria
    laudo_exame = models.FileField(upload_to='laudos/', help_text="Anexe sua audiometria em PDF ou Imagem")
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='AGUARDANDO')
    data_candidatura = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.candidato.username} -> {self.aparelho.nome}"
