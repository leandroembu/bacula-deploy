## Instalação do Servidor Bacula

A instalação, no momento, é feita através de um script que compila os serviços bacula-dir, bacula-fd e bacula-sd. O script também faz a instalação do Baculum, cliente web.

### Vídeo

Vídeo demonstrando a instalação do servidor e do cliente: https://acloud.astian.org/index.php/s/5JwcXiBzH8tZ9bn

### Instalação

O script deve ser executado como root. O script tem algumas variáveis que precisam ser editadas antes da execução:
- job_email
- host
  - IP ou hostname. O hostname deve ser "fqdn".
  - Se algum hostname for usado, ele deve estar no /etc/hosts ou DNS.
- db_name
- db_user
- db_password

```
wget https://raw.githubusercontent.com/leandroramos/bacula-deploy/main/bacula-director-deploy.sh

chmod +x bacula-director-deploy.sh

./bacula-director-deploy.sh
```

Após a execução, os serviços deverão responder nas seguintes portas:
- bacula-dir: 9101
- bacula-fd: 9102
- bacula-sd: 9103


### Testando o Bacula Console
```shell
# A opção -t verifica se os arquivos de configuração estão funcionando corretamente
bacula-dir -t
bacula-fd -t
bacula-sd -t

# Se estiver tudo certo, o console do Bacula estará disponível usando o comando abaixo
bconsole
```

## Instalação do Baculum

```
wget https://raw.githubusercontent.com/leandroramos/bacula-deploy/main/baculum-deploy.sh

chmod +x baculum-deploy.sh

./baculum-deploy.sh
```

### Configuração da API com o Baculum

A configuração da API pode ser feita na URL do servidor, na porta 9096.

### Configuração do cliente Web

Após a configuração da API, o cliente web pode ser configurado na URL do servidor, na porta 9095.

## Instalação do cliente (bacula-fd)

A instalação do cliente é feita da mesma forma. A diferença é que a compilação é feita com suporte apenas ao serviço client (bacula-fd). 

```shell
wget https://raw.githubusercontent.com/leandroramos/bacula-deploy/main/bacula-client-deploy.sh

chmod +x bacula-client-deploy.sh

./bacula-client-deploy.sh
```

---

## Conexão do Director com o Client

### Vídeo

Vídeo demonstrando a criação e a conexão com um client: https://acloud.astian.org/index.php/s/RQ9HaHWCBbHHK62

### Criação do Client

Client é a máquina de onde faremos backups.
Para criar o client, o serviço bacula-fd deve estar rodando na máquina cliente.
                                                                                                                                                       
### Configuração da máquina Client

Com o bacula-fd instalado e rodando, precisamos configurar o _director_ no arquivo /etc/bacula/bacula-fd.conf.

```
#
# List Directors who are permitted to contact this File daemon
#
Director {
  # O nome do director deve ser o mesmo
  # nome do director no servidor Bacula
  Name = bacula-dir
  # A senha abaixo deve ser a mesma
  # na hora de criar o client no servidor
  Password = "hTrzSwx3eNSVVTua75hxn/Ota7nluX/5QPd3u8GfTWKr"
}
```

