### Descrição da Query

Esta query retorna informações sobre o estado de espelhamento de banco de dados no SQL Server. A consulta busca dados das tabelas `sys.databases` e `sys.database_mirroring` para fornecer as seguintes informações:

1. **Nome do banco**: Nome do banco de dados.
2. **Status do banco**: Estado atual do banco (Online, Offline, etc.).
3. **Posição do espelho**: Descrição do papel do banco de dados no espelhamento (Principal ou Secundário).
4. **Sincronia**: Estado da sincronia do espelhamento (sincrônico ou assíncrono).
5. **TCP**: Nome do parceiro de espelhamento (host e IP).
6. **Instância secundária**: Nome da instância do parceiro de espelhamento.
7. **Grau de sincronismo**: Descrição do nível de segurança do espelhamento (Desempenho alto assíncrono ou Alta segurança com sincronia).

```SQL
select 
 db.name as "Nome do banco",
 db.state_desc as "Status do banco" ,
 dm.mirroring_role_desc as "Posição do espelho",
 dm.mirroring_state_desc as "Sincronia",
 dm.mirroring_partner_name as "TCP", 
 dm.mirroring_partner_instance "Instância secundária",
 CASE
WHEN dm.mirroring_safety_level_desc = 'OFF' THEN 'High performance (asynchronous)'
ELSE 'High safety without automatic failover (synchronous)'
END AS 'Grau de sincronismo'
from sys.databases db
inner join sys.database_mirroring dm
on db.database_id = dm.database_id
where dm.mirroring_role_desc is not null
order by db.name;
```