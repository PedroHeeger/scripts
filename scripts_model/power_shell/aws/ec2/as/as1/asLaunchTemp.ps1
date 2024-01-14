#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2"
Write-Output "LAUNCH TEMPLATE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$launchTempName = "launchTempTest1"
$versionDescription = "My version 1"
$latestVersion = 1
$amiId = "ami-0c7217cdde317cfec"    # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
$instanceType = "t2.micro"
$keyPair = "keyPairUniversal"
$userDataPath = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/aws/ec2_userData/httpd_stress"
$userDataFile = "udFile.sh"
$tagNameInstance = "ec2Test"
$groupName = "default"
$aZ1 = "us-east-1a"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o modelo de implantação $launchTempName na versão $latestVersion"
    if ((aws ec2 describe-launch-templates --query "LaunchTemplates[?LaunchTemplateName=='$launchTempName' && to_string(LatestVersionNumber)=='$latestVersion'].LaunchTemplateName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o modelo de implantação $launchTempName na versão $latestVersion"
        aws ec2 describe-launch-templates --query "LaunchTemplates[?LaunchTemplateName=='$launchTempName' && to_string(LatestVersionNumber)=='$latestVersion'].LaunchTemplateName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os modelos de implantação"
        aws ec2 describe-launch-templates --query "LaunchTemplates[].[LaunchTemplateName,VersionNumber]" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo os IDs dos elementos de rede"
        $vpcId = aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[].VpcId" --output text
        $subnetId1 = aws ec2 describe-subnets --filters "Name=availability-zone,Values=$aZ1" "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text
        $sgId = aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$groupName'].GroupId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Codificando o arquivo user data em Base64"
        $udFileBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Content -Raw -Path "$userDataPath/$userDataFile")))

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando um launch template (modelo de implantação) de nome $launchTempName"
        aws ec2 create-launch-template --launch-template-name $launchTempName --version-description $versionDescription --launch-template-data "{
            `"ImageId`": `"$amiId`",
            `"InstanceType`": `"$instanceType`",
            `"KeyName`": `"$keyPair`",
            `"UserData`": `"$udFileBase64`",
            `"TagSpecifications`": [
              {`"ResourceType`": `"instance`",
                `"Tags`": [
                  {
                    `"Key`": `"Name`",
                    `"Value`": `"$tagNameInstance`"
                  }
                ]
              }
            ],
            `"BlockDeviceMappings`": [
              {
                `"DeviceName`": `"/dev/xvda`",
                `"Ebs`": {
                  `"VolumeSize`": 8,
                  `"VolumeType`": `"gp2`"
                }
              }
            ],
            `"NetworkInterfaces`": [
              {
                `"AssociatePublicIpAddress`": true,
                `"DeviceIndex`": 0,
                `"SubnetId`": `"$subnetId1`",
                `"Groups`": [`"$sgId`"]
              }
            ]
          }" --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o modelo de implantação $launchTempName na versão $latestVersion"
        aws ec2 describe-launch-templates --query "LaunchTemplates[?LaunchTemplateName=='$launchTempName' && to_string(LatestVersionNumber)=='$latestVersion'].LaunchTemplateName" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS EC2"
Write-Output "LAUNCH TEMPLATE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$launchTempName = "launchTempTest1"
$latestVersion = 1

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o modelo de implantação $launchTempName na versão $latestVersion"
    if ((aws ec2 describe-launch-templates --query "LaunchTemplates[?LaunchTemplateName=='$launchTempName' && to_string(LatestVersionNumber)=='$latestVersion'].LaunchTemplateName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os modelos de implantação"
        aws ec2 describe-launch-templates --query "LaunchTemplates[].LaunchTemplateName" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo a versão padrão do modelo de implantação de nome $launchTempName"
        $defaultVersion = aws ec2 describe-launch-templates --query "LaunchTemplates[?LaunchTemplateName=='$launchTempName'].DefaultVersionNumber" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se a versão escolhida é a versão padrão do modelo de implantação de nome $launchTempName"
        if ($latestVersion -eq $defaultVersion) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo o modelo de implantação de nome $launchTempName por completo"
            aws ec2 delete-launch-template --launch-template-name $launchTempName
        } else {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo o modelo de implantação de nome $launchTempName na versão $latestVersion"
            aws ec2 delete-launch-template-versions --launch-template-name $launchTempName --versions $latestVersion
        }

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os modelos de implantação"
        aws ec2 describe-launch-templates --query "LaunchTemplates[].LaunchTemplateName" --output text
      } else {Write-Output "Não existe o modelo de implantação $launchTempName na versão $latestVersion"}
} else {Write-Host "Código não executado"}