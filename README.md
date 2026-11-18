<div align="center">

<img src="assets/images/logo.png" alt="Logo do VISITA+" width="120" />

<h1>VISITA+</h1>

**Sistema de gestão de visitas domiciliares para unidades CRAS/CREAS.**

App mobile em **Flutter** para coordenadores e técnicos, e backend em **Rust** com **Clean Architecture**, **operação offline** com sincronização posterior e **auditoria completa** de ações.

**[Backend](https://github.com/Caio13Vinni/visita-plus-backend)** · **App (este repositório)** · **Português (Brasil)**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Rust](https://img.shields.io/badge/Rust-000000?logo=rust&logoColor=white)](https://www.rust-lang.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![SQLite](https://img.shields.io/badge/SQLite-003B57?logo=sqlite&logoColor=white)](https://www.sqlite.org)
[![Clean Architecture](https://img.shields.io/badge/Clean_Architecture-142A40)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
</div>

---

## Por quê

Visitas domiciliares são o coração do trabalho das equipes técnicas do **SUAS** (Sistema Único de Assistência Social). Cada família acompanhada gera um volume enorme de registros: fichas de visita, observações sobre o domicílio, materiais entregues, encaminhamentos, solicitações de retorno.

Hoje, boa parte desse processo ainda é feita em papel ou em planilhas improvisadas. O resultado é previsível:

- **Registros perdidos ou incompletos**: papel danifica, planilha se corrompe
- **Nenhuma rastreabilidade**: quem alterou o quê, quando e por quê?
- **Regras de negócio na cabeça do técnico**: cada unidade faz do seu jeito
- **Agenda sem visibilidade**: o coordenador não enxerga o que a equipe tem para hoje
- **Impossibilidade de trabalho offline**: o campo muitas vezes não tem sinal

O VISITA+ resolve isso em duas frentes: um **app** com telas pensadas para cada perfil, e um **backend** que codifica as regras de negócio no domínio, audita toda ação e suporta sincronização offline.

## Visão geral do sistema

```
┌─────────────────────────┐        ┌──────────────────────────────┐
│  App mobile (Flutter)   │  HTTP  │  Backend (Rust · axum)       │
│  Coordenador · Técnico  │ ◄────► │  Clean Architecture          │
│  Este repositório       │  REST  │  RN01-RN25 · UC01-UC12       │
└─────────────────────────┘        └───────────────┬──────────────┘
                                                   │
                                    ┌──────────────┴──────────────┐
                                    │ PostgreSQL (central online)  │
                                    │ SQLite (simula banco mobile) │
                                    └──────────────────────────────┘
```

| Componente | Tecnologia | Repositório |
|---|---|---|
| **App mobile** | Flutter, Material 3 | este repositório |
| **Backend / API** | Rust, axum, sqlx | [visita-plus-backend](https://github.com/Caio13Vinni/visita-plus-backend) |

> **Estado da integração:** hoje o app roda com dados fictícios e login simulado, e ainda não consome a API do backend. A integração está no [roadmap](#roadmap).

## Características

### App mobile

- **Dois perfis de acesso.** Coordenador e técnico entram pelo mesmo login e caem em telas iniciais diferentes.
- **Agenda.** Coordenador vê a agenda da equipe; técnico vê a própria agenda e a próxima visita atribuída.
- **Agendamento de visitas.** Família, data, horário de início e término, local (unidade do CRAS ou outro) e tipo (domiciliar ou na unidade), com validação de horário.
- **Registro guiado da visita.** Observações, condições do domicílio (adequadas, parcialmente adequadas, inadequadas), participação da família (ativa, parcial, baixa) e materiais e orientações entregues.
- **Encaminhamentos.** Tipo (assistência social, CRAS, CREAS, Conselho Tutelar, outro), motivo, prioridade, responsável e data sugerida, ou finalização sem encaminhamento.
- **Famílias e histórico.** Busca, detalhes da família e histórico de visitas com filtros por período e tipo.
- **Gestão da equipe.** Lista de profissionais com busca e cadastro de novo profissional com etapa de revisão.
- **Recuperação de senha.** Fluxo completo: e-mail, confirmação de envio, nova senha e confirmação.
- **Multiplataforma.** Suporte gerado para Android, iOS, Web, Windows, macOS e Linux.

### Backend

- **Clean Architecture estrita.** Domínio puro, sem dependências de framework ou banco. Casos de uso orquestram fluxos. Infraestrutura implementa portas.
- **Duplo banco de dados.** PostgreSQL como banco central online; SQLite simulando o banco local mobile para o mecanismo de sincronização offline.
- **12 tabelas no MER.** Unidades, usuários, sessões, famílias, visitas, registros, encaminhamentos, notificações e auditoria.
- **25 regras de negócio** (RN01-RN25) validadas no domínio, não no controller nem no banco.
- **12 casos de uso** (UC01-UC12): autenticação, famílias, visitas, encaminhamentos, notificações e sincronização.
- **Migrações automáticas.** SQL em `migrations/` aplicadas na subida da aplicação.
- **API REST documentada.** Endpoints, payloads, enums e códigos de erro no `API.md` do backend.
- **Auditoria nativa.** Toda ação sensível gera registro na tabela `auditoria`.

## Arquitetura

### Backend

```
┌──────────── interface (axum) ────────────┐
│  HTTP handlers · DTOs · Estado compartilhado │
└────────────────┬───────────────────────────┘
                 │
┌──────────── casos_de_uso ─────────────────┐
│  UC01-UC12 · Orquestração de fluxos        │
└────────────────┬───────────────────────────┘
                 │
┌──────────── dominio ──────────────────────┐
│  Entidades · Enums · RN01-RN25             │
│  Sem dependências externas                 │
└────────────────────────────────────────────┘
                 ▲
┌──────────── infraestrutura ───────────────┐
│  PostgreSQL · SQLite · Repositórios        │
│  Segurança · Adaptadores técnicos          │
└────────────────────────────────────────────┘
```

A regra é simples: **o domínio não conhece axum, sqlx ou tokio**. Isso permite testar regras de negócio sem banco, sem HTTP, sem async.

### App

```
lib/
├── main.dart            # Ponto de entrada e tema (Material 3)
└── screens/             # 26 telas, uma por arquivo (tela_*.dart)
assets/
└── images/logo.png      # Logo, também usada como ícone do app
android/ ios/ web/ windows/ macos/ linux/   # Runners de cada plataforma
```

Fluxos principais:

```
Abertura ─► Login ─┬─► Coordenador ─┬─► Agendar visita
                   │                ├─► Agenda da equipe
                   │                ├─► Equipe ─► Novo profissional ─► Revisar dados
                   │                ├─► Famílias ─► Detalhes da família
                   │                └─► Perfil
                   │
                   └─► Técnico ─────┬─► Agenda ─► Detalhe da visita ─► Informações da visita
                                    ├─► Observações ─► Encaminhamentos ─► Resultado da visita
                                    ├─► Histórico de visitas
                                    └─► Famílias ─► Detalhes da família

Login ─► Recuperar senha ─► E-mail enviado ─► Nova senha ─► Senha alterada
```

## Banco de dados

| Banco | Papel | Quando usar |
|---|---|---|
| **PostgreSQL** | Banco central online | Sempre que há conectividade, com o esquema completo do MER |
| **SQLite** | Simulação do banco local mobile | Operação offline em campo, sincronização posterior |

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

## Regras de negócio

As **25 regras** (RN01-RN25) vivem em `src/dominio/` no backend:

- RN01-RN05: Autenticação e sessões
- RN06-RN12: Gestão de famílias e visitas
- RN13-RN18: Encaminhamentos e solicitações de retorno
- RN19-RN22: Sincronização offline
- RN23-RN25: Auditoria e notificações

## Começando

### App (este repositório)

**Pré-requisitos:** [Flutter](https://docs.flutter.dev/get-started/install) estável (Dart `^3.13.5`) e um emulador, dispositivo físico ou navegador.

```bash
git clone https://github.com/Davi-Quirino-Rocha/Visita-.git
cd Visita-

flutter pub get
flutter run
```

```bash
flutter run -d chrome      # Web
flutter run -d windows     # Windows (ou macos / linux)
flutter build apk --release
flutter analyze
```

Contas de demonstração (login simulado, sem backend):

| Perfil | E-mail | Senha |
|---|---|---|
| Coordenador | `coordenador@visita.com` | `123456` |
| Técnico | `tecnico@visita.com` | `123456` |

### Backend

**Pré-requisitos:** Rust estável e Docker + Docker Compose.

```bash
git clone https://github.com/Caio13Vinni/visita-plus-backend.git
cd visita-plus-backend

cp .env.example .env   # ajuste as credenciais se necessário
docker compose up -d --build
```

Para desenvolver sem conteinerizar a API:

```bash
docker compose up -d postgres sqlite
cargo run
```

O contrato completo da API (endpoints, payloads, enums e erros) está no [`API.md`](https://github.com/Caio13Vinni/visita-plus-backend/blob/main/API.md) do backend. As respostas seguem um formato padronizado:

```json
{
  "sucesso": true,
  "dados": { ... },
  "erro": null
}
```

## Contribuindo

Contribuições são bem-vindas: código, interface, documentação, revisão de regras de negócio.

1. Faça um fork e crie uma branch `feature/nome-da-mudanca`
2. Implemente a mudança (no app, mantenha o padrão `tela_*.dart`)
3. Rode `flutter analyze` (app) ou `cargo test` (backend)
4. Abra um Pull Request descrevendo o que mudou, com capturas de tela se mexer na interface

## Licença

- **Backend:** [MIT](https://github.com/Caio13Vinni/visita-plus-backend/blob/main/LICENSE) © Caio Vinícius e contribuidores.
- **App:** a definir. Enquanto não houver um arquivo `LICENSE` neste repositório, todos os direitos permanecem com o autor.

© Davi Quirino Rocha, Caio Vinícius e contribuidores do VISITA+.
