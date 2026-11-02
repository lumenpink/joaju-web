# Spec 15: Remover Push Mirror ao Codeberg e Alinhar ao Kombinat

## 1. Contexto e Motivação
O ecossistema Joaju migrou a orquestração de dependências em cascata para o daemon canônico Kombinat (`http://127.0.0.1:4040`). Disparos legados e espelhamento por push para o Codeberg no step de GitOps (`.forgejo/workflows/ci.yml`) não são mais necessários e devem ser expurgados para garantir hermeticidade da esteira.

## 2. Requisitos Técnicos
- Remover a instrução de `git push` condicional com `CODEBERG_TOKEN` em `.forgejo/workflows/ci.yml`.
- Manter o fluxo de atualização GitOps de `joaju` a partir do registry `lumen`/`gambi`.
- Assegurar que nenhum push não-autorizado ocorra na esteira para remotos legados.
- Atualizar a suíte de auditoria (`tests/audit_gitops_dispatch.sh`) para verificar estritamente que referências a push do Codeberg foram removidas do workflow.

## 3. Plano de Testes (DD-TDD)
- Fase 4: Atualizar `tests/audit_gitops_dispatch.sh` com asserção falha contra menção a `codeberg.org` no workflow.
- Fase 5: Remover o push ao Codeberg em `.forgejo/workflows/ci.yml`, tornando o teste verde.
- Fase 8: Validação de conformidade Gosplan com `cccp check --strict`.
