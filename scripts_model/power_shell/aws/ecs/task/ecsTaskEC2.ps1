#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "TASK EC2 CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$taskName = "taskEC2Test1"
$revision = "4"
$launchType = "EC2"
$containerName1 = "containerTest1"
$containerName2 = "containerTest2"
$dockerImage1 = "docker.io/fabricioveronez/kube-news:v1"
$dockerImage2 = "docker.io/library/httpd:latest"
$region = "us-east-1"
$logGroup = "/ecs/logGroupTest1"
# $roleName = "taskEcsToCloudWatch"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "Verificando se a definição de tarefa está vazia (Ignorando erro)..."
    $erro = "ClientException"
    if ((aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.revision" 2>&1) -match $erro)
    {Write-Output "A definição de tarefa está vazia"; $condition = 0} 
    else{Write-Output "A definição de tarefa não está vazia"; $condition = (aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.revision")}
    
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a definição de tarefa de nome $taskName na revisão $revision"
    if ($condition -eq $revision) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe a definição de tarefa de nome $taskName na revisão $revision"
        aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.family" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todas as definições de tarefas criadas"
        aws ecs list-task-definitions --query taskDefinitionArns[] --output text
        # aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.taskArn" --output text

        # Write-Output "-----//-----//-----//-----//-----//-----//-----"
        # Write-Output "Extraindo a ARN da role criada"
        # $roleArn = aws iam list-roles --query "Roles[?RoleName=='$roleName'].Arn" --output text

           Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Registrando uma definição de tarefa de nome $taskName na revisão $revision"
        aws ecs register-task-definition --family $taskName --network-mode "awsvpc" --requires-compatibilities $launchType --cpu 256 --memory 512 --runtime-platform  cpuArchitecture='X86_64',operatingSystemFamily='LINUX' --container-definitions "[
            {
            `"name`": `"$containerName1`",
            `"image`": `"$dockerImage1`",
            `"cpu`": 128,
            `"memory`": 256,
            `"portMappings`": [
                {
                `"containerPort`": 8080,
                `"hostPort`": 8080
                }
            ],
            `"essential`": false,
            `"logConfiguration`": {
                `"logDriver`": `"awslogs`",
                `"options`": {
                  `"awslogs-group`":`"$logGroup`",
                  `"awslogs-region`": `"$region`",
                  `"awslogs-stream-prefix`": `"container1`"
                }
              }
            },
            {
                `"name`": `"$containerName2`",
                `"image`": `"$dockerImage2`",
                `"cpu`": 128,
                `"memory`": 256,
                `"portMappings`": [
                {
                    `"containerPort`": 80,
                    `"hostPort`": 80
                }
                ],
                `"logConfiguration`": {
                    `"logDriver`": `"awslogs`",
                    `"options`": {
                      `"awslogs-group`":`"$logGroup`",
                      `"awslogs-region`": `"$region`",
                      `"awslogs-stream-prefix`": `"container2`"
                    }
                  }
            }
        ]" --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a definição de tarefa de nome $taskName"
        aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.family" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell
Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "TASK EC2 EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$taskName = "taskEC2Test1"
$revision = "4"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "Verificando se a definição de tarefa está vazia (Ignorando erro)..."
    $erro = "ClientException"
    if ((aws ecs describe-task-definition --task-definition ${taskName}:${revision} --query "taskDefinition.revision" 2>&1) -match $erro)
    {Write-Output "A definição de tarefa está vazia"; $condition = 0} 
    else{Write-Output "A definição de tarefa não está vazia"; $condition = (aws ecs describe-task-definition --task-definition ${taskName}:${revision} --query "taskDefinition.revision")}

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a definição de tarefa de nome $taskName na revisão $revision"
    if ($condition -eq $revision) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todas as revisões da definição de tarefa de nome $taskName"
        aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.taskDefinitionArn" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o registro da definição de tarefa de nome $taskName na revisão $revision"
        aws ecs deregister-task-definition --task-definition ${taskName}:${revision} --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a definição de tarefa de nome $taskName na revisão $revision"
        aws ecs delete-task-definitions --task-definition ${taskName}:${revision} --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todas as revisões da definição de tarefa de nome $taskName"
        aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.taskDefinitionArn" --output text
    } else {Write-Output "Não existe a definição de tarefa de nome $taskName na revisão $revision"}
} else {Write-Host "Código não executado"}