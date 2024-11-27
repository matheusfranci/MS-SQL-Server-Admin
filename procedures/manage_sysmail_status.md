# Este procedimento gerencia o status do sistema de e-mail do SQL Server, permitindo verificar o status atual e iniciar o serviço de e-mail.

## Comandos

1. **sysmail_help_status_sp**: Exibe o status atual do serviço de e-mail SQL Server, fornecendo informações sobre o serviço de correio e possíveis falhas.

2. **sysmail_start_sp**: Inicia o serviço de e-mail do SQL Server, caso o serviço tenha sido parado.

## Benefícios
- **Monitoramento**: Permite verificar se o serviço de e-mail do SQL Server está ativo e funcionando corretamente.
- **Gestão de E-mails**: Facilita a reinicialização do serviço para garantir que os alertas e notificações por e-mail sejam enviados corretamente.

## Observações
- Esses comandos são úteis para gerenciar o serviço de e-mail utilizado para envio de alertas e notificações em ambientes SQL Server.
- Certifique-se de que a conta tenha permissões adequadas para executar esses comandos.

```SQL
EXEC msdb.dbo.sysmail_help_status_sp;
```

```SQL
EXEC msdb.dbo.sysmail_start_sp;
```