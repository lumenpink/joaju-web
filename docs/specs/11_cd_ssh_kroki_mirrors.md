# Especificação Técnica: Deploy Soberano via SSH no Obizero e Espelhos Kroki

- **Ticket**: [#11](https://gambi.2lp.in/lumen/joaju-web/issues/11)
- **Status**: Implementado / Validado
- **Data**: 2026-10-26
- **Autor**: Lumen Pink & Antigravity

---

## 1. Contexto e Motivação

O deploy contínuo (CD) do `joaju-web` no nó `obizero` realizava comandos diretos `docker compose` buscando o arquivo `/home/lumen/src/joaju-web/compose.yaml`. Essa topologia exigia a montagem do diretório de desenvolvimento local dentro do container do runner (`-v /home/lumen/src/joaju-web:/home/lumen/src/joaju-web:ro`), quebrando a hermeticidade e o desacoplamento do ambiente de CI.

Adicionalmente, os serviços de renderização gráfica dependentes (`kroki` e `kroki-mermaid`) consumiam imagens upstream externas diretamente do Docker Hub (`yuzutech/kroki:0.32.1` e `yuzutech/kroki-mermaid:0.32.1`), vulneráveis a indisponibilidades externas e rate limits.

---

## 2. Decisões de Arquitetura

1. **Deploy Contínuo Seguro via SSH no Host**:
   - O runner despacha o deploy para o host `obizero` através da rede Docker interna (`172.17.0.1:22` ou variável `DEPLOY_HOST_OBIZERO`), utilizando a chave SSH autorizada `/root/.ssh/id_obitwo`.
   - O comando opera sobre a stack soberana padronizada em `~/stacks/joaju/compose.yaml`.
   - Healthcheck ativo e protocolo de rollback automático são executados via SSH.

2. **Espelhos Soberanos de Imagens Kroki**:
   - As imagens `kroki` e `kroki-mermaid` são espelhadas no registry soberano `gambi.2lp.in/lumen/`:
     - `gambi.2lp.in/lumen/mirror-kroki:0.32.1`
     - `gambi.2lp.in/lumen/mirror-kroki-mermaid:0.32.1`
   - O manifesto `compose.yaml` passa a apontar exclusivamente para os espelhos soberanos.

3. **Validação de Conformidade**:
   - `tests/audit_registry_and_cd.sh` valida a sintaxe do deploy SSH e a utilização dos espelhos soberanos.
