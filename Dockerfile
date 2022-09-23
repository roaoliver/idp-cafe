FROM ronanoliveira/cafe:0.1

    # adicione um ip válido
ENV IP=20.10.2.3 \
    # adicione nome host
    HN=idp \
    # adicione dominio
    HN_DOMAIN=localhost \
    # adicione ip ou nome do servidor ldap
    LDAPSERVER=10.10.2.3 \
    # Se servidor ldap utiliza ssl use true
    LDAPSERVERSSLUSE=false \
    # Se servidor ldap utiliza ssl use ldaps://
    LDAPSERVERPROTO=ldap:// \
    # Digite a porta do servidor de diretório (ex.: 389)
    LDAPSERVERPORT=389 \
    LDAPDN=dc=pop-pi,dc=rnp,dc=br \
    LDAPUSER=cn=leitor-shib,dc=pop-pi,dc=rnp,dc=br \
    LDAPPWD=senha \
    # Se optar por fazer login por email use mail
    LDAPATTR=uid \
    # Digite a url para a pagina de recuperacao de senha (ex.: https://urlpaginarecuperacaodesenha.instituicao.br)
    MSG_URL_RECUPERACAO_SENHA= \
    # Digite o texto a ser exibido para o usuário de forma que ele saiba o que deve preencher para se autenticar (ex.: Seu email @rnp.br)
    MSG_AUTENTICACAO='Digite seu nome.sobrenome'

ENV LDAPFORM=${LDAPATTR}=%s,${LDAPDN} \
    LDAPSUBTREESEARCH=true

# Se usa AD descomentar essas linhas
#ENV LDAPADDOMAIN=ad.localhost \
#    LDAPATTR=sAMAccountName \
#    LDAPFORM=%s@${LDAPADDOMAIN}

ENV CONTACT='Ronan Oliveira de Andrade' \
    CONTACTMAIL='ronan.oliveira@pop-pi.rnp.br' \
    ORGANIZATION='Ponto de Presenca da RNP no Piaui' \
    INITIALS='PoP-PI' \
    URL='www.pop-pi.rnp.br' \
    DOMAIN='pop-pi.rnp.br' \
    OU='noc' \
    CITY='Teresina' \
    UF='PI'

#COPY layout/edit-webapp/* /opt/shibboleth-idp/edit-webapp/
#COPY layout/messages/* /opt/shibboleth-idp/messages/
#COPY layout/views/* /opt/shibboleth-idp/views/

WORKDIR /root

EXPOSE 80 443 5666

RUN bash firstboot.sh

CMD ["/usr/bin/supervisord"]

HEALTHCHECK --interval=3m --timeout=30s \
  CMD curl -k -f http://localhost:8080/idp/status || exit 1