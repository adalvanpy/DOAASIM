# DOAASIM - Sistema de Doação de Aparelhos Auditivos

## Descrição

Sistema para conectar doadores de aparelhos auditivos a candidatos necessitados, facilitando o processo de doação e tornando-o mais transparente e eficiente.

## Tecnologias

- **Backend:** Django + Django REST Framework (Docker)
- **Frontend:** Flutter (Dart)
- **Autenticação:** JWT (JSON Web Tokens)

## Pré-requisitos

- Docker e Docker Compose
- Flutter 3.16+
- Git

## Execução

### 1. Clone o repositório

```bash
git clone https://github.com/adalvanpy/DOAASIM.git
cd DOAASIM
2. Inicie o Backend
bash
docker-compose up -d
O backend estará disponível em: http://localhost:8000/admin/

3. Configure o Frontend para Mobile
Para executar o aplicativo em um dispositivo físico (celular/tablet):

Descubra o IPv4 da sua máquina:

bash
# Windows
ipconfig

# Linux/Mac
ifconfig
# ou
ip addr show
Altere o arquivo frontend/lib/core/constants/api_constants.dart:

dart
class ApiConstants {
  // Altere para o IPv4 da sua máquina (ex: 192.xxx.x.1)
  static const String baseUrl = 'http://192.168.1.xxx:8000/api';
  
  // Para emulador Android
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Para desenvolvimento web
  // static const String baseUrl = 'http://localhost:8000/api';
}
Execute o Frontend:

bash
cd frontend
flutter pub get
flutter run
⚠️ Importante: O celular e o computador devem estar na mesma rede Wi-Fi para o app funcionar corretamente.

Fluxo por Tipo de Usuário
🟢 Doador
Cadastra aparelhos auditivos para doação

Acompanha status do aparelho (Aguardando → Disponível → Doado)

Visualiza seus próprios aparelhos cadastrados

🔵 Candidato
Visualiza aparelhos disponíveis

Candidata-se a um aparelho enviando laudo médico

Acompanha status da candidatura (Aguardando → Aprovado/Reprovado → Escolhido)

Não pode se candidatar ao mesmo aparelho duas vezes

🟣 Empresa
Aprova ou reprova aparelhos cadastrados

Aprova ou reprova candidaturas

Escolhe o candidato final para receber o aparelho

Após escolha, aparelho é marcado como DOADO

Outras candidaturas são automaticamente reprovadas

Fluxo Completo
text
┌─────────────────────────────────────────────────────────────────┐
│                         AUTENTICAÇÃO                            │
│                                                                  │
│  Cadastro → Login → Recebe Token JWT → Acessa Rotas Protegidas  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      FLUXO DE DOAÇÃO                             │
│                                                                  │
│  Doador cadastra aparelho (AGUARDANDO)                          │
│                           ↓                                      │
│  Empresa aprova (DISPONIVEL)                                    │
│                           ↓                                      │
│  Candidato se candidata (AGUARDANDO)                            │
│                           ↓                                      │
│  Empresa aprova candidatura (APROVADO)                          │
│                           ↓                                      │
│  Empresa escolhe candidato final                                │
│                           ↓                                      │
│  Aparelho → DOADO / Candidato → ESCOLHIDO                       │
└─────────────────────────────────────────────────────────────────┘
Rotas Protegidas (Requerem Token)
Método	Endpoint	Descrição	Perfil
GET	/api/devices/	Listar aparelhos	Todos
POST	/api/devices/	Criar aparelho	DOADOR
GET	/api/devices/{id}/	Detalhar aparelho	Todos
PUT/PATCH	/api/devices/{id}/	Atualizar aparelho	DOADOR
DELETE	/api/devices/{id}/	Deletar aparelho	DOADOR
GET	/api/candidaturas/	Listar candidaturas	Autenticado
POST	/api/candidaturas/	Criar candidatura	CANDIDATO
PATCH	/api/devices/{id}/aprovar/	Aprovar aparelho	EMPRESA
PATCH	/api/devices/{id}/reprovar/	Reprovar aparelho	EMPRESA
PATCH	/api/candidaturas/{id}/aprovar/	Aprovar candidatura	EMPRESA
PATCH	/api/candidaturas/{id}/reprovar/	Reprovar candidatura	EMPRESA
PATCH	/api/candidaturas/{id}/escolher/	Escolher candidato	EMPRESA
Como usar
Abra o aplicativo no celular ou emulador

Clique em "Não tem conta? Cadastre-se"

Escolha o tipo de usuário (Doador/Candidato/Empresa)

Preencha os dados e cadastre

Faça login com suas credenciais

Utilize as funcionalidades conforme seu perfil

Comandos Úteis
bash
# Parar os containers
docker-compose down

# Ver logs do backend
docker-compose logs -f backend

# Reconstruir containers
docker-compose up --build -d

# Executar migrações
docker-compose exec backend python manage.py migrate
Vídeo Demonstrativo
https://youtu.be/2roCcQ8OHPI

Grupo
Nome	Papel
ADALVAN LIMA DOS ANJOS	Desenvolvedor Full Stack
Repositório
https://github.com/adalvanpy/DOAASIM.git

Licença
MIT License

© 2026 DOAASIM - Todos os direitos reservados



