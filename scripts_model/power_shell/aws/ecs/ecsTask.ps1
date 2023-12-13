#!/usr/bin/env powershell
Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "TASK CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamGroupName = "taskDefinitionTest"
$taskDefinitionName = "taskDefinitionTest"
$containerName = "containerTest"
$dockerImage = "pedroheeger/kube-news:9"

$region = "us-east-1"
$accountId = "001727357081"
$taskDefinitionArn = "arn:aws:ecs:${region}:${accountId}:task-definition/${taskDefinitionName}:1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe o grupo de nome $iamGroupName"
    if ((aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe o grupo de nome $iamGroupName"
        aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todos os grupos criados"
        aws iam list-groups --query 'Groups[].GroupName' --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Registrando uma definiçao de tarefa de nome $taskDefinitionName"
        aws ecs register-task-definition --family $taskDefinitionName --network-mode "awsvpc" --requires-compatibilities EC2 --cpu 1024 --memory 3072 --runtime-platform  cpuArchitecture='X86_64',operatingSystemFamily='LINUX' --container-definitions "[
            {
              `"name`": `"$containerName`",
              `"image`": `"$dockerImage`",
              `"cpu`": 256,
              `"memory`": 512,
              `"portMappings`": [
                {
                  `"containerPort`": 80,
                  `"hostPort`": 80
                },
              ]
            }
          ]"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Executando a definiçao de tarefa de nome $taskDefinitionName"
        aws ecs run-task --task-definition $taskDefinitionName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o grupo de nome $iamGroupName"
        aws iam list-groups --query "Groups[?GroupName=='$iamGroupName'].GroupName" --output text
    }
} else {Write-Host "Código não executado"}