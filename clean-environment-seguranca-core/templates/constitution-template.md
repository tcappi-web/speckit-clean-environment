# Clean Environment — Constituição de Segurança de Software

**Projeto:** [PROJECT_NAME]
**Tipo:** [PROJECT_TYPE]
**Compliance ativo:** [COMPLIANCE_LIST — lido de `.specify/memory/security-context.md`]
**Criticidade:** [CRITICALITY]
**Versão da Constitution:** [CONSTITUTION_VERSION]
**Ratificada em:** [RATIFICATION_DATE]
**Última emenda:** [LAST_AMENDED_DATE]

---

## Preâmbulo

Esta Constituição expressa os princípios de segurança de dados que são **inegociáveis** em todos os projetos da Clean Environment desenvolvidos com agentes de IA. Ela é instalada automaticamente pelo preset `clean-environment-seguranca-core` e tem precedência sobre qualquer outra diretriz técnica, exceto a legislação aplicável.

Os princípios estão organizados em **seis artigos temáticos**. Cada artigo agrupa cláusulas que historicamente eram tratadas como itens soltos de checklist; aqui, ganham status normativo. A violação de qualquer cláusula em uma feature exige justificativa documentada na seção **Complexity Tracking** do `plan.md` da feature.

---

## Artigo I — Identidade e Acesso

A identidade e o acesso são a primeira camada de defesa. Falhas aqui invalidam todas as demais.

### Cláusula I.1 — Armazenamento de credenciais de sessão
Tokens de sessão, refresh tokens e qualquer outra credencial **devem** ser armazenados exclusivamente em cookies com os atributos `HttpOnly`, `Secure` e `SameSite=Strict` (ou `Lax` quando justificado por integração cross-site). **É proibido** o uso de `localStorage`, `sessionStorage` ou qualquer storage acessível por JavaScript para esse fim.

### Cláusula I.2 — Hash de senhas
Senhas **devem** ser armazenadas exclusivamente como hash com `bcrypt` (cost factor ≥ 12) ou `argon2id` (parâmetros conforme OWASP). **É proibido** o uso de MD5, SHA1, SHA256 puro, ou qualquer hash sem salt e sem custo computacional adequado.

### Cláusula I.3 — Comparação timing-safe
Toda comparação de credenciais (senha, token, HMAC, assinatura de webhook) **deve** usar função timing-safe (`bcrypt.compare`, `crypto.timingSafeEqual`, equivalente). **É proibido** comparar com `===`, `==` ou `strcmp`.

### Cláusula I.4 — Rate limiting de autenticação
Endpoints de autenticação **devem** ter rate limit de no máximo 5 tentativas por janela de 15 minutos por par (IP, identificador). Endpoints públicos em geral **devem** ter rate limit configurado. Endpoints internos sem rate limit exigem justificativa explícita.

### Cláusula I.5 — Autenticação ≠ Autorização
Todo endpoint que retorna ou modifica recurso de usuário **deve** verificar, além da autenticação, a **autorização** específica do recurso (típico: `req.user.id === resource.userId`, ou checagem de role/permissão). Confiar apenas em "o usuário está logado" é violação.

### Cláusula I.6 — Identificadores opacos
IDs de recursos expostos publicamente (URLs, payloads) **devem** ser opacos (UUID v4, ULID ou similar). **É proibido** expor IDs sequenciais ou previsíveis em recursos sensíveis sob risco de IDOR.

### Cláusula I.7 — Não-revelação de existência
Mensagens de erro de autenticação **não devem** revelar se um identificador existe (mesma mensagem para "email não cadastrado" e "senha incorreta"). Aplica-se também a fluxos de recuperação de senha e cadastro.

### Cláusula I.8 — 2FA para criticidade ≥ ALTA
Quando `security-context.criticality` ≥ ALTA, ou quando há acesso a operações administrativas, **2FA é obrigatório** para os perfis envolvidos. WebAuthn/Passkeys são preferenciais a TOTP, que é preferencial a SMS.

---

## Artigo II — Integridade dos Dados

A entrada não confiável é a fonte mais comum de vulnerabilidades. A integridade dos dados é responsabilidade do sistema, não do cliente.

