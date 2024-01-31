#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "TASK EC2 CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
taskName="taskEC2Test1"
executionRoleName="ecsTaskExecutionRole"
revision="1"
launchType="EC2"
containerName1="containerTest1"
containerName2="containerTest2"
dockerImage1="docker.io/fabricioveronez/conversao-temperatura:latest"
dockerImage2="public.ecr.aws/nginx/nginx"
# dockerImage2="docker.io/library/httpd:latest"
logGroupName="/aws/ecs/ec2/taskEc2Test1"
region="us-east-1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "Verificando se a definição de tarefa está vazia (Ignorando erro)..."
    erro="ClientException"
    if aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.revision" 2>&1 | grep -q "$erro"; then
        echo "A definição de tarefa está vazia"
        condition=0
    else
        echo "A definição de tarefa não está vazia"
        condition=$(aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.revision")
    fi
    
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a definição de tarefa de nome $taskName na revisão $revision"
    if [ "$condition" -eq "$revision" ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe a definição de tarefa de nome $taskName na revisão $revision"
        aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.family" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todas as definições de tarefas criadas"
        task_definition_arns=$(aws ecs list-task-definitions --query taskDefinitionArns[] --output text)
        echo "$task_definition_arns"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ARN da role $executionRoleName"
        executionRoleArn=$(aws iam list-roles --query "Roles[?RoleName=='$executionRoleName'].Arn" --output text)
            
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Registrando uma definição de tarefa de nome $taskName na revisão $revision"
        aws ecs register-task-definition --family $taskName --network-mode "bridge" --requires-compatibilities $launchType --execution-role-arn $executionRoleArn --cpu 256 --memory 512 --runtime-platform cpuArchitecture='X86_64',operatingSystemFamily='LINUX' --placement-constraints "type=spread,field=attribute:ecs.availability-zone" --container-definitions "[
            {
                \"name\": \"$containerName1\",
                \"image\": \"$dockerImage1\",
                \"cpu\": 128,
                \"memory\": 256,
                \"portMappings\": [
                    {
                    \"containerPort\": 8080,
                    \"hostPort\": 8080
                    }
                ],
                \"essential\": false,
                \"logConfiguration\": {
                    \"logDriver\": \"awslogs\",
                    \"options\": {
                        \"awslogs-group\": \"$logGroupName\",
                        \"awslogs-region\": \"$region\",
                        \"awslogs-stream-prefix\": \"$containerName1\"
                    }        
                }
            },
            {
                \"name\": \"$containerName2\",
                \"image\": \"$dockerImage2\",
                \"cpu\": 128,
                \"memory\": 256,
                \"portMappings\": [
                {
                    \"containerPort\": 80,
                    \"hostPort\": 80
                }
                ],
                \"logConfiguration\": {
                    \"logDriver\": \"awslogs\",
                    \"options\": {
                        \"awslogs-group\": \"$logGroupName\",
                        \"awslogs-region\": \"$region\",
                        \"awslogs-stream-prefix\": \"$containerName2\"
                    }  
                }
            }
        ]" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a definição de tarefa de nome $taskName"
        aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.family" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "TASK EC2 EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
taskName="taskEC2Test1"
revision="1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "Verificando se a definição de tarefa está vazia (Ignorando erro)..."
    erro="ClientException"
    if aws ecs describe-task-definition --task-definition "${taskName}:${revision}" --query "taskDefinition.revision" 2>&1 | grep -q "$erro"; then
        echo "A definição de tarefa está vazia"
        condition=0
    else
        echo "A definição de tarefa não está vazia"
        condition=$(aws ecs describe-task-definition --task-definition "${taskName}:${revision}" --query "taskDefinition.revision")
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a definição de tarefa de nome $taskName na revisão $revision"
    if [ "$condition" -eq "$revision" ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todas as definições de tarefas criadas ativas"
        aws ecs list-task-definitions --query taskDefinitionArns[] --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todas as definições de tarefas criadas inativas"
        aws ecs list-task-definitions --status INACTIVE --query taskDefinitionArns[] --output text

        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Listando a ARN da reivsão atual da definição de tarefa de nome $taskName"
        # aws ecs describe-task-definition --task-definition "$taskName" --query "taskDefinition.taskDefinitionArn" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o registro da definição de tarefa de nome $taskName na revisão $revision"
        aws ecs deregister-task-definition --task-definition "${taskName}:${revision}" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a definição de tarefa de nome $taskName na revisão $revision"
        aws ecs delete-task-definitions --task-definition "${taskName}:${revision}" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todas as definições de tarefas criadas ativas"
        aws ecs list-task-definitions --query taskDefinitionArns[] --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs de todas as definições de tarefas criadas inativas"
        aws ecs list-task-definitions --status INACTIVE --query taskDefinitionArns[] --output text
    else
        echo "Não existe a definição de tarefa de nome $taskName na revisão $revision"
    fi
else
    echo "Código não executado"
fi