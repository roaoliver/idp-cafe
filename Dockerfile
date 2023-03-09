FROM ronanoliveira/cafe:0.1

    # adicione um ip válido
ENV IP=172.16.0.2 \
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

ENV TZ="America/Fortaleza"

# Configura timezone e linguagem e dependências 
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

EXPOSE 80 443

# edit the default Apache config to enable some modules and disable things we don't want
RUN sed -i \
  -e '/LoadModule proxy_module/s/^#//g' \
  -e '/LoadModule proxy_http_module/s/^#//g' \
  -e '/LoadModule rewrite_module/s/^#//g' \
	-e 's/^#\(Include .*httpd-ssl.conf\)/\1/' \
	-e 's/^#\(LoadModule .*mod_ssl.so\)/\1/' \
	-e 's/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/' \
  -e '/ServerAdmin/s/^/#/g' \
  -e '/httpd-vhosts.conf/s/^#//g' \
  /usr/local/apache2/conf/httpd.conf

# apagar página default html
RUN rm /usr/local/apache2/htdocs/index.html

# para utilizar logo da instituição, copiar imagem para esta pasta com nome e formato .png: logo-instituicao.png
COPY logo/logo-instituicao.png /opt/shibboleth-idp/edit-webapp/images

# configuração idp com variáveis fornecidas
RUN /usr/local/bin/init-configs

# Para utilizar certificado válido adicione a chave e certificado na pasta cert, e descomente as duas linhas COPY
# Obs.: Copiar a chave e certificado para dentro da pasta com respectivo nome: chave.key e certificado.crt
#COPY cert/chave-apache.key /etc/ssl/private
#COPY cert/certificado-apache.crt /etc/ssl/certs

CMD ["supervisord","-c","/etc/supervisor/conf.d/run-idp.conf"]

HEALTHCHECK --interval=3m --timeout=30s \
  CMD curl -k -f http://localhost:8080/idp/status || exit 1