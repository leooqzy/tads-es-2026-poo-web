# FF Rental

**Marketplace para anúncios e aluguel de contas de Free Fire.**

## Informações do projeto

- **Aluno:** Leonardo Lemes Passos
- **Curso:** Tecnologia em Análise e Desenvolvimento de Sistemas (TADS)
- **Disciplina:** Programação para Dispositivos Móveis / Paradigmas de Linguagem de Programação / Programação Orientada a Objetos para Web
- **Back-end:** Opção A — API Laravel
- **Front-end:** Flutter / Dart
- **Banco de dados:** MySQL

## Sobre o projeto

O FF Rental é um aplicativo desenvolvido em Flutter, integrado a uma API Laravel, com o objetivo de permitir o cadastro, a consulta e o gerenciamento de anúncios de contas de Free Fire.

O sistema possui três tipos de usuários:

- **Administrador:** possui acesso ao painel administrativo e aos indicadores do sistema.
- **Vendedor:** pode publicar e gerenciar seus próprios anúncios.
- **Comprador:** pode consultar os anúncios disponíveis no catálogo.

Cada anúncio de conta deve possuir duas imagens obrigatórias: uma imagem da conta e outra do inventário, permitindo que os interessados visualizem as informações do anúncio.

## Funcionalidades

### Autenticação
- Cadastro de usuários.
- Login.
- Controle de acesso por perfil.
- Persistência da sessão do usuário.

### Anúncios
- Cadastro de anúncios.
- Listagem dos próprios anúncios.
- Consulta do catálogo.
- Edição de anúncios.
- Exclusão de anúncios.
- Envio obrigatório da imagem da conta e da imagem do inventário.
- Armazenamento das imagens no back-end.

### Painéis
- Painel do vendedor com seus anúncios.
- Painel administrativo com indicadores de usuários, anúncios, categorias, pedidos e avaliações.

## Tecnologias utilizadas

### Aplicativo
- Flutter
- Dart
- Dio
- GoRouter
- Flutter Secure Storage
- Image Picker

### Back-end
- PHP
- Laravel
- Laravel Sanctum
- MySQL
- Docker

## Arquitetura do projeto

O aplicativo utiliza arquitetura em camadas, separando as responsabilidades de cada parte do sistema.

```text
apps/ff_rental/lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── routes/
│   ├── theme/
│   └── utils/
├── models/
├── repositories/
├── services/
└── screens/
    ├── auth/
    └── home/
```

### Responsabilidades das camadas

- **Models:** representam as entidades e realizam a conversão dos dados JSON.
- **Repositories:** realizam as operações de comunicação com a API.
- **Services:** centralizam as regras e intermediam as operações entre as telas e os repositories.
- **Screens:** apresentam as interfaces e recebem as interações dos usuários.
- **Core:** concentra constantes, rotas, temas e utilitários.

O fluxo de comunicação segue a seguinte estrutura:

```text
Screen
  ↓
Service
  ↓
Repository
  ↓
API Laravel
  ↓
Banco de dados MySQL
```

## Telas e rotas

| Tela | Rota |
|---|---|
| Login | `/login` |
| Cadastro | `/register` |
| Painel administrativo | `/admin` |
| Painel do vendedor | `/seller` |
| Catálogo de anúncios | `/catalog` |
| Cadastro de anúncio | Formulário acessado pelo painel do vendedor |

A navegação é realizada utilizando o pacote GoRouter, com rotas nomeadas.

## Execução do projeto

### Requisitos

- Flutter SDK instalado.
- Dart SDK.
- Docker Desktop.
- Git.
- Navegador Google Chrome para execução Web.

### 1. Iniciar o back-end

Na raiz do repositório, execute:

```bash
docker compose up -d
```

Verifique os containers:

```bash
docker ps
```

### 2. Executar as migrations

```bash
docker exec -it poo_web_php php artisan migrate
```

### 3. Configurar o armazenamento das imagens

```bash
docker exec -it poo_web_php php artisan storage:link
```

### 4. Executar o aplicativo Flutter

Acesse a pasta do aplicativo:

```bash
cd apps/ff_rental
```

Instale as dependências:

```bash
flutter pub get
```

Execute no navegador:

```bash
flutter run -d chrome
```

### 5. Endereço da API

O aplicativo utiliza a API Laravel disponibilizada localmente em:

```text
http://localhost:8182/api
```

A configuração da URL encontra-se em:

```text
lib/core/constants/api_constants.dart
```

## Verificação de qualidade

Para formatar os arquivos:

```bash
dart format .
```

Para analisar o código:

```bash
flutter analyze
```

Para executar os testes:

```bash
flutter test
```

## Capturas de tela

As capturas abaixo devem representar as telas reais do aplicativo:

- Tela de login.
- Tela de cadastro.
- Catálogo de anúncios.
- Painel do vendedor.
- Formulário de publicação de anúncio.
- Painel administrativo.

As imagens podem ser organizadas em uma pasta `docs/prints/` na raiz do projeto.

## Considerações finais

O FF Rental foi desenvolvido como projeto acadêmico com o objetivo de aplicar os conhecimentos de desenvolvimento mobile, programação orientada a objetos, integração com APIs REST e arquitetura em camadas.

O projeto utiliza Flutter no aplicativo mobile e Laravel no back-end, com persistência dos dados em banco de dados MySQL.