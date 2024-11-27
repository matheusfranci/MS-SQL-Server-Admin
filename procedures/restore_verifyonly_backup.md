#Este procedimento verifica a integridade de um backup sem restaurar os dados, garantindo que o arquivo de backup não esteja corrompido.

## Comando

```sql
RESTORE VERIFYONLY FROM DISK = 'D:\Backup\curso2022.06.14.bak';
```