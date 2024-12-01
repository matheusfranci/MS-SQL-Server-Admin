 Script: Remover Usuário, Alterar Proprietário do Banco de Dados e Negar Acesso

## Descrição:
Este script executa uma série de ações em um usuário em um banco de dados específico. Ele inclui os seguintes passos:
1. Remove um usuário do banco de dados.
2. Altera o proprietário do banco de dados para o usuário especificado.
3. Muda para o banco de dados `master` para garantir que operações de nível de sistema sejam realizadas.
4. Nega ao usuário o acesso para visualizar qualquer banco de dados.

## Processo:
1. **Remover Usuário**: O usuário é removido do banco de dados, o que também remove as permissões associadas.
2. **Alterar Proprietário do Banco de Dados**: A propriedade do banco de dados é reassinada para o usuário especificado.
3. **Negar Acesso**: O usuário é explicitamente negado a permissão de visualizar qualquer banco de dados.

Certifique-se de substituir `USER` no script pelo nome do usuário real.

## Uso:
Execute este script para gerenciar as funções e permissões do usuário no banco de dados especificado.

```sql
USE [DATABASE_NAME]
SP_DROPUSER USER
SP_CHANGEDBOWNER USER
USE MASTER
DENY VIEW ANY DATABASE TO USER
```