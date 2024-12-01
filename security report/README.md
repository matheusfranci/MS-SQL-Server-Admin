# Security Report - SQL Server

Bem-vindo ao repositório **Security Report** para SQL Server. Este repositório contém uma série de scripts e procedimentos relacionados à segurança de instâncias SQL Server. O objetivo é fornecer ferramentas para realizar auditorias, identificar vulnerabilidades, configurar práticas de segurança, além de prevenir e mitigar possíveis riscos.

## Índice de Scripts

1. **stpchecklist_security.md**  
   Um checklist de segurança para garantir que as melhores práticas sejam seguidas em uma instância SQL Server.
   
2. **trace_and_event_monitor.md**  
   Configuração de monitoramento e rastreamento de eventos de segurança, incluindo análise de consultas e eventos do SQL Server.
   
3. **audit_login_trigger_and_object_changes.md**  
   Script de auditoria de logins e alterações de objetos no banco de dados, essencial para monitorar acessos e modificações.

4. **disable_smo_and_dmo_xps.md**  
   Desabilitação de extensões de procedimentos (XP) de SMO (SQL Management Objects) e DMO (Distributed Management Objects), prevenindo ataques relacionados.

5. **dac_connection_configuration_and_login_restrictions.md**  
   Configuração de conexões DAC (Dedicated Administrator Connection) e restrições de login, melhorando a segurança no acesso administrativo.

6. **malicious_email_exfiltration_and_sql_injection.md**  
   Prevenção de exfiltração de dados via e-mail malicioso e mitigação de riscos de injeção SQL.

7. **startup_procedure_execution_setup.md**  
   Configuração de procedimentos de inicialização para garantir que apenas procedimentos seguros sejam executados ao iniciar o servidor.

8. **default_trace_analysis_and_security_events.md**  
   Análise de trace padrão do SQL Server e eventos de segurança para monitoramento de atividades suspeitas.

9. **alter_page_verify_checksum.md**  
   Alteração da configuração de verificação de página para checksum, visando a integridade dos dados.

10. **cross_db_ownership_chain_exploit.md**  
    Análise de cadeia de posse entre bancos de dados e a exploração de possíveis falhas de segurança relacionadas a esse mecanismo.

11. **ad_hoc_data_theft_script.md**  
    Script para detectar e evitar roubo de dados ad hoc por meio de consultas não autorizadas.

12. **authentication_mode_change_and_identification.md**  
    Monitoramento e controle de mudanças no modo de autenticação e identificação de possíveis riscos.

13. **audit_failed_logins_analysis_step_03.md**  
    Continuação da auditoria de falhas de login, focando na análise de dados e alertas de tentativas malsucedidas.

14. **handling_login_failures_step_02.md**  
    Estratégias de gestão de falhas de login e medidas corretivas em caso de tentativas repetidas de acesso não autorizado.

15. **export_table_to_html_audit_output_step_01.md**  
    Exporte os resultados de auditoria de tabelas para um formato HTML, permitindo relatórios mais acessíveis.

16. **trustworthy_risk_analysis_and_exploitation.md**  
    Análise de riscos relacionados ao parâmetro `TRUSTWORTHY` e como isso pode ser explorado por usuários mal-intencionados.

## Objetivo

O objetivo principal deste repositório é fornecer um conjunto completo de ferramentas para a implementação de práticas de segurança em ambientes SQL Server. Os scripts abrangem desde auditorias básicas até configurações avançadas de segurança, com foco em mitigar os riscos mais comuns, como injeção de SQL, exfiltração de dados e vulnerabilidades de configuração.

Esses scripts devem ser usados por administradores de banco de dados, profissionais de segurança e equipes de auditoria para garantir que as instâncias do SQL Server estejam configuradas corretamente e protegidas contra ataques externos e internos.

## Como Usar

1. Cada arquivo `.md` contém o código do script e uma explicação detalhada sobre sua implementação e uso.
2. Siga as instruções em cada arquivo para aplicar as correções ou configurações em sua instância SQL Server.
3. Personalize os scripts de acordo com a infraestrutura e requisitos de segurança específicos do seu ambiente.

## Contribuição

Se você tiver sugestões de melhorias ou novos scripts que possam ser úteis para melhorar a segurança em SQL Server, fique à vontade para abrir um *pull request* ou abrir uma *issue*.

## Licença
Este repositório é baseado nos curso de segurança para MS SQL Server da power tuning, esses labs foram realizados pelo MVP Dirceu Rezende e os arquivos foram remodelados e descritos com o auxilio de IA generativa.
Este repositório é de código aberto e pode ser utilizado de acordo com a [Licença MIT](LICENSE).
