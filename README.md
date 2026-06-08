# DOAASIM - Sistema de Doação de Aparelhos Auditivos

## Descrição

Sistema para conectar doadores de aparelhos auditivos a candidatos necessitados.

## Tecnologias

- **Backend:** Django + Django REST Framework (Docker)
- **Frontend:** Flutter (Dart)

## Pré-requisitos

- Docker e Docker Compose
- Flutter 3.16+

## Execução

### 1. Clone o repositório

```bash
git clone https://github.com/adalvanpy/DOAASIM.git
cd DOAASIM
```
2. Inicie o Backend
bash
docker-compose up -d
O backend estará disponível em: http://localhost:8000

3. Execute o Frontend
bash
cd frontend
flutter pub get
flutter run
Fluxo por Tipo de Usuário
🟢 Doador
Cadastra aparelhos auditivos para doação

Acompanha status do aparelho (Aguardando → Disponível → Doado)

🔵 Candidato
Visualiza aparelhos disponíveis

Candidata-se a um aparelho enviando laudo médico

Acompanha status da candidatura (Aguardando → Aprovado/Reprovado -> Escolhido)

🟣 Empresa
Aprova ou reprova aparelhos cadastrados

Aprova ou reprova candidaturas

Escolhe o candidato final para receber o aparelho

Após escolha, aparelho é marcado como DOADO

Fluxo Completo
┌─────────────────────────────────────────────────────────────────┐
│                         AUTENTICAÇÃO                            │
│                                                                  │
│  Cadastro → Login → Recebe Token → Acessa Rotas Protegidas      │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      FLUXO DE DOAÇÃO                             │
│                                                                  │
│  Doador cadastra aparelho → Empresa aprova → DISPONIVEL          │
│                                                      ↓           │
│  Candidato se candidata → Empresa aprova → APROVADO              │
│                                                      ↓           │
│  Empresa escolhe candidato → Aparelho DOADO / Candidato ESCOLHIDO│
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    ROTAS PROTEGIDAS (Requerem Token)             │
│                                                                  │
│  GET    /api/devices/         - Listar aparelhos                 │
│  POST   /api/devices/         - Criar aparelho (DOADOR)          │
│  PATCH  /api/devices/{id}/    - Atualizar aparelho               │
│  DELETE /api/devices/{id}/    - Deletar aparelho                 │
│  GET    /api/candidaturas/    - Listar candidaturas              │
│  POST   /api/candidaturas/    - Criar candidatura (CANDIDATO)    │
│  PATCH  /api/devices/{id}/aprovar/   - Aprovar aparelho (EMPRESA)│
│  PATCH  /api/candidaturas/{id}/escolher/ - Escolher (EMPRESA)    │
└─────────────────────────────────────────────────────────────────┘
Como usar
Abra o aplicativo

Clique em "Não tem conta? Cadastre-se"

Escolha o tipo de usuário (Doador/Candidato/Empresa)

Faça login

Utilize as funcionalidades conforme seu perfil

Parar os containers
bash
docker-compose down
Vídeo Demonstrativo
[Link do vídeo - até 10 minutos]

Grupo
ADALVAN LIMA DOS ANJOS


Repositório
https://github.com/adalvanpy/DOAASIM.git



