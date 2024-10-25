#!/usr/bin/env bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM INSTANCE PROFILE + ROLE + POLICY CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamRoleName="iamRoleTest"
instanceProfileName="instanceProfileTest"
policyName="AmazonS3ReadOnlyAccess"
# policyName="policyTest"
policyArn="arn:aws:iam::aws:policy/${policyName}"
# pathTrustPolicyDocument="G:/Meu Drive/4_PROJ/scripts/aws/.default/policy/iam/iamTrustPolicy.json"
# pathPolicyDocument="G:/Meu Drive/4_PROJ/scripts/aws/.default/policy/iam/iamPolicy.json"

# SERVICE:
principal="Service"
principalName="ec2.amazonaws.com"

# USER:
# principal="AWS"
# accountId="001727357081"
# iamUserName="iamUserTest"
# principalName="arn:aws:iam::${accountId}:user/${iamUserName}"

# ROLE:
# principal="AWS"
# accountId="001727357081"
# iamRoleName2="iamGroupTest2"
# principalName="arn:aws:iam::${accountId}:role/${iamRoleName2}"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "${resposta,,}" == "y" ]]; then

    VerificarOuCriarPerfilDeInstancia() {
        instanceProfileName="$1"
        iamRoleName="$2"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o perfil de instância $instanceProfileName"
        condition=$(aws iam list-instance-profiles --query "InstanceProfiles[?InstanceProfileName=='$instanceProfileName'].InstanceProfileName" --output text | wc -l)
        
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe o perfil de instância $instanceProfileName"
            aws iam list-instance-profiles --query "InstanceProfiles[?InstanceProfileName=='$instanceProfileName'].InstanceProfileName" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando o perfil de instância $instanceProfileName"
            aws iam create-instance-profile --instance-profile-name "$instanceProfileName"
            
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Adicionando a role $iamRoleName ao perfil de instância $instanceProfileName"
            aws iam add-role-to-instance-profile --instance-profile-name "$instanceProfileName" --role-name "$iamRoleName"
        fi
    }

    VincularPolicyARole() {
        policyName="$1"
        iamRoleName="$2"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ARN da policy $policyName"
        policyArn=$(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text)
        
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Vinculando a policy $policyName à role $iamRoleName"
        aws iam attach-role-policy --role-name "$iamRoleName" --policy-arn "$policyArn"
    }


    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a role $iamRoleName"
    condition=$(aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        VerificarOuCriarPerfilDeInstancia "$instanceProfileName" "$iamRoleName"
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a role $iamRoleName"
        aws iam create-role --role-name "$iamRoleName" --assume-role-policy-document "{
            \"Version\": \"2012-10-17\",
            \"Statement\": [
              {
                \"Effect\": \"Allow\",
                \"Principal\": {\"$principal\": \"$principalName\"},
                \"Action\": \"sts:AssumeRole\"
              }
            ]
          }" --no-cli-pager
        
        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Criando a role $iamRoleName com um arquivo JSON"
        # aws iam create-role --role-name "$iamRoleName" --assume-role-policy-document file://"$pathTrustPolicyDocument"
        
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe a policy $policyName"
        condition=$(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].PolicyName" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe a policy $policyName anexada à role $iamRoleName"
            if [[ $(aws iam list-attached-role-policies --role-name "$iamRoleName" --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text | wc -l) -gt 0 ]]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Já existe a policy $policyName anexada à role $iamRoleName"
                aws iam list-attached-role-policies --role-name "$iamRoleName" --query "AttachedPolicies[?PolicyName=='$policyName'].PolicyName" --output text
            else
                VincularPolicyARole "$policyName" "$iamRoleName"
            fi
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando a policy $policyName"
            aws iam create-policy --policy-name "$policyName" --policy-document "{
                \"Version\": \"2012-10-17\",
                \"Statement\": [
                  {
                    \"Effect\": \"Allow\",
                    \"Action\": \"s3:GetObject\",
                    \"Resource\": \"arn:aws:s3:::seu-bucket/*\"
                  }
                ]
              }" --no-cli-pager
            
            # echo "-----//-----//-----//-----//-----//-----//-----"
            # echo "Criando a policy $policyName a partir do arquivo JSON"
            # aws iam create-policy --policy-name "$policyName" --policy-document file://"$pathPolicyDocument"
            
            VincularPolicyARole "$policyName" "$iamRoleName"
        fi

        VerificarOuCriarPerfilDeInstancia "$instanceProfileName" "$iamRoleName"
    fi
else
    echo "Código não executado"
fi




#!/usr/bin/env bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM INSTANCE PROFILE + ROLE + POLICY EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamRoleName="iamRoleTest"
instanceProfileName="instanceProfileTest"
policyName="AmazonS3ReadOnlyAccess"
# policyName="policyTest"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [[ "${resposta,,}" == "y" ]]; then
    remover_policies_e_role() {
        local iamRoleName="$1"
        
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existem policies na role $iamRoleName"
        condition=$(aws iam list-attached-role-policies --role-name "$iamRoleName" --query 'AttachedPolicies[].PolicyName' --output text)
        
        if [[ -n "$condition" ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Separando as policies da role $iamRoleName em uma lista"
            IFS=$'\n' read -r -d '' -a policies <<< "$condition"
            
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo as policies da role $iamRoleName"
            for policyName in "${policies[@]}"; do
                policyArn=$(aws iam list-policies --query "Policies[?PolicyName=='$policyName'].[Arn]" --output text)
                aws iam detach-role-policy --role-name "$iamRoleName" --policy-arn "$policyArn"
            done
        else
            echo "Não existem policies na role $iamRoleName"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a role $iamRoleName"
        aws iam delete-role --role-name "$iamRoleName"
    }


    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a role $iamRoleName"
    condition=$(aws iam list-roles --query "Roles[?RoleName=='$iamRoleName'].RoleName" --output text)
    if [[ -n "$condition" ]]; then

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o perfil de instância $instanceProfileName"
        condition=$(aws iam list-instance-profiles --query "InstanceProfiles[?InstanceProfileName=='$instanceProfileName'].InstanceProfileName" --output text)
        if [[ -n "$condition" ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo a role $iamRoleName do perfil de instância $instanceProfileName"
            aws iam remove-role-from-instance-profile --instance-profile-name "$instanceProfileName" --role-name "$iamRoleName"

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o perfil de instância $instanceProfileName"
            aws iam delete-instance-profile --instance-profile-name "$instanceProfileName"

            remover_policies_e_role "$iamRoleName"
        else
            remover_policies_e_role "$iamRoleName"
        fi
    else
        echo "Não existe a role $iamRoleName"
    fi
else
    echo "Código não executado"
fi