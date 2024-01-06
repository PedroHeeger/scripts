#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM INSTANCE PROFILE CREATION AND ADD ROLE"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
instanceProfileName="ecs-ec2InstanceIProfile"
roleName="ecs-ec2InstanceRole"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o perfil de instância de nome $instanceProfileName"
    if [ $(aws iam list-instance-profiles --query "InstanceProfiles[?InstanceProfileName=='$instanceProfileName'].InstanceProfileName" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o perfil de instância de nome $instanceProfileName"
        aws iam list-instance-profiles --query "InstanceProfiles[?InstanceProfileName=='$instanceProfileName'].InstanceProfileName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os perfis de instância existentes"
        aws iam list-instance-profiles --query 'InstanceProfiles[].InstanceProfileName' --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o perfil de instância de nome $instanceProfileName"
        aws iam create-instance-profile --instance-profile-name $instanceProfileName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Adicionando a role $roleName ao perfil de instância de nome $instanceProfileName"
        aws iam add-role-to-instance-profile --instance-profile-name $instanceProfileName --role-name $roleName
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o perfil de instância de nome $instanceProfileName"
        aws iam list-instance-profiles --query "InstanceProfiles[?InstanceProfileName=='$instanceProfileName'].InstanceProfileName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM INSTANCE PROFILE EXCLUSION AND REMOVE ROLE"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
instanceProfileName="ecs-ec2InstanceIProfile"
roleName="ecs-ec2InstanceRole"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o perfil de instância de nome $instanceProfileName"
    if [ $(aws iam list-instance-profiles --query "InstanceProfiles[?InstanceProfileName=='$instanceProfileName'].InstanceProfileName" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os perfis de instância existentes"
        aws iam list-instance-profiles --query 'InstanceProfiles[].InstanceProfileName' --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a role $roleName do perfil de instância de nome $instanceProfileName"
        aws iam remove-role-from-instance-profile --instance-profile-name $instanceProfileName --role-name $roleName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o perfil de instância de nome $instanceProfileName"
        aws iam delete-instance-profile --instance-profile-name $instanceProfileName

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os perfis de instância existentes"
        aws iam list-instance-profiles --query 'InstanceProfiles[].InstanceProfileName' --output text
    else
        echo "Não existe o perfil de instância de nome $instanceProfileName"
    fi
else
    echo "Código não executado"
fi