
# SonarQube for Embrapa I/O

Configuração de deploy do [SonarQube](https://www.sonarsource.com/products/sonarqube/) no ecossistema do Embrapa I/O.

Esta ferramenta analisa automaticamente o código-fonte dos ativos digitais desenvolvidos na plataforma para identificar problemas de qualidade e segurança, ajudando os desenvolvedores a criar softwares mais confiáveis e eficientes.

## Requisitos

A VM precisa ser configurada por alguns requisitos exigidos pelo [Elasticsearch](https://www.elastic.co/pt/elasticsearch). Primeiramente, edite o arquivo `/etc/sysctl.conf` com os seguintes atributos:

```
vm.max_map_count=524288
fs.file-max=131072
```

Depois, edite o arquivo `/etc/security/limits.conf` e inclua a linha:

```
root      -      nofile      65535
```

## Deploy

Crie os volumes necessários:

```
docker volume create sonarqube_db && \
docker volume create sonarqube_conf && \
docker volume create sonarqube_data && \
docker volume create sonarqube_extensions && \
docker volume create sonarqube_logs && \
docker volume create sonarqube_temp && \
docker volume create sonarqube_pgadmin && \
docker volume create --driver local --opt type=none --opt device=$(pwd)/backup --opt o=bind sonarqube_backup
```

Configure as variáveis de ambiente: `cp .env.example .env`. Por fim, suba a _stack_ de containers:

```
docker-compose up --force-recreate --build --remove-orphans --wait
```

## Configuração

Além do usuário `admin` é necessário criar um usuário local, com credenciais/permissões de acesso semelhantes, porém sem a permissão de "criar projetos". É neste usuário que deverá ser crio o _token_, do tipo "Global Analysis Token", que será configurado na variável `SONAR_TOKEN` do GitLab (Admin Area &raquo; CI/CD &raquo; Variables).

## Update

## Backup e Restore

O _backup_ é feito de forma automática pelo serviço `backup` da _stack_ de containers. Para isso, é utilizado a imagem [prodrigestivill/postgres-backup-local](https://hub.docker.com/r/prodrigestivill/postgres-backup-local).

Para o _restore_ é recomendado executar o seguinte procedimento:

1. Desligue todos os containers:

```
docker-compose stop
```

2. Crie um novo volume para o DB (sem apagar o anterior):

```
docker volume create sonarqube_db2
```

**Atenção!** Não se esqueça de alterar o nome na variável `VOLUME_DB` do `.env`.

3. Agora suba apenas o container do banco de dados:

```
docker-compose up --force-recreate --build --remove-orphans --wait db
```

4. Por fim, execute a restauração utilizando um container independente do PostgreSQL:

```
docker run --rm --tty --interactive -v $BACKUPFILE:/tmp/backupfile.sql.gz --network=$NETWORK postgres:$VERSION /bin/sh -c "zcat /tmp/backupfile.sql.gz | psql --host=db --port=5432 --username=$DB_USER --dbname=sonarqube -W"
```

O `$BACKUPFILE` será o nome do arquivo de _backup_ a ser restaurado. Veja dentro do diretório `backup/` qual é o mais apropriado (p.e., `./backup/last/sonarqube-latest.sql.gz`).

É necessário que `$NETWORK` seja a rede da _stack_ de containers (normalmente será `sonarqube_default`). É possível verificar com o comando `docker network ls`.

A variável `$VERSION` deve refletir a mesma versão utilizada pela imagem `postgres` no `docker-compose.yaml`.

O valor da variável `DB_USER` está no `.env` e, ao executar, será pedida a senha do DB, que está na variável `DB_PASSWORD` também no `.env`.

## Referências

- https://medium.com/@denis.verkhovsky/sonarqube-with-docker-compose-complete-tutorial-2aaa8d0771d4
