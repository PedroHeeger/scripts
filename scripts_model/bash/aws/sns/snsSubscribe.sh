#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON SNS"
echo "SUBSCRIPTION CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
topicName="topicTest1"
region="us-east-1"
accountId="001727357081"
topicArn="arn:aws:sns:${region}:${accountId}:${topicName}"
protocol="email"
notificationEndpoint="phcstudy@proton.me"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ $resposta =~ ^[Yy]$ ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a subscrição de endpoint $notificationEndpoint para o tópico de nome $topicName"
    if [[ $(aws sns list-subscriptions-by-topic --topic-arn $topicArn --query "Subscriptions[?Endpoint=='$notificationEndpoint'].Endpoint" --output text | wc -w) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe a subscrição de endpoint $notificationEndpoint para o tópico de nome $topicName"
        aws sns list-subscriptions-by-topic --topic-arn $topicArn --query "Subscriptions[?Endpoint=='$notificationEndpoint'].Endpoint" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o endpoint de todas as subscrições do tópico de nome $topicName"
        aws sns list-subscriptions-by-topic --topic-arn $topicArn --query "Subscriptions[].Endpoint" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a subscrição de endpoint $notificationEndpoint para o tópico de nome $topicName"
        aws sns subscribe --topic-arn $topicArn --protocol $protocol --notification-endpoint $notificationEndpoint

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se o endpoint $notificationEndpoint da subscrição para o tópico de nome $topicName já foi confirmada"
        while :; do
            echo "Confirme o endpoint $notificationEndpoint da subscrição"
            sleep 10
            status=$(aws sns list-subscriptions-by-topic --topic-arn $topicArn --query "Subscriptions[?Endpoint=='$notificationEndpoint']" --output json | jq -r '.[0].SubscriptionArn')
            if [[ $status != "PendingConfirmation" ]]; then
                break
            fi
        done

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a subscrição de endpoint $notificationEndpoint para o tópico de nome $topicName"
        aws sns list-subscriptions-by-topic --topic-arn $topicArn --query "Subscriptions[?Endpoint=='$notificationEndpoint'].Endpoint" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AMAZON SNS"
echo "SUBSCRIPTION EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
topicName="topicTest1"
region="us-east-1"
accountId="001727357081"
topicArn="arn:aws:sns:${region}:${accountId}:${topicName}"
protocol="email"
notificationEndpoint="phcstudy@proton.me"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ $resposta =~ ^[Yy]$ ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a subscrição de endpoint $notificationEndpoint para o tópico de nome $topicName"
    if [[ $(aws sns list-subscriptions-by-topic --topic-arn $topicArn --query "Subscriptions[?Endpoint=='$notificationEndpoint'].Endpoint" --output text | wc -w) -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o endpoint de todas as subscrições do tópico de nome $topicName"
        aws sns list-subscriptions-by-topic --topic-arn $topicArn --query "Subscriptions[].Endpoint" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo a ARN da subscrição de endpoint $notificationEndpoint do tópico de nome $topicName"
        subscriptionArn=$(aws sns list-subscriptions-by-topic --topic-arn $topicArn --query "Subscriptions[?Endpoint=='$notificationEndpoint'].SubscriptionArn" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a subscrição de endpoint $notificationEndpoint para o tópico de nome $topicName"
        aws sns unsubscribe --subscription-arn $subscriptionArn

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o endpoint de todas as subscrições do tópico de nome $topicName"
        aws sns list-subscriptions-by-topic --topic-arn $topicArn --query "Subscriptions[].Endpoint" --output text
    else
        echo "Não existe a subscrição de endpoint $notificationEndpoint para o tópico de nome $topicName"
    fi
else
    echo "Código não executado"
fi