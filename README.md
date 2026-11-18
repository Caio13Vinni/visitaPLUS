# VISITA+

Sistema de gestão de visitas domiciliares para unidades CRAS/CREAS.

Este repositório é o ponto central do projeto, contendo o backend e o frontend como submódulos.

---

## Visão Geral

O VISITA+ é um sistema completo para gestão de visitas domiciliares no contexto do SUAS (Sistema Único de Assistência Social). O projeto é dividido em duas partes principais: uma API robusta desenvolvida em Rust e um aplicativo mobile multiplataforma desenvolvido em Flutter.

O sistema atende dois perfis de usuários: coordenadores, que gerenciam equipes e visualizam agendamentos, e técnicos, que realizam visitas em campo e registram informações sobre as famílias acompanhadas.

---

## Estrutura do Repositório

```
visitaPLUS/
├── backend/     # API REST em Rust (submódulo)
├── frontend/    # App mobile em Flutter (submódulo)
└── README.md
```

---

## Arquitetura do Sistema

### Visão Macro

```
┌─────────────────────────┐         ┌──────────────────────────────┐
│  App Mobile (Flutter)   │  HTTP   │  Backend (Rust · axum)       │
│  Coordenador · Técnico  │ ◄─────► │  Clean Architecture          │
│  Operacao offline       │  REST   │  RN01-RN25 · UC01-UC12       │
└─────────────────────────┘         └──────────────┬───────────────┘
                                                   │
                                    ┌──────────────┴──────────────┐
                                    │ PostgreSQL (central online)  │
                                    │ SQLite (banco local mobile)  │
                                    └─────────────────────────────┘
```

### Comunicação

O frontend se comunica com o backend através de uma API REST. As requisições seguem o padrão HTTP com JSON, e as respostas utilizam um formato padronizado:

```json
{
  "sucesso": true,
  "dados": { },
  "erro": null
}
```

O sistema foi projetado para suportar operação offline. Quando não há conectividade, o app armazena dados localmente e sincroniza com o backend quando a conexão é restabelecida.

---

## Backend

### Tecnologias

- Rust
- axum (framework web)
- sqlx (acesso a banco de dados)
- PostgreSQL (banco central)
- SQLite (banco local para simulação mobile)
- Docker

### Arquitetura

O backend segue rigorosamente os princípios da Clean Architecture, dividindo o sistema em camadas bem definidas:

```
┌─────────────────────────────────────────┐
│  Interface (axum)                       │
│  HTTP handlers · DTOs · Estado          │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│  Casos de Uso                           │
│  UC01-UC12 · Orquestração de fluxos     │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│  Domínio                                │
│  Entidades · Enums · RN01-RN25          │
│  Sem dependências externas              │
└────────────────▲────────────────────────┘
                 │
┌────────────────┴────────────────────────┐
│  Infraestrutura                         │
│  PostgreSQL · SQLite · Repositórios     │
│  Segurança · Adaptadores                │
└─────────────────────────────────────────┘
```

### Princípios da Arquitetura

- O domínio não conhece axum, sqlx ou tokio
- Regras de negócio vivem exclusivamente no domínio
- Casos de uso orquestram fluxos sem conter lógica de negócio
- Infraestrutura implementa portas definidas pelo domínio
- Permite testar regras de negócio sem banco, sem HTTP, sem async

### Regras de Negócio

O backend implementa 25 regras de negócio (RN01-RN25) organizadas por domínio:

- RN01-RN05: Autenticação e sessões
- RN06-RN12: Gestão de famílias e visitas
- RN13-RN18: Encaminhamentos e solicitações de retorno
- RN19-RN22: Sincronização offline
- RN23-RN25: Auditoria e notificações

### Casos de Uso

Doze casos de uso (UC01-UC12) orquestram os fluxos principais:

- Autenticação de usuários
- Gestão de famílias
- Agendamento e registro de visitas
- Encaminhamentos entre serviços
- Notificações
- Sincronização de dados offline

### Banco de Dados

| Banco       | Papel                        | Quando usar                    |
|-------------|------------------------------|--------------------------------|
| PostgreSQL  | Banco central online         | Sempre que há conectividade    |
| SQLite      | Banco local (simula mobile)  | Operação offline em campo      |

