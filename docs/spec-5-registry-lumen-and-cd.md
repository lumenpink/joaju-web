# Especificação Normativa — Ticket #5
## Migração para Registry Soberano `lumen` e Continuous Deployment Soberano no Nó Central (obizero)

**Norma de Referência:** GOST v1.5.0 (Perfil Lumen — Seção 9)  
**Status:** Aprovado para Implementação  
**Data:** 2026-10-20  

---

### 1. Escopo e Objetivos

Esta especificação define a hermeticidade da compilação e entrega contínua do microserviço **Joaju Web (`joaju-web`)** no nó central de execução (`obizero`), eliminando dependências de caminho relativo local do filesystem e assegurando deploy soberano (Zero Watchtower):

1. **Dependência Soberana da Crate `joaju`:**
   - Em `Cargo.toml`, a dependência `joaju` deixa de utilizar caminho relativo local (`path = "../joaju"`).
   - Passa a consumir a versão canônica publicada no índice sparse da lujinha interna de crates Forgejo: `joaju = { version = "0.1.0", registry = "lumen" }`.
2. **Hermeticidade do Build Docker:**
   - O `Dockerfile` é executado com contexto hermético local (`context: .`), sem cópias fraturadas ou caminhos externos (`COPY joaju-...`).
   - O container de compilação consome o registry `sparse+https://git.2lp.in/api/packages/lumen/cargo/`.
3. **Continuous Deployment Soberano no obizero:**
   - A imagem Docker `lumenpink/joaju-web:latest` é gerada diretamente no Docker daemon do nó `obizero` através do socket montado no runner do Forgejo.
   - Aplicação imediata no runtime Compose:
     ```bash
     docker compose -f /home/lumen/src/joaju-web/compose.yaml up -d --no-build joaju
     ```
   - Veto compulsório a qualquer chamada de webhook ou orquestrador legado Watchtower.
4. **Sondagem Ativa de Healthcheck & Rollback Automático:**
   - Polling de estabilidade de até 15 segundos confirmando que o container `joaju` atinge status `running`.
   - Em caso de falha de inicialização, reversão automática para a imagem anterior salva e interrupção do job.
5. **Purga Automática de Camadas Órfãs:**
   - Execução de `docker image prune -f` após o deploy bem-sucedido.
