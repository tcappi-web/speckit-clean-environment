# Checklist de Segurança — [FEATURE / DEPLOY]

**Preset:** `clean-environment-seguranca-core`
**Spec/Plan:** [link]
**Data:** [DATE]
**Responsável:** [@nome]
**Tipo:** [ ] Por feature   [ ] Pré-deploy   [ ] Auditoria pontual

> Este checklist é uma versão estendida do `CHECKLIST-RAPIDO.md` da empresa, agora versionado
> dentro do fluxo Spec Kit. Use os 12 grupos abaixo. Cada item descobre violações constitucionais
> que devem ser corrigidas ou registradas em `Complexity Tracking` do `plan.md`.

---

## 1. Início do projeto

- [ ] `.gitignore` criado ANTES do primeiro commit
- [ ] `.env.example` commitado (sem valores reais)
- [ ] `.env.local` em `.gitignore`
- [ ] `git-secrets` instalado e configurado
- [ ] Pre-commit hooks configurados (husky/equivalente)
- [ ] `.specify/memory/security-context.md` preenchido via `/speckit.security-context`
- [ ] `/speckit.security-setup` executado

---

## 2. Autenticação (Constituição Art. I)

- [ ] Token de sessão em HttpOnly cookie — **nunca** localStorage
- [ ] Cookie com `Secure` + `SameSite=Strict` (ou `Lax` justificado)
- [ ] Senha com bcrypt cost ≥ 12 ou argon2id (não MD5/SHA1/SHA256 puro)
- [ ] Rate limit: máx 5 tentativas / 15 min por (IP, identificador)
- [ ] JWT com expiração curta (≤ 15 min) + refresh com rotação
- [ ] Logout invalida token no backend (blacklist/revoke list)
- [ ] Mesma mensagem para "email inválido" e "senha incorreta"
- [ ] 2FA obrigatório para criticidade ≥ ALTA ou perfis admin
- [ ] Password reset via token de uso único com expiração

---

## 3. Autorização (Constituição Cláusula I.5)

- [ ] Middleware `authenticate()` em rotas protegidas
- [ ] Verificação explícita `req.user.id === resource.userId`
- [ ] UUIDs/ULIDs em vez de IDs sequenciais expostos
- [ ] Verificação de role/permissão além de autenticação
- [ ] Multi-tenancy isolado (se aplicável)
- [ ] Endpoints admin com proteção adicional
- [ ] Permissões granulares por recurso (não global)

---

## 4. Validação de input (Constituição Art. II)

- [ ] Schema validation (Zod/Joi/Pydantic) no backend obrigatório
- [ ] Validação frontend para UX (não como camada de segurança)
- [ ] Limites de tamanho em strings, arrays, profundidade JSON
- [ ] Whitelist sobre blacklist quando aplicável
- [ ] Type coercion seguro
- [ ] Sanitização baseada em contexto (HTML, URL, JS, shell)
- [ ] Parametrized queries em 100% das interações com banco

---

## 5. Frontend

- [ ] Sem `dangerouslySetInnerHTML` para input de usuário (ou com DOMPurify documentado)
- [ ] Sem `localStorage`/`sessionStorage` para tokens/dados sensíveis
- [ ] Sem URLs/credenciais hardcoded
- [ ] Sem `console.log` em build de produção
- [ ] Source maps **desligados** em produção
- [ ] Variáveis `VITE_/NEXT_PUBLIC_` não contêm secrets (auditar nome a nome)
- [ ] CSP header configurado (`Content-Security-Policy`)
- [ ] HTTPS forçado em todas as rotas

---

## 6. API / Backend (Constituição Art. III)

- [ ] Rate limiting configurado por tier (auth/público/user-scoped)
- [ ] CORS com whitelist explícita (`Access-Control-Allow-Origin`)
- [ ] Headers de segurança presentes em toda resposta:
  - [ ] `Strict-Transport-Security`
  - [ ] `X-Frame-Options: DENY` (ou `CSP: frame-ancestors`)
  - [ ] `X-Content-Type-Options: nosniff`
  - [ ] `Content-Security-Policy`
  - [ ] `Referrer-Policy: strict-origin-when-cross-origin`
- [ ] Erros opacos para cliente (sem stack trace)
- [ ] Logs estruturados sem PII (Cláusula III.2)
- [ ] Paginação obrigatória em listas
- [ ] Timeouts configurados em I/O externo

---

## 7. Uploads (Cláusula II.6)

- [ ] Whitelist de MIME types permitidos
- [ ] Validação por **magic bytes** (não confiar em extensão/Content-Type)
- [ ] Tamanho máximo aplicado
- [ ] Nome em disco aleatório (UUID)
- [ ] Diretório de upload sem permissão de execução
- [ ] Path traversal prevention
- [ ] Storage isolado por usuário/tenant
- [ ] URLs assinadas com expiração
- [ ] Antivírus se possível (ClamAV)

---

## 8. Banco de dados (Cláusula III.7)

