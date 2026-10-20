# Especificação Normativa — Ticket #6
## Integração de Workflow Dispatch para Atualização em Cascata GitOps no Joaju Web

**Norma de Referência:** GOST v1.5.0 (Perfil Lumen — Seção 9)  
**Status:** Aprovado para Implementação  
**Data:** 2026-10-20  

---

### 1. Escopo e Objetivos

Esta especificação define a recepção de eventos de automação GitOps no repositório **Joaju Web (`joaju-web`)** via `workflow_dispatch`, permitindo a atualização automática da dependência `joaju` a partir do registry soberano `lumen` e consequente deploy contínuo no host `obizero`:

1. **Gatilho de Despacho Remoto:** O workflow `.forgejo/workflows/ci.yaml` deve declarar `workflow_dispatch:` como gatilho oficial.
2. **Auto-atualização GitOps da Dependência `joaju`:** Em execuções via `workflow_dispatch`, a esteira executa `cargo update -p joaju`. Se houver alteração em `Cargo.lock`, realiza commit e push para a branch `main`.
3. **Deploy Contínuo no obizero:** O job `build-and-deploy-docker` deve ser acionado tanto em eventos `push` quanto em `workflow_dispatch` na branch `main`.
