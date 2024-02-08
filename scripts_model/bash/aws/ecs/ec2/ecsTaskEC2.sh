#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ECS"
echo "TASK EC2 CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
taskName="taskEC2Test1"
executionRoleName="ecsTaskExecutionRole"
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
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Criando uma função para executar a definição de tarefa de nome $taskName na versão correspondente"
    function ExecutarTarefa {
        local executionRoleName="$1"
        local taskName="$2"
        local launchType="$3"
        local containerName1="$4"
        local dockerImage1="$5"
        local logGroupName="$6"
        local region="$7"
        local containerName2="$8"
        local dockerImage2="$9"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando as ARNs das revisões da definição de tarefa ativas de nome $taskName"
        aws ecs list-task-definitions --family-prefix $taskName --query taskDefinitionArns[] --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ARN da role $executionRoleName"
        local executionRoleArn=$(aws iam list-roles --query "Roles[?RoleName=='$executionRoleName'].Arn" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Registrando uma definição de tarefa de nome $taskName"
        aws ecs register-task-definition --family $taskName --network-mode "bridge" --requires-compatibilities $launchType --execution-role-arn $executionRoleArn --cpu 256 --memory 512 --runtime-platform  cpuArchitecture='X86_64',operatingSystemFamily='LINUX' --container-definitions "[
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

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a revisão da definição de tarefa de nome $taskName"
        aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.revision" --output text
    }


    erro="ClientException"
    if [[ "$(aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.revision" 2>&1)" =~ $erro ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a definição de tarefa"
        ExecutarTarefa $executionRoleName $taskName $launchType $containerName1 $dockerImage1 $logGroupName $region $containerName2 $dockerImage2
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe uma definição de tarefa de nome $taskName"
        revision=$(aws ecs describe-task-definition --task-definition $taskName --query "taskDefinition.revision" --output text)
        echo "${taskName}:${revision}"

        echo "-----//-----//-----//-----//-----//-----//-----"
        newRevision=$((revision + 1))
        read -p "Quer implementar a versão $newRevision? (y/n) " resposta
        if [ "${resposta,,}" == 'y' ]; then
            ExecutarTarefa $executionRoleName $taskName $launchType $containerName1 $dockerImage1 $logGroupName $region $containerName2 $dockerImage2
        fi
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
revision="10"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "Verificando se a definição de tarefa está vazia (Ignorando erro)..."
    erro="ClientException"
    if [[ "$(aws ecs describe-task-definition --task-definition ${taskName}:${revision} --query "taskDefinition.revision" 2>&1)" =~ $erro ]]; then
        echo "Não existe a definição de tarefa de nome $taskName na revisão $revision"
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe a definição de tarefa de nome $taskName na revisão $revision"
        if [ "$(aws ecs describe-task-definition --task-definition ${taskName}:${revision} --query "taskDefinition.status" --output text)" == "ACTIVE" ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando as ARNs das revisões da definição de tarefa ativas de nome $taskName"
            aws ecs list-task-definitions --family-prefix $taskName --query taskDefinitionArns[] --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando as ARNs das revisões da definição de tarefa inativas de nome $taskName"
            aws ecs list-task-definitions --family-prefix $taskName --status INACTIVE --query taskDefinitionArns[] --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o registro da definição de tarefa de nome $taskName na revisão $revision"
            aws ecs deregister-task-definition --task-definition ${taskName}:${revision} --no-cli-pager

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo a definição de tarefa de nome $taskName na revisão $revision"
            aws ecs delete-task-definition --task-definition ${taskName}:${revision} --no-cli-pager

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando as ARNs das revisões da definição de tarefa ativas de nome $taskName"
            aws ecs list-task-definitions --family-prefix $taskName --query taskDefinitionArns[] --output text

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando as ARNs das revisões da definição de tarefa inativas de nome $taskName"
            aws ecs list-task-definitions --family-prefix $taskName --status INACTIVE --query taskDefinitionArns[] --output text
        else
            echo "Não existe a definição de tarefa de nome $taskName na revisão $revision"
        fi
    fi
else
    echo "Código não executado"
fi