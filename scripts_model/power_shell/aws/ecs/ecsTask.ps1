#!/usr/bin/env powershell
Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "TASK CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$taskDefinitionName = "taskDefinitionTest"
$revision = "2"
$containerName = "containerTest"
$dockerImage = "pedroheeger/kube-news:9"
$region = "us-east-1"
$accountId = "001727357081"
$taskDefinitionArn = "arn:aws:ecs:${region}:${accountId}:task-definition/${taskDefinitionName}:1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a definição de tarefa de nome $taskDefinitionName"
    if ((aws ecs describe-task-definition --task-definition $taskDefinitionName --query "taskDefinition.family").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe a definição de tarefa de nome $taskDefinitionName"
        aws ecs describe-task-definition --task-definition $taskDefinitionName --query "taskDefinition.family" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todas as definições de tarefas criadas"
        aws ecs list-task-definitions --query taskDefinitionArns[] --output text
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Registrando uma definiçao de tarefa de nome $taskDefinitionName"
        aws ecs register-task-definition --family $taskDefinitionName --network-mode "awsvpc" --requires-compatibilities FARGATE --cpu 1024 --memory 3072 --runtime-platform  cpuArchitecture='X86_64',operatingSystemFamily='LINUX' --container-definitions "[
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
          ]" --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Executando a definiçao de tarefa de nome $taskDefinitionName"
        aws ecs run-task --task-definition $taskDefinitionName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a definição de tarefa de nome $taskDefinitionName"
        aws ecs describe-task-definition --task-definition $taskDefinitionName --query "taskDefinition.family" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "TASK EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$taskDefinitionName = "taskDefinitionTest"
$revision = "2"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a definição de tarefa de nome $taskDefinitionName"
    if ((aws ecs describe-task-definition --task-definition $taskDefinitionName --query "taskDefinition.family").Count -gt 0) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todas as definições de tarefas criadas"
        aws ecs list-task-definitions --query taskDefinitionArns[] --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a definição de tarefa de nome $taskDefinitionName"
        aws ecs deregister-task-definition --task-definition ${taskDefinitionName}:${revision} --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todas as definições de tarefas criadas"
        aws ecs list-task-definitions --query taskDefinitionArns[] --output text
    } else {Write-Output "Não existe a definição de tarefa de nome $taskDefinitionName"}
} else {Write-Host "Código não executado"}