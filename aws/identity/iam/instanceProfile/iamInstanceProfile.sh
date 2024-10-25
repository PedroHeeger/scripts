#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM INSTANCE PROFILE CREATION AND ADD ROLE"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
instanceProfileName="instanceProfileTest"
iamRoleName="iamRoleTest"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a role $iamRoleName"
    condition=$(aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o perfil de instância $instanceProfileName"
        condition=$(aws iam list-instance-profiles --query "InstanceProfiles[?InstanceProfileName=='$instanceProfileName'].InstanceProfileName" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe o perfil de instância $instanceProfileName"
            aws iam list-instance-profiles --query "InstanceProfiles[?InstanceProfileName=='$instanceProfileName'].InstanceProfileName" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todos os perfis de instância existentes"
            aws iam list-instance-profiles --query 'InstanceProfiles[].InstanceProfileName' --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando o perfil de instância $instanceProfileName"
            aws iam create-instance-profile --instance-profile-name $instanceProfileName

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Adicionando a role $iamRoleName ao perfil de instância $instanceProfileName"
            aws iam add-role-to-instance-profile --instance-profile-name $instanceProfileName --role-name $iamRoleName
        
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando o perfil de instância $instanceProfileName"
            aws iam list-instance-profiles --query "InstanceProfiles[?InstanceProfileName=='$instanceProfileName'].InstanceProfileName" --output text
        fi
    else
        echo "Não existe a role $iamRoleName"
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
instanceProfileName="instanceProfileTest"
iamRoleName="iamRoleTest"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a role $iamRoleName"
    condition=$(aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe o perfil de instância $instanceProfileName"
            condition=$(aws iam list-instance-profiles --query "InstanceProfiles[?InstanceProfileName=='$instanceProfileName'].InstanceProfileName" --output text | wc -l)
            if [[ "$condition" -gt 0 ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todos os perfis de instância existentes"
                aws iam list-instance-profiles --query 'InstanceProfiles[].InstanceProfileName' --output text

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Removendo a role $iamRoleName do perfil de instância $instanceProfileName"
                aws iam remove-role-from-instance-profile --instance-profile-name $instanceProfileName --role-name $iamRoleName

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Removendo o perfil de instância $instanceProfileName"
                aws iam delete-instance-profile --instance-profile-name $instanceProfileName

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todos os perfis de instância existentes"
                aws iam list-instance-profiles --query 'InstanceProfiles[].InstanceProfileName' --output text
            else
                echo "Não existe o perfil de instância $instanceProfileName"
            fi
    else
        echo "Não existe a role $iamRoleName"
    fi
else
    echo "Código não executado"
fi