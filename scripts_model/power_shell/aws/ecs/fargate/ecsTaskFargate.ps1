#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "TASK FARGATE CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$taskName = "taskFargateTest1"
$executionRoleName = "ecsTaskExecutionRole"
$revision = "10"
$launchType = "FARGATE"
$containerName1 = "containerTest1"
$containerName2 = "containerTest2"
$dockerImage1 = "docker.io/fabricioveronez/conversao-temperatura:latest"
$dockerImage2 = "docker.io/library/httpd:latest"
$logGroupName = "/aws/ecs/fargate/taskFargateTest1"
$region = "us-east-1"

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

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o ARN da role $executionRoleName"
        $executionRoleArn = aws iam list-roles --query "Roles[?RoleName=='$executionRoleName'].Arn" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Registrando uma definição de tarefa de nome $taskName na revisão $revision"
        aws ecs register-task-definition --family $taskName --network-mode "awsvpc" --requires-compatibilities $launchType --execution-role-arn $executionRoleArn --cpu 256 --memory 512 --runtime-platform  cpuArchitecture='X86_64',operatingSystemFamily='LINUX' --container-definitions "[
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
                        `"awslogs-group`": `"$logGroupName`",
                        `"awslogs-region`": `"$region`",
                        `"awslogs-stream-prefix`": `"$containerName1`"
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
                        `"awslogs-group`": `"$logGroupName`",
                        `"awslogs-region`": `"$region`",
                        `"awslogs-stream-prefix`": `"$containerName2`"
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
Write-Output "TASK FARGATE EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$taskName = "taskFargateTest1"
$revision = "10"

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
        Write-Output "Listando as ARNs de todas as definições de tarefas criadas ativas"
        aws ecs list-task-definitions --query taskDefinitionArns[] --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todas as definições de tarefas criadas inativas"
        aws ecs list-task-definitions --status INACTIVE --query taskDefinitionArns[] --output text

        # Write-Output "-----//-----//-----//-----//-----//-----//-----"
        # Write-Output "Listando a ARN da reivsão atual da definição de tarefa de nome $taskName"
        # aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.taskDefinitionArn" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o registro da definição de tarefa de nome $taskName na revisão $revision"
        aws ecs deregister-task-definition --task-definition ${taskName}:${revision} --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a definição de tarefa de nome $taskName na revisão $revision"
        aws ecs delete-task-definitions --task-definition ${taskName}:${revision} --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todas as definições de tarefas criadas ativas"
        aws ecs list-task-definitions --query taskDefinitionArns[] --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs de todas as definições de tarefas criadas inativas"
        aws ecs list-task-definitions  --status INACTIVE --query taskDefinitionArns[] --output text
    } else {Write-Output "Não existe a definição de tarefa de nome $taskName na revisão $revision"}
} else {Write-Host "Código não executado"}