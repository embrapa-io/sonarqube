
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

## Update

## Referências

- https://medium.com/@denis.verkhovsky/sonarqube-with-docker-compose-complete-tutorial-2aaa8d0771d4
