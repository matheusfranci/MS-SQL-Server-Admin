# Scripts de Manutenção de Banco de Dados SQL Server

Este repositório contém scripts SQL para realizar diversas tarefas de manutenção em bancos de dados SQL Server. Os scripts foram convertidos de arquivos `.sql` para arquivos Markdown (`.md`) para facilitar a leitura e documentação.

## Conteúdo

* **Backup de Log de Transações (TLog)**:
    * `BackupTlog_Step01.md`: Script para a primeira etapa do backup de log de transações.
    * `BackupTlog_Step02.md`: Script para a segunda etapa do backup de log de transações.
* **Backup Full (Completo)**:
    * `Step01_BkpFull.md`: Primeira etapa do backup completo.
    * `Step02_BkpFull.md`: Segunda etapa do backup completo.
    * `Step03_BkpFull.md`: Terceira etapa do backup completo.
* **Verificação e Monitoramento**:
    * `CheckCommandLog.md`: Script para verificar o log de comandos.
    * `CheckDB.md`: Script para verificar a integridade do banco de dados (DBCC CHECKDB).
* **Manutenção de Índices**:
    * `CompressIndex.md`: Script para compactar índices.
    * `ReorganizeIndex.md`: Script para reorganizar índices.
    * `Part01_IndexRebuild.md` a `Part05_IndexRebuild.md`: Scripts para reconstrução de índices, divididos em partes.
* **Atualização de Estatísticas**:
    * `UpdateStats.md`: Script para atualizar estatísticas de índices.
* **Parâmetros de Exemplo**:
    * `Part06_SampleParameters.sql`: Arquivo com parâmetros de exemplo para os scripts.

## Uso

1.  **Visualização**: Os arquivos `.md` podem ser visualizados diretamente no GitHub ou em qualquer editor de Markdown.
2.  **Execução**: Para executar os scripts SQL, copie o conteúdo dos arquivos `.md` e cole em uma janela de consulta do SQL Server Management Studio (SSMS) ou outra ferramenta de sua preferência.
3.  **Personalização**: Ajuste os parâmetros dos scripts conforme necessário para o seu ambiente. O arquivo `Part06_SampleParameters.sql` fornece exemplos de parâmetros.

## Contribuição

Contribuições são bem-vindas! Se você encontrar erros ou tiver melhorias, sinta-se à vontade para criar um pull request.

## Notas

* Os scripts foram convertidos para Markdown para facilitar a leitura e documentação. Os arquivos SQL originais foram renomeados e convertidos.
* Certifique-se de entender o impacto de cada script antes de executá-lo em um ambiente de produção.
* Realize testes em ambientes de desenvolvimento antes de aplicar as alterações em produção.
