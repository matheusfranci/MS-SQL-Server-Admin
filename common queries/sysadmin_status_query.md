
markdown
Copiar código
### Descrição da Query

Estas consultas têm como objetivo listar os servidores com a função de **sysadmin** no SQL Server e indicar o status de habilitação ou desabilitação de cada usuário.

#### Primeira Consulta
A primeira consulta retorna uma lista dos **principais servidores** (principals) que são membros do grupo **sysadmin**, incluindo as seguintes informações:
- **name**: Nome do principal (usuário ou login).
- **type_desc**: Descrição do tipo do principal (como `SQL_LOGIN`, `WINDOWS_LOGIN`, etc.).
- **is_disabled**: Indica se o principal está desabilitado (1 para desabilitado, 0 para habilitado).

A consulta é ordenada por **name**.

#### Segunda Consulta
A segunda consulta retorna informações semelhantes, mas adiciona uma classificação no campo **Status**, que é uma tradução para indicar se o principal está habilitado ou desabilitado:
- **Status**: 
  - 'Habilitado' se o valor de `is_disabled` for 0.
  - 'Desabilitado' se o valor de `is_disabled` for 1.
  - 'Não classificado' se o valor de `is_disabled` for nulo (caso raro).
  
A consulta também é ordenada por **name**.

```SQL
SELECT   name,type_desc,is_disabled
FROM     master.sys.server_principals 
WHERE    IS_SRVROLEMEMBER ('sysadmin',name) = 1
ORDER BY name
```

```SQL
SELECT   name,type_desc,
CASE
WHEN is_disabled = 1 then 'Desabilidado'
WHEN is_disabled = 0 then 'Habilitado'
ELSE 'Não classificado'
END AS 'Status'
FROM     master.sys.server_principals WITH(NOLOCK)
WHERE    IS_SRVROLEMEMBER ('sysadmin',name) = 1
ORDER BY name;
```