### Cláusula II.1 — Validação defensiva
**Todo** input **deve** ser validado com schema explícito (Zod, Pydantic, JSON Schema ou equivalente) no backend, antes de qualquer uso. Validação no frontend é UX, nunca segurança. **É proibido** confiar em validação realizada apenas no cliente.

### Cláusula II.2 — Parametrização absoluta
Toda interação com banco SQL/NoSQL **deve** usar parametrização (prepared statements, query builder com binding, ORM). **É proibida** qualquer forma de concatenação de string com input em queries, mesmo após "sanitização" manual.

### Cláusula II.3 — Whitelist sobre blacklist
Quando aplicável, validação **deve** usar whitelist (lista do que é permitido) e não blacklist (lista do que é negado). Aplica-se a MIME types, extensões, URLs de redirect, hosts de SSRF, domínios de CORS e qualquer outro filtro.

### Cláusula II.4 — Sanitização baseada em contexto
A sanitização **deve** ser específica ao destino: HTML usa DOMPurify ou escape automático do framework; URLs usam `encodeURIComponent`; JS embutido em HTML usa serialização JSON segura; shell usa argumentos parametrizados (nunca concatenação). **É proibido** o uso de `dangerouslySetInnerHTML` (React), `v-html` (Vue) e equivalentes sem sanitização explícita documentada.

### Cláusula II.5 — Limites explícitos
Strings, arrays, números, profundidade de JSON, tamanho de upload **devem** ter limites superiores definidos. Sem limite explícito = aberto a DoS por exaustão.

### Cláusula II.6 — Upload sob magic bytes
Validação de arquivos **deve** ocorrer por magic bytes do conteúdo, nunca por extensão ou Content-Type declarado pelo cliente. Para imagens, descompressão real e leitura de dimensões antes do salvamento. Nome em disco **deve** ser UUID.

### Cláusula II.7 — Integridade de mensagens externas
Webhooks recebidos de terceiros **devem** ter assinatura verificada antes de qualquer processamento. Mensagens entre serviços internos **devem** ser autenticadas (JWT de serviço, mTLS ou equivalente).

---

## Artigo III — Resiliência e Operação

Sistemas em produção falham; falham em silêncio quando não estão sob observação. Resiliência operacional é parte da segurança.

### Cláusula III.1 — Erros opacos para fora
Respostas a clientes externos **devem** conter apenas mensagens genéricas e identificadores opacos de erro. **É proibido** retornar stack traces, mensagens de exceção raw, schemas de banco ou caminhos do sistema de arquivos em produção.

### Cláusula III.2 — Logs estruturados sem PII
Logs **devem** ser estruturados (JSON) e **não devem** conter senhas, tokens, números de cartão, PII completa, payload de upload nem corpos de webhooks com assinatura. Quando PII é necessária para correlação, usar hash determinístico ou ID interno.

### Cláusula III.3 — Headers de segurança
Toda resposta HTTP **deve** carregar, no mínimo: `Strict-Transport-Security`, `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY` (ou `Content-Security-Policy: frame-ancestors`), `Content-Security-Policy` apropriado, `Referrer-Policy: strict-origin-when-cross-origin`.

### Cláusula III.4 — CORS com whitelist
CORS **deve** usar lista explícita de origens permitidas, lidas de variável de ambiente. **É proibida** a configuração `Access-Control-Allow-Origin: *` em combinação com `Allow-Credentials: true`.

### Cláusula III.5 — Timeouts e circuit breakers
Chamadas a sistemas externos (APIs, banco, fila, storage) **devem** ter timeout configurado. Para integrações críticas, circuit breaker e exponential backoff são obrigatórios.

### Cláusula III.6 — HTTPS forçado
Tráfego em produção **deve** ocorrer exclusivamente sobre HTTPS, com HSTS habilitado e preload quando o domínio justificar. Redirecionamento HTTP → HTTPS **deve** ocorrer no edge, não no aplicativo.

### Cláusula III.7 — Permissões mínimas de banco
A conta de banco usada pelo aplicativo **deve** ter apenas as permissões necessárias. **É proibido** o uso de contas administrativas (`root`, `postgres`, `sa`) para acesso normal. Credenciais via variável de ambiente; conexão sob TLS em produção.

