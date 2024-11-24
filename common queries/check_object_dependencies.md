# Descrição da Consulta para Verificar Dependências de um Objeto no SQL Server

## Descrição da Consulta

A consulta executa o procedimento armazenado `sp_depends` para verificar as dependências de um objeto específico em um banco de dados do SQL Server, como uma tabela, visão ou procedimento armazenado. A seguir, estão os detalhes:

1. **Execução de `sp_depends`:**
   - O procedimento armazenado `sp_depends` é utilizado para listar os objetos no banco de dados que dependem de um objeto específico.
   - O parâmetro `@objname` é passado com o nome do objeto para o qual se deseja obter as dependências. Neste caso, o valor de `@objname` seria o nome de um procedimento armazenado (exemplo: `ProcedureName`).

2. **Objetivo:**
   - A execução dessa consulta resulta na exibição dos objetos dependentes do objeto especificado, ou seja, retorna as tabelas, visualizações ou outros procedimentos que estão diretamente relacionados ao objeto fornecido.

```SQL
EXEC sp_depends @objname = N'ProcedureName';
```