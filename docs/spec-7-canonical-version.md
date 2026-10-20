# Especificação Normativa — Ticket #7
## Apresentação da Versão Canônica SemVer no Endpoint /health

**Norma de Referência:** GOST v1.5.0 (Perfil Lumen — Seção 3 & Seção 9)  
**Status:** Aprovado para Implementação  
**Data:** 2026-10-20  

---

### 1. Escopo e Objetivos

Esta especificação estabelece a apresentação mandante da versão canônica no microserviço **Joaju Web (`joaju-web`)**:

1. **Fonte Única de Versão (SSOT):** O endpoint HTTP `/health` deve retornar no campo `"version"` exatamente a versão declarada no arquivo canônico `VERSION`, respeitando o padrão SemVer 2.0.0 completo (incluindo identificadores de pré-lançamento e metadados de build com hash git).
2. **Eliminação do Acoplamento ao Cargo.toml:** O uso de `env!("CARGO_PKG_VERSION")`, que reporta apenas a versão estática `0.1.0`, é descontinuado no estado da aplicação (`AppState`), sendo substituído por `include_str!("../VERSION").trim()`.
3. **Validação Estrita de Contrato:** A suíte de testes de integração (`tests/server_spec.rs`) deve asseverar que o JSON retornado por `/health` coincide caracter por caracter com `include_str!("../VERSION").trim()`.
