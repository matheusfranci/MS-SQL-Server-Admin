Scripts do curso de Segurança da power tuning.

Default trace - É habilitado por padrão e traz informações relacionadas a auditoria muito interessantes.

Startup Procs - São procedures executadas com a súbida da instância, elas podem ser utilizadas para revigorar os acessos de um atacante. 
Por exemplo um DBA sai da empresa sabendo que seu usuário será bloqueado, ele cria uma proc que irá recriar o usuário dele no próximo reboot e garantir os privilégios.
DatabaseMail XP ou SQL Mail XP - Possibilita o atacante a enviar e-mail com dados sensíveis. Alternativa a isso seria criar um controle paralelo e desabilitar a proc.

Remote Admin Connections (DAC) - O SQL Server permite 32767 conexões. O sql server reserva uma conexão DAC para casos extremos onde todos os slots de conexão estão em utilização.
Ele pode ser útil quando um atacante tenta bloquear o acesso do dba utilizando uma server trigger ou outro mecanismo. A conexão DAC ela burla qualquer bloqueio e pode ser utilizado na defesa.
Para usar a conexão DAC basta colocar no ssms na option da instância ADMIN:INSTANCENAME.

Remote Access - É uma configuração antiga que permitia executar procedure remotamente. Ela foi depreciada e hoje utilizamos o linked server. Ela deve ser desabilitada pois abre brecha para atacantes explorarem
essa vulnerabilidade.

SQL-DMO e SQL-SMO - São módulos que permitem o desenvolvimento dentro do SQL Server através de encapsulamento de código c sharp, powershell ou visual basic net. Esse módulo deve ser desabilitado
pois permite ao atacante programar um malware. O DMO já foi descontinuado e não é utilizado desde o SQL SERVER 2012, o problema de desabilitar o SMO é que ao fazer isso o SSMS torna-se inutilizado
já que o mesmo utiliza pacotes do SMO para funcionar.
Caso desabilite, utilize o azure data studio ou sqlcmd, não sei se isso se aplica ao dbeaver ou toad por exemplo.

Server Trigger - Mapear todas as triggers pois as mesmas podem ser utilizadas por atacantes. Não precisa evitar de tê-las mas apenas conhecê-las.

Trace e Extend Events - Ambos são utilizados para auditoria. Verificam informações das sessões flagadas como tempo de execução e utilização de CPU.
Eles podem ser utilizados pelos atacantes para coleta de informações sensíveis do ambiente.
