# INEGI · UMEC — Gestão de Equipamento Informático

Aplicação de gestão de equipamento informático da UMEC, alojada no **GitHub Pages** com base de dados **Supabase**.

---

## Setup — passo a passo

### 1. Criar projeto Supabase

1. Aceder a [supabase.com](https://supabase.com) e criar uma conta (gratuito).
2. Criar um novo projeto (escolher região europeia, ex: `eu-central-1`).
3. Aguardar a inicialização (~2 min).

### 2. Migrar a tabela na base de dados partilhada

Esta app partilha a base de dados Supabase do projeto **team-planning**.  
A tabela `app_storage` já existe — o script de migração adiciona a coluna `app_id` e recria a chave primária como composta `(app_id, key)`, sem perder dados existentes.

1. No dashboard do projeto → **SQL Editor** → **New query**.
2. Colar o conteúdo do ficheiro [`supabase/schema.sql`](supabase/schema.sql).
3. Clicar em **Run**.

> **Nota:** Os dados do team-planning ficam com `app_id = 'team-planning'`; os dados desta app ficam com `app_id = 'equipment'`. Nenhuma colisão possível.

### 3. Obter as credenciais

1. No dashboard → **Settings** → **API**.
2. Copiar:
   - **Project URL** — ex: `https://abcdefgh.supabase.co`
   - **anon / public key** — começa com `eyJ...`

### 4. Configurar o index.html

Abrir `index.html` e editar as duas linhas na secção de configuração (perto do topo do ficheiro, dentro da primeira `<script>`):

```javascript
const SUPABASE_URL = 'https://SEU_PROJECT_ID.supabase.co';
const SUPABASE_ANON_KEY = 'eyJ...';
```

### 5. Criar o repositório GitHub e ativar Pages

1. Criar um novo repositório em [github.com](https://github.com) (pode ser privado ou público).
2. Fazer push de todos os ficheiros:

```bash
git init
git add .
git commit -m "initial commit"
git branch -M main
git remote add origin https://github.com/SEU_USER/SEU_REPO.git
git push -u origin main
```

3. No repositório → **Settings** → **Pages**:
   - Source: **GitHub Actions**
4. O workflow `.github/workflows/pages.yml` faz o deploy automaticamente a cada push para `main`.
5. Após o primeiro deploy, o URL aparece em **Settings → Pages** (ex: `https://SEU_USER.github.io/SEU_REPO/`).

### 6. (Opcional) Migrar dados do backup JSON

Se tiver um ficheiro de backup exportado pela versão anterior:

1. Abrir a aplicação no browser.
2. Clicar no ícone de **Backup** (topo direito).
3. Escolher **Importar** e selecionar o ficheiro `inegi_umec_backup_*.json`.

Os dados são escritos para o Supabase e ficam partilhados por todos os utilizadores.

---

## Estrutura do repositório

```
.
├── index.html                  # Aplicação (React, Babel — sem build step)
├── supabase/
│   └── schema.sql              # Schema da tabela app_storage
├── .github/
│   └── workflows/
│       └── pages.yml           # Deploy automático para GitHub Pages
└── README.md
```

---

## Notas de segurança

- A **anon key** do Supabase é pública por design — é seguro incluí-la no HTML.
- O acesso à tabela é controlado por **Row Level Security (RLS)**.
- Qualquer utilizador com acesso à página pode ler e escrever dados.
- Para restringir o acesso a utilizadores autenticados, configure **Supabase Auth** e ajuste as políticas RLS em `supabase/schema.sql`.
