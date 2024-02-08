#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "TASK EC2 CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$taskName = "taskEC2Test1"
$executionRoleName = "ecsTaskExecutionRole"
$launchType = "EC2"
$containerName1 = "containerTest1"
$containerName2 = "containerTest2"
$dockerImage1 = "docker.io/fabricioveronez/conversao-temperatura:latest"
$dockerImage2 = "public.ecr.aws/nginx/nginx"
# $dockerImage2 = "docker.io/library/httpd:latest"
$logGroupName = "/aws/ecs/ec2/taskEc2Test1"
$region = "us-east-1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Criando uma função para executar a definição de tarefa de nome $taskName na versão correspondente"
    function ExecutarTarefa {
        param([string]$executionRoleName, [string]$taskName, [string]$launchType, [string]$containerName1, [string]$dockerImage1, [string]$logGroupName, [string]$region, [string]$containerName2, [string]$dockerImage2)

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando as ARNs das revisões da definição de tarefa ativas de nome $taskName"
        aws ecs list-task-definitions --family-prefix $taskName --query taskDefinitionArns[] --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o ARN da role $executionRoleName"
        $executionRoleArn = aws iam list-roles --query "Roles[?RoleName=='$executionRoleName'].Arn" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Registrando uma definição de tarefa de nome $taskName"
        aws ecs register-task-definition --family $taskName --network-mode "bridge" --requires-compatibilities $launchType --execution-role-arn $executionRoleArn --cpu 256 --memory 512 --runtime-platform  cpuArchitecture='X86_64',operatingSystemFamily='LINUX' --container-definitions "[
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

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a revisão da definição de tarefa de nome $taskName"
        aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.revision" --output text
    }


    $erro = "ClientException"
    if ((aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.revision" 2>&1) -match $erro) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a definição de tarefa";
        ExecutarTarefa $executionRoleName $taskName $launchType $containerName1 $dockerImage1 $logGroupName $region $containerName2 $dockerImage2
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe uma definição de tarefa de nome $taskName";
        $revision = (aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.revision" --output text)
        Write-Output "${taskName}:${revision}"

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        $newRevision = [int]$revision + 1
        $resposta = Read-Host "Quer implementar a versão $($newRevision.ToString())? (y/n) "
        if ($resposta.ToLower() -eq 'y') 
            {ExecutarTarefa $executionRoleName $taskName $launchType $containerName1 $dockerImage1 $logGroupName $region $containerName2 $dockerImage2}
    }   
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS ECS"
Write-Output "TASK EC2 EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$taskName = "taskEC2Test1"
$revision = "10"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "Verificando se a definição de tarefa está vazia (Ignorando erro)..."
    $erro = "ClientException"
    if ((aws ecs describe-task-definition --task-definition ${taskName}:${revision} --query "taskDefinition.revision" 2>&1) -match $erro)
    {Write-Output "Não existe a definição de tarefa de nome $taskName na revisão $revision"}
    else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe a definição de tarefa de nome $taskName na revisão $revision"
        if ((aws ecs describe-task-definition --task-definition ${taskName}:${revision} --query "taskDefinition.status" --output text) -eq "ACTIVE") {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando as ARNs das revisões da definição de tarefa ativas de nome $taskName"
            aws ecs list-task-definitions --family-prefix $taskName --query taskDefinitionArns[] --output text
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando as ARNs das revisões da definição de tarefa inativas de nome $taskName"
            aws ecs list-task-definitions --family-prefix $taskName --status INACTIVE --query taskDefinitionArns[] --output text
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo o registro da definição de tarefa de nome $taskName na revisão $revision"
            aws ecs deregister-task-definition --task-definition ${taskName}:${revision} --no-cli-pager
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Removendo a definição de tarefa de nome $taskName na revisão $revision"
            aws ecs delete-task-definitions --task-definition ${taskName}:${revision} --no-cli-pager
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando as ARNs das revisões da definição de tarefa ativas de nome $taskName"
            aws ecs list-task-definitions --family-prefix $taskName --query taskDefinitionArns[] --output text
    
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Listando as ARNs das revisões da definição de tarefa inativas de nome $taskName"
            aws ecs list-task-definitions --family-prefix $taskName --status INACTIVE --query taskDefinitionArns[] --output text
        } else {Write-Output "Não existe a definição de tarefa de nome $taskName na revisão $revision"}
    }
} else {Write-Host "Código não executado"}