# Tech Challenge Generate Token Lambda

## O Desafio :triangular_flag_on_post:

Uma lanchonete de bairro está em expansão devido ao seu grande sucesso. Entretanto, com essa expansão e a ausência de um sistema de controle de pedidos, o atendimento aos clientes pode tornar-se caótico e confuso. Por exemplo, imagine que um cliente faça um pedido complexo, como um hambúrguer personalizado com ingredientes específicos, acompanhado de batatas fritas e uma bebida. O atendente pode anotar o pedido em um papel e entregá-lo à cozinha, mas não há garantia de que o pedido será preparado corretamente.

Sem um sistema de controle de pedidos, pode haver confusão entre os atendentes e a cozinha, resultando em atrasos na preparação e entrega dos pedidos. Pedidos podem ser perdidos, mal interpretados ou esquecidos, levando à insatisfação dos clientes e à perda de negócios.

Em resumo, um sistema de controle de pedidos é essencial para garantir que a lanchonete possa atender os clientes de maneira eficiente, gerenciando seus pedidos e estoques de forma adequada. Sem ele, a expansão da lanchonete pode não ser bem-sucedida, resultando em clientes insatisfeitos e impactando negativamente os negócios.

Para solucionar o problema, a lanchonete irá investir em um sistema de autoatendimento de fast food, composto por uma série de dispositivos e interfaces que permitem aos clientes selecionar e fazer pedidos sem precisar interagir com um atendente, com as seguintes funcionalidades:

1. **Pedido**
    - Os clientes são apresentados a uma interface de seleção na qual podem optar por se identificarem via CPF, se cadastrarem com nome e e-mail, ou não se identificar. A montagem do combo segue a sequência a seguir, sendo todas as etapas opcionais:
        - Lanche
        - Acompanhamento
        - Bebida
        - Sobremesa

**Em cada etapa, são exibidos o nome, descrição e preço de cada produto.**

2. **Pagamento**
    - O sistema deverá possuir uma opção de pagamento integrada para o MVP, sendo a forma de pagamento oferecida via QRCode do Mercado Pago.
    - Nesse MVP, será realizado um `fake checkout` para o fluxo de pagamento, sem integração direta com o Mercado Pago.

3. **Acompanhamento**
    - Uma vez que o pedido é confirmado e pago, ele é enviado para a cozinha para ser preparado. Simultaneamente, deve aparecer em um monitor para o cliente acompanhar o progresso do seu pedido com as seguintes etapas:
        - Recebido
        - Em preparação
        - Pronto
        - Finalizado

4. **Entrega**
    - Quando o pedido estiver pronto, o sistema deverá notificar o cliente que ele está disponível para retirada. Ao ser retirado, o pedido deve ser atualizado para o status finalizado.

**Além das etapas do cliente, o estabelecimento precisa de um acesso administrativo:**

1. **Gerenciar clientes**
    - Com a identificação dos clientes, o estabelecimento pode trabalhar em campanhas promocionais.

2. **Gerenciar produtos e categorias**
    - Os produtos dispostos para escolha do cliente serão gerenciados pelo estabelecimento, definindo nome, categoria, preço, descrição e imagens. Para esse sistema, teremos categorias fixas:
        - Lanche
        - Acompanhamento
        - Bebida
        - Sobremesa

3. **Acompanhamento de pedidos**
    - Deve ser possível acompanhar os pedidos em andamento e o tempo de espera de cada pedido.

As informações dispostas no sistema de pedidos precisarão ser gerenciadas pelo estabelecimento através de um painel administrativo.

## Equipe :construction_worker:

- Myller Lobo
- Jean Carlos
- Caio Isikawa
- Vanderly
- Thiago

## Pré-Requisitos :exclamation:

- AWS Cli
- Docker
- Golang
- SAM Cli

---

## Descricao do Projeto
```bash
.
├── Makefile                    <-- Comandos make para build do lambda function
├── README.md                   <-- Documentacao e instrucoes de uso
├── generate-token              
│   ├── main.go                 <-- Codigo fonte do Lambda function
│   └── main_test.go            <-- Testes Unitarios
└── template.yaml
```

## Configuração de Ambiente de Desenvolvimento Local  :heavy_check_mark:

### Installing dependencies & building the target 

A aplicação utiliza o comando `sam build` para baixar todas as dependencias e pacotes.   
Para mais detalhes leia [SAM Build here](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-build.html) 

O comando `sam build` também pode ser invocado via `Makefile`, utilizando o seguinte comando.
 
```shell
make
```

### Invocando o lambda function localmente

```bash
sam local invoke
```

### Invocando o lambda function através de um API Gateway local

```bash
sam local start-api
```

Se o comando anterior retornar sucesso, deverá ser possível acessar o Lambda function através da URL `http://localhost:3000/generatetoken`

**SAM CLI** é utilizado para emular o Lambda e o API Gateway localmente usando o arquivo `template.yaml`

## Deployment

Para realizar o deploy do Lambda function pela primeira vez, rode o seguinte comando:

```bash
sam deploy --guided
```

Esse comando irá realizar a build e o deploy na AWS, pedindo algumas informações:

* **Stack Name**: O nome da stack para realizar deploy no CloudFormation. O valor deve ser único na conta e na região.
* **AWS Region**: TheA região AWS em que será realizado o deploy do Lambda func.
* **Confirm changes before deploy**: Se respondido com 'yes', atodas as alterações serão listadas para uma revisão manual antes do deploy.
* **Allow SAM CLI IAM role creation**: Muitos modelos do AWS SAM, incluindo este, criam funções do AWS IAM necessárias para as funções do AWS Lambda incluídas para acessar os serviços da AWS. Por padrão, elas são limitadas às permissões mínimas necessárias. Para implantar uma stack do AWS CloudFormation que cria ou modifica funções do IAM, o valor `CAPABILITY_IAM` para `capabilities` deve ser fornecido. Se a permissão não for fornecida por meio deste prompt, para implantar este exemplo, você deve passar explicitamente `--capabilities CAPABILITY_IAM` para o comando `sam deploy`.
* **Save arguments to samconfig.toml**: Se respondido com 'yes', suas escolhas serão salvas em um arquivo de configuração dentro do projeto, para que no futuro você possa executar novamente `sam deploy` sem parâmetros para implantar alterações em seu aplicativo.

Você pode encontrar a URL do ponto de extremidade do API Gateway nos valores de saída exibidos após o deploy.

# Apêndice

### Instalação Golang installation

A forma mais simples de se instalar o Go é utilizando o Homebrew, chocolatey ou um Linux Package Manager.

#### Homebrew (Mac)

```shell
brew install golang
```

#### Chocolatey (Windows)

```shell
choco install golang
```