### Modelo de Dados

```
unidade ──┬── usuario ──┬── sessao
          │             └── recuperacao_acesso
          │
          ├── familia ──┬── solicitacao_retorno
          │             ├── visita ──┬── registro_visita
          │             │            └── complemento_registro
          │             └── encaminhamento
          │
          ├── notificacao
          └── auditoria
```

---

## Frontend

### Tecnologias

- Flutter
- Dart
- Material 3

### Estrutura

```
lib/
├── main.dart            # Ponto de entrada e tema (Material 3)
└── screens/             # 26 telas, uma por arquivo (tela_*.dart)
assets/
└── images/logo.png      # Logo e ícone do app
android/ ios/ web/ windows/ macos/ linux/   # Runners de cada plataforma
```

### Perfis de Acesso

O app possui dois perfis com telas e funcionalidades distintas:

**Coordenador:**
- Visualizar agenda da equipe
- Agendar visitas
- Gerenciar equipe (cadastro e revisão de profissionais)
- Acessar famílias e históricos
- Visualizar perfil

**Técnico:**
- Visualizar própria agenda
- Registrar visitas em campo
- Acessar famílias e históricos
- Visualizar perfil

### Fluxos Principais

```
Abertura → Login ─┬─→ Coordenador ─┬─→ Agendar visita
                  │                ├─→ Agenda da equipe
                  │                ├─→ Equipe → Novo profissional → Revisar dados
                  │                ├─→ Famílias → Detalhes da família
                  │                └─→ Perfil
                  │
                  └─→ Técnico ─────┬─→ Agenda → Detalhe da visita → Informações da visita
                                   ├─→ Observações → Encaminhamentos → Resultado da visita
                                   ├─→ Histórico de visitas
                                   └─→ Famílias → Detalhes da família

Login → Recuperar senha → E-mail enviado → Nova senha → Senha alterada
```

### Funcionalidades

- Agendamento de visitas com validação de horário, local e tipo
- Registro guiado da visita: observações, condições do domicílio, participação da família e materiais entregues
- Encaminhamentos com tipo, motivo, prioridade, responsável e data sugerida
- Gestão de famílias com busca, detalhes e histórico de visitas com filtros
- Gestão da equipe com cadastro e revisão de profissionais
- Recuperação de senha com fluxo completo
- Multiplataforma: Android, iOS, Web, Windows, macOS e Linux

---

## Sincronização Offline

O sistema foi projetado para operação em campo onde a conectividade pode ser limitada ou inexistente. O fluxo de sincronização funciona da seguinte forma:

1. O técnico realiza visitas e registra dados normalmente, mesmo sem internet
2. Os dados são armazenados localmente no dispositivo
3. Quando a conexão é restabelecida, o app sincroniza automaticamente com o backend
4. O backend valida as regras de negócio e persiste os dados no PostgreSQL
5. Toda ação é auditada para garantir rastreabilidade

---

## Como Clonar

Para clonar este repositório junto com os submódulos:

```bash
git clone --recurse-submodules https://github.com/Caio13Vinni/visitaPLUS.git
cd visitaPLUS
```

Se você já clonou sem o flag `--recurse-submodules`:

```bash
git submodule update --init --recursive
```

---

## Como Executar

### Backend

Pré-requisitos: Rust estável e Docker + Docker Compose.

```bash
cd backend
cp .env.example .env
docker compose up -d --build
```

Para desenvolvimento local sem conteinerizar a API:

```bash
docker compose up -d postgres sqlite
cargo run
```

### Frontend

Pré-requisitos: Flutter estável.

```bash
cd frontend
flutter pub get
flutter run
```

Comandos úteis:

```bash
flutter run -d chrome        # Web
flutter run -d windows       # Windows
flutter build apk --release  # Android
flutter analyze              # Análise estática
```

---

## Contas de Demonstração

Login simulado no frontend, sem necessidade de backend:

| Perfil      | E-mail                  | Senha    |
|-------------|-------------------------|----------|
| Coordenador | coordenador@visita.com  | 123456   |
| Técnico     | tecnico@visita.com      | 123456   |

---

---

## Autores

- Caio Vinícius
- Davi Quirino Rocha