### Cláusula III.8 — Soft delete por padrão
Recursos auditáveis ou recuperáveis **devem** usar soft delete (`deletedAt` timestamp). Hard delete só por requisito legal (LGPD, GDPR direito ao esquecimento), com backup imutável anterior.

---

## Artigo IV — Privacidade e Compliance

A Clean Environment respeita os direitos das pessoas titulares de dados. Compliance é gate de produção, não tarefa final.

### Cláusula IV.1 — Compliance dirigido por contexto
Os requisitos legais aplicáveis a cada projeto são declarados no `.specify/memory/security-context.md` da empresa. Os Compliance Gates do `plan-template.md` ativam automaticamente os controles correspondentes. **É proibido** declarar compliance ausente em projeto que efetivamente trate dados de titulares brasileiros (LGPD) ou europeus (GDPR).

### Cláusula IV.2 — Minimização de dados
A coleta **deve** se limitar ao estritamente necessário para a finalidade declarada. Toda coleta acima do mínimo exige justificativa documentada na spec da feature.

### Cláusula IV.3 — Base legal explícita (LGPD/GDPR)
Quando LGPD ou GDPR ativo, **toda** finalidade de tratamento **deve** ter base legal declarada (consentimento, execução de contrato, obrigação legal, etc.) e documentada no `plan.md` da feature.

### Cláusula IV.4 — Direitos do titular
Quando LGPD ou GDPR ativo: direito de acesso, retificação, exclusão (esquecimento), portabilidade e oposição **devem** ter endpoints ou processos definidos antes do release de produção. Não é admissível "implementar depois".

### Cláusula IV.5 — Notificação de incidente
Quando ocorre incidente que afete dados pessoais: notificação ao DPO interno e à ANPD (LGPD) **em até 72 horas**. O `plan.md` de qualquer feature que manipule PII deve referenciar o playbook de resposta a incidentes da empresa.

### Cláusula IV.6 — Dados de pagamento
Quando PCI-DSS ativo: **proibido** armazenar PAN (número completo de cartão), CVV ou dados de banda magnética. Tokenização via provedor certificado (Stripe, Adyen, equivalente) é obrigatória.

### Cláusula IV.7 — Dados de saúde
Quando HIPAA (ou regulação equivalente) ativo: criptografia at-rest e in-transit, audit log imutável de acessos, BAA (ou equivalente contratual) com todos os fornecedores que processam PHI.

### Cláusula IV.8 — Audit log
Toda operação sobre dados sensíveis (PII, financeiros, saúde, credenciais, configuração de segurança) **deve** gerar entrada em audit log estruturado, append-only, com identificação de ator, ação, recurso, timestamp e correlation ID. Logs de audit têm retenção mínima definida no security-context.

---

## Artigo V — Cultura e Processo

Segurança é prática contínua, não evento. As cláusulas deste artigo regem o comportamento do time e dos agentes de IA durante o desenvolvimento.

### Cláusula V.1 — Test-First para superfícies de segurança
Endpoints de autenticação, autorização, manipulação de PII e pagamento **devem** ter testes escritos e validados antes do código de produção, conforme o Test-First Imperative do Spec Kit. Testes incluem casos positivos, negativos e adversariais (input malformado, tentativa de IDOR, replay de token).

### Cláusula V.2 — Defesa em profundidade
A mesma proteção **deve** existir em múltiplas camadas (frontend valida, backend valida, banco constrange). Uma camada caindo não pode comprometer a segurança.

### Cláusula V.3 — Recusa do agente
Quando o agente de IA for instruído a gerar código que viole esta Constituição, ele **deve** recusar e propor alternativa segura. Recusa não bloqueia a feature — apenas redireciona a implementação. Override explícito do humano exige documentação em `plan.md` e revisão por Security Champion.

### Cláusula V.4 — Revisão por pares antes de produção
Toda PR para `main` (ou equivalente) **deve** ter ao menos uma revisão humana, **e** ter passado pelos hooks `before_implement` e `after_implement` da extension `clean-environment-seguranca-tools` (`/speckit.security-audit` automático).