![Trecho de configuração do bacula-fd na máquina cliente](https://i.imgur.com/kRh05TI.png)

### Criação do Client no Baculum (servidor)

No Baculum (servidor-bacula:9095, no navegador), crie um novo cliente.

![Criação de novo cliente Bacula](https://i.imgur.com/hntARUa.png)

Preencha os dados e cuide para que a senha do Client seja a mesma senha do /etc/bacula/bacula-fd.conf na máquina Client (tópico acima - configuração da máquina client).

![Dados do novo client](https://i.imgur.com/OqTx2hG.png)

Na página de detalhes do cliente, podemos ver seu status:

![Lista de clientes](https://i.imgur.com/JDjT0Lg.png)

![Detalhes do cliente](https://i.imgur.com/ANJBDKG.png)

![Status do cliente](https://i.imgur.com/O0AhFaR.png)

---

## Primeiro backup e restore

### Vídeo

Vídeo demonstrando o primeiro backup/restore: https://acloud.astian.org/index.php/s/7YYjbtpHWJPR7QE

### Criação do Device (Servidor Bacula)

Device é um dispositivo onde podemos gravar backups. Pode ser um disco, drive de fita, diretório ou ponto de montagem qualquer, etc.

Um device em diretório no sistema de arquivos também pode servir de ponto de montagem para sistemas remotos, como NFS, Samba, s3fs, etc.

O diretório deve ser acessível para leitura e escrita ao usuário www-data e ao grupo bacula:

```
mkdir -p /backups/servidor-web

chown -R www-data:bacula /backups/servidor-web
```

No Baculum, acesse a página _storages_ e adicione um _device_:

![Novo device](https://i.imgur.com/M0DCkV7.png)

Configure o nome, localização e MediaType do novo device. Marque as opções RandomAccess, AutomaticMount, LabelMedia e AlwaysOpen.

![Detalhes do novo device](https://i.imgur.com/zFpYnFd.png)

### Criação do Storage

Com o device criado, podemos criar o storage que usará o device. Na página de storages, crie um novo storage e mande "Copiar configuração de" _File1_:

![Criação do novo storage](https://i.imgur.com/RjOrtj2.png)

Coloque o nome do device a ser usado, usando o mesmo nome para MediaType:

![Dados do novo storage](https://i.imgur.com/vciK64e.png)

Veja o status do novo storage:

![Status do novo storage](https://i.imgur.com/pDnRpiD.png)

### Criação do FileSet

FileSet é um conjunto de arquivos para fazermos backups. São arquivos da máquina cliente que desejamos guardar backups.

![Adicionar novo FileSet](https://i.imgur.com/do6JhRh.png)

![Detalhes do FileSet](https://i.imgur.com/otq1Gjf.png)

![Adicionar vários arquivos](https://i.imgur.com/TUXIzuO.png)

Ao selecionar um cliente, podemos navegar pelos diretórios e incluir ao FileSet:

![Incluindo diretórios ao FileSet](https://i.imgur.com/kWmUeE3.png)


### Criação do Job de Backup

Agora que temos:

- Cliente
- Device
- Storage
- FileSet

Podemos criar um Job de backup. Ainda poderíamos criar Pools, mas a que já vem configurada é suficiente.

Na página de Jobs, crie um novo Job no assistente de criação de job de backup:

![Assistente de criação do Job](https://i.imgur.com/Uyvc86X.png)

Podemos usar o JobDefs padrão (DefaultJob)

![Informações básicas sobre o job de backup](https://i.imgur.com/8BXk41s.png)

Configure o cliente e o FileSet:

![Client e FileSet](https://i.imgur.com/YlMidTD.png)

Configure Storage e Pool para o job:

![Storage e Pool](https://i.imgur.com/U6rK3bW.png)

Selecione o nível de backup eu outras coisas, se necessário:

![Outras configurações do job](https://i.imgur.com/1dNUBUq.png)

Selecione ou crie uma nova agenda:

![Seleção da agenda](https://i.imgur.com/NzaFpAv.png)

Na página de detalhes do Job, mande executar o Job:

![Detalhes do Job](https://i.imgur.com/m9GzbGb.png)

Veja a estimativa do Job:

![Estimativa do Job](https://i.imgur.com/1xU1knc.png)

Backup OK:

![Resumo do job de backup](https://i.imgur.com/qkRFNyg.png)

Lista de jobs no _bconsole_:

![Lista de jobs no bconsole](https://i.imgur.com/jn5GE7N.png)

### Assistente de Restauração

O Restore Wizard permite restaurarmos arquivos de acordo com os backups bem-sucedidos.

![Dashboard do Baculum](https://i.imgur.com/HYZHrmu.png)

Seleção do cliente a ser restaurado:

![Seleção do cliente a ser restaurado](https://i.imgur.com/K5BofGK.png)

Seleção do job a ser restaurado:

![Seleção do job a ser restaurado](https://i.imgur.com/NMMSOcF.png)

Selecionar arquivos a serem restaurados:

![Seleção de arquivos a restaurar](https://i.imgur.com/FTPa07I.png)

Seleção do diretório destino da restauração:

![Destino do restore](https://i.imgur.com/vfx6Boc.png)

Definição da política de substituição de arquivos:

![Política da substituição de arquivos](https://i.imgur.com/roRrGmp.png)

Restauração OK:

![Status da restauração](https://i.imgur.com/9VPrXtI.png)

![Status da restauração no bconsole](https://i.imgur.com/iNmbDdR.png)

