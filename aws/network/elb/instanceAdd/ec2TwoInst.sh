#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2 E AWS ELB"
echo "TWO INSTANCE CREATION AND ADD AO ELB (CLB OU ALB)"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameInstance="ec2ELBTest"
instanceA="1"
instanceB="2"
sgName="default"
az="us-east-1a"
imageId="ami-0c7217cdde317cfec"    # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
so="ubuntu"
# so="ec2-user"
instanceType="t2.micro"
keyPairPath="G:/Meu Drive/4_PROJ/scripts/aws/.default/secrets/awsKeyPair/universal"
keyPairName="keyPairUniversal"
userDataPath="G:/Meu Drive/4_PROJ/scripts/aws/compute/ec2/userData/httpd/"
userDataFile="udFileDeb.sh"
# deviceName="/dev/xvda" 
deviceName="/dev/sda1"
volumeSize=8
volumeType="gp2"
elbName="albTest1"
# elbName="clbTest1"
tgName="tgTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "${resposta,,}" == "y" ]; then
    addInstanceLb() {
        local elbName=$1
        local tgName=$2
        local tagNameInstance=$3
        local instanceId=$4

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando o tipo de load balancer"
        isClassicLB=false
        isApplicationLB=false

        classicLB=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$elbName'].LoadBalancerName" --output text)
        applicationLB=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?LoadBalancerName=='$elbName'].LoadBalancerName" --output text)
        
        if [ -n "$classicLB" ]; then
            isClassicLB=true
        elif [ -n "$applicationLB" ]; then
            isApplicationLB=true
        fi

        if [ "$isClassicLB" = true ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se a instância $tagNameInstance está associada ao classic load balancer $elbName"
            condition=$(aws elb describe-load-balancers --load-balancer-name "$elbName" --query "LoadBalancerDescriptions[].Instances[?InstanceId=='$instanceId'].InstanceId" --output text)
            
            if [ -n "$condition" ]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Já existe a instância $tagNameInstance associada ao classic load balancer $elbName"
                aws elb describe-load-balancers --load-balancer-name "$elbName" --query "LoadBalancerDescriptions[].Instances[?InstanceId=='$instanceId'].InstanceId" --output text
            else
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Registrando a instância $tagNameInstance ao classic load balancer $elbName"
                aws elb register-instances-with-load-balancer --load-balancer-name "$elbName" --instances "$instanceId"
            fi
        elif [ "$isApplicationLB" = true ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe o target group $tgName"
            condition=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupName" --output text)
            
            if [ -n "$condition" ]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Extraindo a ARN do target group $tgName"
                tgArn=$(aws elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='$tgName'].TargetGroupArn" --output text)

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Verificando se existe a instância $tagNameInstance no target group $tgName"
                condition=$(aws elbv2 describe-target-health --target-group-arn "$tgArn" --query "TargetHealthDescriptions[?contains(Target.Id, '$instanceId')].Target.Id" --output text)
                
                if [ -n "$condition" ]; then
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Já existe a instância $tagNameInstance no target group $tgName"
                    aws elbv2 describe-target-health --target-group-arn "$tgArn" --query "TargetHealthDescriptions[?contains(Target.Id, '$instanceId')].Target.Id" --output text
                else
                    echo "-----//-----//-----//-----//-----//-----//-----"
                    echo "Registrando a instância $tagNameInstance no target group $tgName"
                    aws elbv2 register-targets --target-group-arn "$tgArn" --targets Id="$instanceId"
                fi
            else
                echo "Não existe o target group $tgName. A instância $tagNameInstance não pôde ser adicionada. Certifique-se de criar o target group."
            fi
        else
            echo "Não existe o load balancer $elbName ou não pertence aos tipos Classic e Application. A instância $tagNameInstance não foi vinculada ao load balancer."
        fi
    }


    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe as instâncias ativas ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
    condition=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[?(Tags[?Key=='Name' && (Value=='${tagNameInstance}${instanceA}' || Value=='${tagNameInstance}${instanceB}')])].[Tags[?Key=='Name'].Value | [0]]" --output text)

    if [ -n "$condition" ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe as instâncias ativas ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name' && Value=='${tagNameInstance}${instanceA}'].Value" --output text
        aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name' && Value=='${tagNameInstance}${instanceB}'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o IP público das instâncias ativas ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        instanceIpA=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceA}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text)
        instanceIpB=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceB}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" --output text)
        echo "$instanceIpA"
        echo "$instanceIpB"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id das instâncias ativas ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        instanceIdA=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceA}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text)
        instanceIdB=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceB}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância ${tagNameInstance}${instanceA}"
        echo "ssh -i \"$keyPairPath/$keyPairName.pem\" $so@$instanceIpA"
        echo "aws ssm start-session --target $instanceIdA"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância ${tagNameInstance}${instanceB}"
        echo "ssh -i \"$keyPairPath/$keyPairName.pem\" $so@$instanceIpB"
        echo "aws ssm start-session --target $instanceIdB"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Adicionando as instâncias ao load balancer $elbName"
        addInstanceLb "$elbName" "$tgName" "$tagNameInstance" "$instanceIdA"
        addInstanceLb "$elbName" "$tgName" "$tagNameInstance" "$instanceIdB"
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Não existe instância ${tagNameInstance}${instanceA} ou ${tagNameInstance}${instanceB} em execução."
    fi
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS EC2"
echo "DOUBLE INSTANCE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
tagNameInstance="ec2ELBTest"
instanceA="1"
instanceB="2"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe as instâncias ativas ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
    condition=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[?(Tags[?Key=='Name' && (Value=='${tagNameInstance}${instanceA}' || Value=='${tagNameInstance}${instanceB}')])].[Tags[?Key=='Name'].Value | [0]]" --output text)

    if [ $(echo "$condition" | wc -l) -gt 0 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o nome de tag de todas as instâncias criadas ativas"
        aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id das instâncias ativas ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        instanceIdA=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceA}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text)
        instanceIdB=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${tagNameInstance}${instanceB}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo as instâncias ativas ${tagNameInstance}${instanceA} e ${tagNameInstance}${instanceB}"
        aws ec2 terminate-instances --instance-ids $instanceIdA $instanceIdB --no-dry-run --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Aguardando a instância ser removida"
        instanceStateA=""
        instanceStateB=""
        while [[ "$instanceStateA" != "terminated" || "$instanceStateB" != "terminated" ]]; do
            sleep 20  
            instanceStateA=$(aws ec2 describe-instances --instance-ids "$instanceIdA" --query "Reservations[].Instances[].State.Name" --output text --no-cli-pager)
            echo "Estado atual da instância ${tagNameInstance}${instanceA}: $instanceStateA"
            instanceStateB=$(aws ec2 describe-instances --instance-ids "$instanceIdB" --query "Reservations[].Instances[].State.Name" --output text --no-cli-pager)
            echo "Estado atual da instância ${tagNameInstance}${instanceB}: $instanceStateB"
        done

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o nome de tag de todas as instâncias criadas ativas"
        aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].Tags[?Key=='Name'].Value" --output text
    else
        echo "Não existe instâncias ativas ${tagNameInstance}${instanceA} ou ${tagNameInstance}${instanceB}"
    fi
else
    echo "Código não executado"
fi