### Cláusula V.5 — Sem secrets em commit
Pre-commit hook bloqueando padrões de secret é obrigatório (`scripts/security-check.sh` + `git-secrets`). Secret detectado em git history exige rotação imediata, mesmo após remoção do arquivo.

### Cláusula V.6 — Dependências atualizadas
`npm audit --audit-level=high` (ou equivalente) **deve** retornar zero vulnerabilidades CRÍTICAS e ALTAS para release de produção. Renovate/Dependabot ativo em todo repositório.

### Cláusula V.7 — Documentação viva
Decisões de segurança não-óbvias (uso de DOMPurify, desvio de uma cláusula com justificativa, integração com terceiro de risco) **devem** ser comentadas no código E referenciadas no `plan.md` da feature.

---

## Artigo VI — Governança e Evolução

Esta Constituição evolui com o conhecimento da Clean Environment e com a paisagem de ameaças.

### Cláusula VI.1 — Soberania
Esta Constituição **prevalece** sobre qualquer documento técnico, preset de terceiros ou diretriz informal do time, exceto:
- Legislação aplicável (que prevalece sempre).
- Determinação documentada do Conselho de Segurança da Clean Environment.

### Cláusula VI.2 — Custódia
A custódia desta Constituição cabe à **Equipe de Segurança Corporativa** da Clean Environment. Atualizações são versionadas (semver) e distribuídas via repositório privado `spec-kit-private`.

### Cláusula VI.3 — Processo de emenda
Toda alteração desta Constituição **deve**:
1. Ser proposta como PR no repositório `spec-kit-private`.
2. Conter justificativa explícita (incidente, novo padrão da indústria, nova regulação, retrospectiva de projeto).
3. Receber aprovação de pelo menos dois membros da Equipe de Segurança Corporativa.
4. Receber comunicação aos times afetados antes da entrada em vigor.
5. Atualizar este arquivo com nova versão, data de emenda e changelog.

### Cláusula VI.4 — Revisão periódica
Revisão obrigatória desta Constituição **ao menos uma vez por trimestre**, conduzida pela Equipe de Segurança Corporativa, considerando:
- Incidentes ocorridos no período.
- Vulnerabilidades novas relevantes ao stack da empresa.
- Atualizações na knowledge base `vulnerabilities.md` da extension.
- Retrospectivas dos times.

### Cláusula VI.5 — Aplicação a projetos legados
Projetos em manutenção (criados antes desta Constituição) **devem** receber plano de adequação na próxima feature de meia ou maior. Refatorações puramente para conformidade são aceitas como features válidas.

### Cláusula VI.6 — Transparência
Todas as emendas, incidentes públicos (não-confidenciais) e métricas agregadas de aderência (gates passados, gates justificados) são publicadas internamente no painel de Segurança da empresa.

---

## Como esta Constituição é aplicada na prática

| Onde | Aplicação |
| --- | --- |
| `/speckit.specify` | A seção *Security & Privacy Impact* do `spec-template.md` força a equipe a declarar dados, permissões e riscos OWASP relevantes — alimenta os gates posteriores. |
| `/speckit.plan` | **Security Gate** verifica aderência aos Artigos I–III; **Compliance Gate** verifica Artigo IV conforme `security-context.md`. Violações exigem entrada em `Complexity Tracking`. |
| `/speckit.tasks` | Tasks `[SEC]` transversais são adicionadas por user story, materializando as cláusulas como trabalho de implementação. |
| `/speckit.threat-model` | Gera modelo de ameaças STRIDE usando os riscos OWASP marcados na spec. |
| `/speckit.implement` | Hook `before_implement` roda `/speckit.security-audit` em design; hook `after_implement` roda `scripts/security-check.sh` no código gerado. |
| Code review | Cláusula V.4: revisão humana + auditoria automática. |
| Produção | Cláusula V.6 + Compliance Gates aprovados. |

---

**Esta Constituição entra em vigor no momento da instalação do preset `clean-environment-seguranca-core` no projeto e permanece em vigor até sua emenda formal.**

— Clean Environment, Equipe de Segurança Corporativa
