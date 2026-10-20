#!/usr/bin/env bash
# ==============================================================================
# tests/audit_gitops_dispatch.sh
# Valida integracao de workflow_dispatch e esteira GitOps no joaju-web (Ticket #6)
# ==============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

WORKFLOW=".forgejo/workflows/ci.yaml"

if [ ! -f "$WORKFLOW" ]; then
  echo "✘ [FALHA] $WORKFLOW inexistente!"
  exit 1
fi

if ! grep -q "workflow_dispatch:" "$WORKFLOW"; then
  echo "✘ [FALHA] $WORKFLOW nao declara gatilho 'workflow_dispatch:'!"
  exit 1
fi

if ! grep -q "github.event_name == 'workflow_dispatch'" "$WORKFLOW"; then
  echo "✘ [FALHA] $WORKFLOW nao autoriza deploy em evento workflow_dispatch!"
  exit 1
fi

if ! grep -q "cargo update -p joaju" "$WORKFLOW"; then
  echo "✘ [FALHA] $WORKFLOW nao executa atualizacao de joaju a partir do registry!"
  exit 1
fi

echo "✔ [PASS] Auditoria GitOps dispatch validada com sucesso em $WORKFLOW."
