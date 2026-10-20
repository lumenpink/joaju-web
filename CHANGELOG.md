# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Pipeline de Continuous Deployment soberano (Zero Watchtower) no nó central `obizero` com healthcheck de 15s e rollback automático (closes #5).
- Auditoria de conformidade para isolamento de build hermético e registry soberano (closes #5).

### Changed
- Migração da dependência `joaju` para o registry soberano Cargo (`lumen`) via sparse index HTTPS (closes #5).
- Hermeticidade completa do `Dockerfile` e `compose.yaml` com contexto isolado local e imagem canônica `lumenpink/joaju-web:latest` (closes #5).
- Inicialização do repositório em conformidade com o padrão GOST.
