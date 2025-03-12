# Repositório de Performance SQL Server

Este repositório contém scripts e documentação para análise e otimização de performance do SQL Server. Ele inclui scripts como `sp_Blitz`, `sp_BlitzCache`, `sp_BlitzFirst`, `sp_BlitzIndex` e `sp_BlitzWho`, além de análises detalhadas em `SQLServerPerformanceAnalysis.md`.

## Conteúdo

* **`SQLServerPerformanceAnalysis.md`**: Documentação detalhada sobre análises de performance do SQL Server.
* **`sp_Blitz.md`**: Script para diagnóstico geral de problemas de performance.
* **`sp_BlitzCache.md`**: Script para análise do cache de planos do SQL Server.
* **`sp_BlitzFirst.md`**: Script para coleta rápida de informações de performance do SQL Server.
* **`sp_BlitzIndex.md`**: Script para análise de índices do SQL Server.
* **`sp_BlitzWho.md`**: Script para monitoramento de processos ativos no SQL Server.

## Sobre os Scripts

Os scripts `sp_Blitz*` são parte do First Responder Kit, uma coleção de scripts úteis para administradores de banco de dados SQL Server. Eles fornecem insights valiosos sobre a saúde e o desempenho do seu servidor SQL Server.

* **`sp_Blitz`**: Realiza uma análise abrangente do SQL Server, verificando diversas configurações e problemas potenciais.
* **`sp_BlitzCache`**: Analisa o cache de planos para identificar consultas que consomem mais recursos.
* **`sp_BlitzFirst`**: Coleta rapidamente informações sobre o estado atual do SQL Server, como CPU, memória e I/O.
* **`sp_BlitzIndex`**: Analisa índices para identificar índices ausentes, duplicados ou não utilizados.
* **`sp_BlitzWho`**: Mostra quem está conectado ao SQL Server e o que eles estão fazendo.

## Como Usar

1.  Clone este repositório para o seu ambiente local.
2.  Abra o SQL Server Management Studio (SSMS).
3.  Conecte-se ao seu servidor SQL Server.
4.  Abra os scripts `.md` no SSMS ou em um editor de texto para copiar o código SQL.
5.  Execute os scripts no seu servidor SQL Server.
6.  Analise os resultados para identificar e resolver problemas de performance.
7.  Leia `SQLServerPerformanceAnalysis.md` para entender as análises e otimizações.

## Contribuição

Contribuições são bem-vindas! Se você tiver melhorias, correções de bugs ou novos scripts, por favor, envie um pull request.

## Licença

Este repositório utiliza a licença MIT. Consulte o arquivo `LICENSE` para obter mais detalhes.

## Recursos Adicionais

* [First Responder Kit](http://FirstResponderKit.org)
* [Brent Ozar Unlimited](https://www.brentozar.com/)
