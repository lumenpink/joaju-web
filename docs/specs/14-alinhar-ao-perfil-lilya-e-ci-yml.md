# Spec do Ticket #14: Alinhar ao Perfil Lilya e ci.yml

## 1. Contexto e Motivação
Padronização da esteira CI e das especificações GOST para conformidade com a norma GOST-10 (`ci.yml`) e o perfil Lilya (`https://lilya.2lp.in/profile.md`).

## 2. Escopo Técnico
- Renomear `.forgejo/workflows/ci.yaml` para `.forgejo/workflows/ci.yml`.
- Atualizar script de teste `tests/audit_gitops_dispatch.sh` e `tests/audit_registry_and_cd.sh` para verificar `ci.yml`.
- Higienizar termos imperiais em `ci.yml` e scripts de teste.
- Atualizar perfil GOST para Lilya e sincronizar diretivas.
- Garantir 100% de conformidade com `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`, `cargo test` e `cccp check --strict`.

## 3. Plano de Fases DD-TDD
- [x] Fase 1 (Ticket): #14 criado
- [x] Fase 2 (Branch): `chore/14-alinhar-ao-perfil-lilya-e-ci-yml` ativada
- [x] Fase 3 (Spec): Especificação técnica elaborada
- [ ] Fase 4 (Red Test): Teste falhando após migração para `ci.yml`
- [ ] Fase 5 (Green Implement): Renomear workflow e ajustar testes
- [ ] Fase 6 (Refactor): Limpeza e garantia de clareza
- [ ] Fase 7 (Mutation/Adversarial): Validação de caminhos e nomes
- [ ] Fase 8 (Quality Gate): Testes e clippy estritos
- [ ] Fase 9 (Finish): Encerramento com `cccp close` e integração
