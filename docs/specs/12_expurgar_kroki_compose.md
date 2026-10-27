# Especificação Técnica: Expurgar Sidecars Kroki e Simplificar Compose Standalone

- **Ticket**: [#12](https://gambi.2lp.in/lumen/joaju-web/issues/12)
- **Status**: Fase 3: Especificação
- **Data**: 2026-10-27
- **Autor**: Lumen Pink & Antigravity

---

## 1. Contexto e Motivação

Com o desenvolvimento completo e a disponibilização dos motores soberanos em Rust puro:
- `joaju-sequence` (diagramas temporais de sequência determinísticos);
- `joaju-graph` (fluxogramas, grafos conectados, UML e topologia de nuvem);
- `joaju-wireframe` (interfaces declarativas e wireframes);
- `joaju-chem` e `joaju-pedigree`,

toda a renderização gráfica no ecossistema Joaju tornou-se estritamente nativa, matemática e determinística (direto para vetores SVG e primitives Typst), eliminando a dependência legada de contêineres externos em Java (Kroki gateway) e Node/Chromium headless (`kroki-mermaid`).

Além de consumirem mais de 1GB de RAM e gerarem sobrecarga na máquina, esses contêineres provocavam colisões de nomes (`/kroki_mermaid` já em uso) ao executar a esteira de CD no `obizero`.

---

## 2. Decisões de Arquitetura

1. **Stack Docker Compose Autônoma (Standalone)**:
   - O manifesto `compose.yaml` passa a conter única e exclusivamente o serviço de aplicação `joaju` (Axum daemon + ativos estáticos).
   - Remoção completa dos serviços auxiliares `kroki` e `kroki-mermaid`.
   - Remoção de diretivas `depends_on: [kroki]` e dependências de rede complexas.
   - O serviço `joaju` expõe a porta `3000:3000` e conecta-se à rede `joaju_net` (ou rede bridge padrão).

2. **Sincronização em `~/stacks/joaju`**:
   - O manifesto no host de produção `~/stacks/joaju/compose.yaml` é sincronizado para refletir o modelo standalone.
   - Os comandos de deploy contínuo em `.forgejo/workflows/ci.yaml` mantêm o acionamento direto via SSH `docker compose -f compose.yaml up -d --no-build joaju`.

3. **Auditoria e Validação Hermética**:
   - `tests/audit_registry_and_cd.sh` é atualizado para validar:
     - Ausência de menções ou dependências aos containers `kroki` e `kroki-mermaid` no `compose.yaml`;
     - Presença exclusiva do serviço autônomo `joaju`;
     - Presença do comando de deploy via SSH sem dependências de sidecars.
