# Reconstrução de índices

Este procedimento realiza a reconstrução de índices no SQL Server para otimizar a performance e corrigir fragmentações causadas por operações frequentes de leitura e escrita.

## Etapas do procedimento

### 1. Reconstrução do índice
O comando `ALTER INDEX ... REBUILD` é utilizado para reconstruir o índice especificado em uma tabela. Esse processo recria o índice, removendo a fragmentação e otimizando a estrutura de armazenamento.
```SQL
alter index NOME_INDEX on NOME_TABELA  REBUILD
```