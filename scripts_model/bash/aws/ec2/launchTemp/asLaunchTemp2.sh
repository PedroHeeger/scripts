#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2"
echo "LAUNCH TEMPLATE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
launchTempName="launchTempTest1"
versionDescription="My version 1"
amiId="ami-0c7217cdde317cfec" # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
instanceType="t2.micro"
keyPair="keyPairUniversal"
userDataPath="G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/aws/ec2_userData/httpd_stress"
userDataFile="udFile.sh"
sgName="default"
aZ1="us-east-1a"
tagNameInstance="ec2Test"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o modelo de implantação de nome $launchTempName"
    if [ "$(aws ec2 describe-launch-templates --query "LaunchTemplates[?LaunchTemplateName=='$launchTempName'].LaunchTemplateName" --output text | wc -l)" -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o modelo de implantação de nome $launchTempName"
        aws ec2 describe-launch-templates --query "LaunchTemplates[?LaunchTemplateName=='$launchTempName'].LaunchTemplateName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo a última versão do modelo de implantação de nome $launchTempName"
        latestVersion=$(aws ec2 describe-launch-templates --query "LaunchTemplates[?LaunchTemplateName=='$launchTempName'].LatestVersionNumber" --output text)
        versionNumber=$((latestVersion + 1))

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as versões do modelo de implantação de nome $launchTempName"
        aws ec2 describe-launch-template-versions --launch-template-name $launchTempName --query "LaunchTemplateVersions[].[LaunchTemplateName,VersionNumber]" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo os IDs dos elementos de rede"
        vpcId=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text)
        subnetId1=$(aws ec2 describe-subnets --filters "Name=availability-zone,Values=$aZ1" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text)
        sgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Codificando o arquivo user data em Base64"
        udFileBase64=$(base64 -w 0 "$userDataPath/$userDataFile")

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o launch template (modelo de implantação) de nome $launchTempName na versão $versionNumber"
        aws ec2 create-launch-template-version --launch-template-name $launchTempName --version-description "$versionDescription" --launch-template-data '{
            "ImageId": "'"$amiId"'",
            "InstanceType": "'"$instanceType"'",
            "KeyName": "'"$keyPair"'",
            "UserData": "'"$udFileBase64"'",
            "TagSpecifications": [
                {"ResourceType": "instance",
                    "Tags": [
                        {
                            "Key": "Name",
                            "Value": "'"$tagNameInstance"'"
                        }
                    ]
                }
            ],
            "BlockDeviceMappings": [
            {
                "DeviceName": "/dev/xvda",
                "Ebs": {
                "VolumeSize": 8,
                "VolumeType": "gp2"
                }
            }
            ],
            "NetworkInterfaces": [
                {
                    "AssociatePublicIpAddress": true,
                    "DeviceIndex": 0,
                    "SubnetId": "'"$subnetId1"'",
                    "Groups": ["'"$sgId"'"]
                }
            ]
        }' --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o modelo de implantação de nome $launchTempName na versão $versionNumber"
        aws ec2 describe-launch-template-versions --launch-template-name $launchTempName --query "LaunchTemplateVersions[?to_string(VersionNumber)=='$versionNumber'].[LaunchTemplateName,VersionNumber]" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Definindo a versão como primeira do modelo de implantação de nome $launchTempName"
        versionNumber=1

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os modelos de implantação existentes"
        aws ec2 describe-launch-templates --query 'LaunchTemplates[].[LaunchTemplateName,DefaultVersionNumber]' --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo os IDs dos elementos de rede"
        vpcId=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text)
        subnetId1=$(aws ec2 describe-subnets --filters "Name=availability-zone,Values=$aZ1" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text)
        sgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Codificando o arquivo user data em Base64"
        udFileBase64=$(base64 -w 0 "$userDataPath/$userDataFile")

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o launch template (modelo de implantação) de nome $launchTempName na versão $versionNumber"
        aws ec2 create-launch-template --launch-template-name $launchTempName --version-description "$versionDescription" --launch-template-data '{
            "ImageId": "'"$amiId"'",
            "InstanceType": "'"$instanceType"'",
            "KeyName": "'"$keyPair"'",
            "UserData": "'"$udFileBase64"'",
            "TagSpecifications": [
                {"ResourceType": "instance",
                    "Tags": [
                        {
                            "Key": "Name",
                            "Value": "'"$tagNameInstance"'"
                        }
                    ]
                }
            ],
            "BlockDeviceMappings": [
            {
                "DeviceName": "/dev/xvda",
                "Ebs": {
                "VolumeSize": 8,
                "VolumeType": "gp2"
                }
            }
            ],
            "NetworkInterfaces": [
                {
                    "AssociatePublicIpAddress": true,
                    "DeviceIndex": 0,
                    "SubnetId": "'"$subnetId1"'",
                    "Groups": ["'"$sgId"'"]
                }
            ]
        }' --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o modelo de implantação de nome $launchTempName na versão $versionNumber"
        aws ec2 describe-launch-templates --query "LaunchTemplates[?LaunchTemplateName=='$launchTempName'].LaunchTemplateName" --output text
    fi
else
    echo "Código não executado"
fi





#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2"
echo "LAUNCH TEMPLATE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
launchTempName="launchTempTest1"
versionNumber=1

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "${resposta,,}" == 'y' ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o modelo de implantação de nome $launchTempName"
    if [ "$(aws ec2 describe-launch-templates --query "LaunchTemplates[?LaunchTemplateName=='$launchTempName'].LaunchTemplateName" --output text | wc -l)" -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todos os modelos de implantação existentes e sua versão padrão"
        aws ec2 describe-launch-templates --query 'LaunchTemplates[].[LaunchTemplateName,DefaultVersionNumber]' --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe o modelo de implantação de nome $launchTempName na versão $versionNumber"
        if [ "$(aws ec2 describe-launch-template-versions --launch-template-name $launchTempName --query "LaunchTemplateVersions[?to_string(VersionNumber)=='$versionNumber'].VersionNumber" --output text | wc -l)" -gt 1 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas as versões do modelo de implantação de nome $launchTempName"
            aws ec2 describe-launch-template-versions --launch-template-name $launchTempName --query "LaunchTemplateVersions[].[LaunchTemplateName,VersionNumber]" --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo a versão padrão do modelo de implantação de nome $launchTempName"
            defaultVersion=$(aws ec2 describe-launch-templates --query "LaunchTemplates[?LaunchTemplateName=='$launchTempName'].DefaultVersionNumber" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se a versão escolhida é a versão padrão do modelo de implantação de nome $launchTempName"
            if [ "$versionNumber" -eq "$defaultVersion" ]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Removendo o modelo de implantação de nome $launchTempName por completo"
                aws ec2 delete-launch-template --launch-template-name $launchTempName

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todos os modelos de implantação existentes"
                aws ec2 describe-launch-templates --query 'LaunchTemplates[].[LaunchTemplateName,DefaultVersionNumber]' --output text
            else
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Removendo o modelo de implantação de nome $launchTempName na versão $versionNumber"
                aws ec2 delete-launch-template-versions --launch-template-name $launchTempName --versions $versionNumber

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Listando todas as versões do modelo de implantação de nome $launchTempName"
                aws ec2 describe-launch-template-versions --launch-template-name $launchTempName --query "LaunchTemplateVersions[].[LaunchTemplateName,VersionNumber]" --output text
        else
            echo "Não existe o modelo de implantação de nome $launchTempName na versão $versionNumber"
        fi
    else
        echo "Não existe o modelo de implantação de nome $launchTempName"
    fi
else
    echo "Código não executado"
fi