- [ ] Conta de aplicação com permissões mínimas (não root/postgres/sa)
- [ ] Conexão sob TLS em produção
- [ ] Credenciais em env vars
- [ ] Parametrized queries em 100% das chamadas
- [ ] Senhas hash com bcrypt/argon2id
- [ ] PII criptografada at-rest quando requerido
- [ ] Backups criptografados
- [ ] Audit log de mudanças sensíveis
- [ ] Soft delete onde aplicável (Cláusula III.8)

---

## 9. Secrets (Cláusula V.5)

- [ ] Nenhum hardcoded em código
- [ ] Nenhum em variáveis `VITE_/NEXT_PUBLIC_`
- [ ] `.env` nunca commitado (verificar git history)
- [ ] Secrets manager em produção (não env var em texto plano em CI)
- [ ] Rotação periódica documentada
- [ ] `git-secrets` ativo
- [ ] Pre-commit hook bloqueando padrões

---

## 10. Deploy / Infraestrutura

- [ ] HTTPS forçado (HSTS)
- [ ] Secrets em GitHub Actions / cloud secret manager
- [ ] Container sem privilégios excessivos (sem `--privileged`, usuário não-root)
- [ ] Firewall configurado
- [ ] Backups automatizados e testados
- [ ] Monitoring ativo (Sentry/Datadog/equivalente)
- [ ] Alertas configurados (latência, erros, security events)
- [ ] Plano de rollback documentado
- [ ] Logs centralizados

---

## 11. Dependências (Cláusula V.6)

- [ ] `npm audit` (ou equivalente) com zero CRÍTICAS, zero ALTAS
- [ ] Renovate/Dependabot ativo
- [ ] Lockfile commitado (`package-lock.json`/`poetry.lock`/`go.sum`)
- [ ] Sem pacotes abandonados ou deprecated
- [ ] Pacotes verificados (publicador conhecido, não typo-squatting)

---

## 12. LGPD / GDPR / Outras (Constituição Art. IV)

> Aplicar conforme `security-context.compliance.*`. Se não ativos, marcar N/A.

- [ ] Política de privacidade atualizada
- [ ] Termos de uso atualizados
- [ ] Consentimento explícito (banner de cookies, opt-in onde requerido)
- [ ] Direito ao esquecimento implementado (endpoint ou processo)
- [ ] Portabilidade implementada (exportação de dados)
- [ ] Audit log de operações sobre dados pessoais
- [ ] DPO contactável e referenciado em `security-context.md`
- [ ] Plano de notificação de incidente (72h ANPD/autoridade)
- [ ] Minimização de dados aplicada
- [ ] [Se PCI-DSS] PAN/CVV nunca armazenados; tokenização ativa
- [ ] [Se HIPAA] Criptografia at-rest/in-transit + BAAs assinados

---

## ⚡ Pré-commit (toda vez)

```bash
[ ] ./scripts/security-check.sh
[ ] npm run lint
[ ] npm test
[ ] Revisão manual do diff
[ ] Sem console.log esquecido
[ ] Sem TODO de segurança pendente
```

---

## 🚀 Pré-deploy (antes de produção)

- [ ] `/speckit.security-audit` rodou em modo full, achados CRÍTICOS = 0
- [ ] Todos os Compliance Gates do `plan.md` aprovados
- [ ] Variáveis de ambiente de produção configuradas
- [ ] Secrets de produção rotacionados (≠ dev/staging)
- [ ] Backup recente testado (restore real)
- [ ] Plano de rollback documentado e validado
- [ ] Monitoring + alertas funcionando
- [ ] DNS/CDN configurado
- [ ] HTTPS verificado em todas as rotas
- [ ] Headers de segurança verificados via curl/Mozilla Observatory
- [ ] Performance e load tests aprovados
- [ ] Documentação atualizada
- [ ] Sign-off de Security Champion (Cláusula V.4)

---

## 🎯 Score

| Faixa | Significado |
| --- | --- |
| 100% | Pronto para produção |
| 90-99% | Pendências menores documentadas em `Complexity Tracking` |
| 70-89% | **Bloqueado.** Corrigir antes de produção |
| < 70% | Refatoração de segurança necessária |

---

## 🆘 Em caso de incidente (referência rápida)

1. **Conter:** tirar serviço do ar se necessário; rotacionar credenciais comprometidas; bloquear IPs.
2. **Investigar:** coletar logs; identificar escopo, vetor, timeline.
3. **Remediar:** patch; deploy de correção; verificar ausência de persistência.
4. **Comunicar:** time interno; usuários afetados; ANPD em até 72h se LGPD aplicável.
5. **Aprender:** post-mortem; atualizar checklist e knowledge base; testes de regressão.

---

**Validação final do checklist:**

- [ ] Todos os itens N/A justificados na `Complexity Tracking` do `plan.md`
- [ ] Todos os itens NÃO marcados têm task `[SEC]` correspondente no `tasks.md`
- [ ] Checklist anexado à PR de release
