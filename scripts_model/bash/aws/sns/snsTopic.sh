#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON SNS"
echo "TOPIC CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
topicName="topicTest1"
displayName="Topic Test 1"
region="us-east-1"
accountId="001727357081"
topicArn="arn:aws:sns:${region}:${accountId}:${topicName}"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ $resposta =~ ^[Yy]$ ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o tópico de nome $topicName"
    if [[ $(aws sns list-topics --query "Topics[?TopicArn=='$topicArn'].TopicArn" --output text | wc -w) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o tópico de nome $topicName"
        aws sns list-topics --query "Topics[?TopicArn=='$topicArn'].TopicArn" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o ARN de todos os tópicos"
        aws sns list-topics --query "Topics[].TopicArn" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o tópico de nome $topicName"
        aws sns create-topic --name $topicName --attributes DisplayName=$displayName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o tópico de nome $topicName"
        aws sns list-topics --query "Topics[?TopicArn=='$topicArn'].TopicArn" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON SNS"
echo "TOPIC EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
topicName="topicTest1"
region="us-east-1"
accountId="001727357081"
topicArn="arn:aws:sns:${region}:${accountId}:${topicName}"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ $resposta =~ ^[Yy]$ ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o tópico de nome $topicName"
    if [[ $(aws sns list-topics --query "Topics[?TopicArn=='$topicArn'].TopicArn" --output text | wc -w) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o ARN de todos os tópicos"
        aws sns list-topics --query "Topics[].TopicArn" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o tópico de nome $topicName"
        aws sns delete-topic --topic-arn $topicArn

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o ARN de todos os tópicos"
        aws sns list-topics --query "Topics[].TopicArn" --output text
    else
        echo "Não existe o tópico de nome $topicName"
    fi
else
    echo "Código não executado"
fi