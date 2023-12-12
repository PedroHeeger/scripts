#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM POLICY CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
policyName="policyTest"
policyArn="arn:aws:iam::001727357081:policy/policyTest"
idAccount="001727357081"
pathPolicyDocument="G:\Meu Drive\4_PROJ\scripts\scripts_model\.default\aws\iamPolicy.json"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a policy de nome $policyName"
    if [ $(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe a policy de nome $policyName"
        aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as polices criadas pelo usuário"
        aws iam list-policies --query "Policies[?starts_with(Arn, 'arn:aws:iam::${idAccount}:')].PolicyName"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a polciy de nome $policyName"
        aws iam create-policy --policy-name $policyName --policy-document '{
            "Version": "2012-10-17",
            "Statement": [
              {
                "Effect": "Allow",
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::seu-bucket/*"
              }
            ]
          }'

        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Criando a polciy de nome $policyName a partir do arquivo JSON"
        # aws iam create-policy --policy-name $policyName --policy-document file://$pathPolicyDocument

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a policy de nome $policyName"
        aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM POLICY EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
policyName="policyTest"
policyArn="arn:aws:iam::001727357081:policy/policyTest"
idAccount="001727357081"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a policy de nome $policyName"   
    if [ $(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as polices criadas pelo usuário"
        aws iam list-policies --query "Policies[?starts_with(Arn, 'arn:aws:iam::${idAccount}:')]" --query "Policies[].PolicyName"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ARN da policy de nome $policyName"
        policyArn=$(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a policy de nome $policyName"
        aws iam delete-policy --policy-arn "$policyArn"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as polices criadas pelo usuário"
        aws iam list-policies --query "Policies[?starts_with(Arn, 'arn:aws:iam::${idAccount}:')]" --query "Policies[].PolicyName"
    else
        echo "Não existe a policy de nome $policyName"
    fi
else
    echo "Código não executado"
fi