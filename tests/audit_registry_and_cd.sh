#!/usr/bin/env bash
# ==============================================================================
# tests/audit_registry_and_cd.sh
# Auditoria de conformidade GOST para uso do registry lumen e deploy soberano (Ticket #5)
# ==============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "=== [AUDIT] Verificando conformidade do ecossistema joaju-web (Ticket #5) ==="

# 1. Verificar ausência de dependência de caminho local em Cargo.toml
if grep -q 'path = "\.\./joaju"' Cargo.toml; then
  echo "✘ [FALHA] Cargo.toml ainda utiliza dependência de caminho local '../joaju'!"
  exit 1
fi

# 2. Verificar uso explícito do registry soberano lumen
if ! grep -q 'registry = "lumen"' Cargo.toml; then
  echo "✘ [FALHA] Cargo.toml não configura 'registry = \"lumen\"' para joaju!"
  exit 1
fi
echo "✔ [PASS] Cargo.toml configurado para registry soberano lumen."

# 3. Verificar hermeticidade do compose.yaml e espelhos soberanos Kroki
if grep -q 'context: \.\.' compose.yaml; then
  echo "✘ [FALHA] compose.yaml ainda aponta o contexto de build para o diretório pai (..)"
  exit 1
fi
if grep -q 'dockerfile: joaju-web/Dockerfile' compose.yaml; then
  echo "✘ [FALHA] compose.yaml ainda referencia caminho fraturado de Dockerfile!"
  exit 1
fi
if ! grep -q 'image: lumenpink/joaju-web:latest' compose.yaml; then
  echo "✘ [FALHA] compose.yaml não define a imagem canônica 'lumenpink/joaju-web:latest'!"
  exit 1
fi
if ! grep -q 'image: gambi.2lp.in/lumen/mirror-kroki:0.32.1' compose.yaml; then
  echo "✘ [FALHA] compose.yaml não utiliza o espelho soberano mirror-kroki no gambi.2lp.in!"
  exit 1
fi
if ! grep -q 'image: gambi.2lp.in/lumen/mirror-kroki-mermaid:0.32.1' compose.yaml; then
  echo "✘ [FALHA] compose.yaml não utiliza o espelho soberano mirror-kroki-mermaid no gambi.2lp.in!"
  exit 1
fi
echo "✔ [PASS] compose.yaml com contexto hermético, imagem canônica e espelhos soberanos."

# 4. Verificar ausência de cópias locais fraturadas no Dockerfile
if grep -q 'COPY joaju' Dockerfile; then
  echo "✘ [FALHA] Dockerfile ainda contém cópias manuais de crates irmãs no host!"
  exit 1
fi
if ! grep -q -E "sparse\+https://(gambi|git)\.2lp\.in/api/packages/lumen/cargo/" Dockerfile; then
  echo "✘ [FALHA] Dockerfile não configura o endpoint do registry soberano lumen!"
  exit 1
fi
echo "✔ [PASS] Dockerfile hermético com sparse index configurado."

# 5. Verificar workflow de Continuous Deployment soberano
WORKFLOW_FILE=""
if [ -f .forgejo/workflows/ci.yml ]; then
  WORKFLOW_FILE=".forgejo/workflows/ci.yml"
elif [ -f .forgejo/workflows/ci.yaml ]; then
  WORKFLOW_FILE=".forgejo/workflows/ci.yaml"
else
  echo "✘ [FALHA] Nenhum arquivo de workflow encontrado em .forgejo/workflows/!"
  exit 1
fi

if grep -i "watchtower" "$WORKFLOW_FILE"; then
  echo "✘ [FALHA] $WORKFLOW_FILE ainda contém referências legadas ao Watchtower!"
  exit 1
fi

if grep -q "/home/lumen/src/joaju-web" "$WORKFLOW_FILE"; then
  echo "✘ [FALHA] $WORKFLOW_FILE ainda contém caminhos absolutos para o repositório de desenvolvimento no host!"
  exit 1
fi

if ! grep -q "cd ~/stacks/joaju && docker compose -f compose.yaml up -d --no-build joaju" "$WORKFLOW_FILE"; then
  echo "✘ [FALHA] $WORKFLOW_FILE não executa deploy seguro na stack ~/stacks/joaju/compose.yaml!"
  exit 1
fi

if ! grep -q "ssh .*id_obitwo" "$WORKFLOW_FILE"; then
  echo "✘ [FALHA] $WORKFLOW_FILE não executa conexão SSH com id_obitwo!"
  exit 1
fi

if ! grep -q "Active Healthcheck & Rollback Protocol" "$WORKFLOW_FILE"; then
  echo "✘ [FALHA] $WORKFLOW_FILE não possui passo de Healthcheck e Rollback ativo!"
  exit 1
fi

if ! grep -q "docker image prune -f" "$WORKFLOW_FILE"; then
  echo "✘ [FALHA] $WORKFLOW_FILE não executa limpeza de camadas órfãs (docker image prune -f)!"
  exit 1
fi

echo "✔ [PASS] Pipeline de Continuous Deployment soberano em $WORKFLOW_FILE 100% em conformidade."
echo "=== [AUDIT] Todos os requisitos do Ticket #5 validados com sucesso! ==="
