#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS RDS"
echo "DB CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
dbInstanceId="rdsInstanceTest1"
dbInstanceClass="db.t3.micro"
engine="postgres"
engineVersion="16.1"
masterUsername="masterUsernameTest1"
masterPassword="masterPasswordTest1"
allocatedStorage=20
storageType="gp2"
dbName="dbTest1"
periodBackup=7
sgName="default"
az="us-east-1a"
tagName="rdsInstanceTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância de banco de dados ativa $dbInstanceId (Ignorando erro)..."
    erro="DBInstanceNotFound"
    condition=(aws rds describe-db-instances --db-instance-identifier $dbInstanceId --query "DBInstances[].DBInstanceStatus" --output text) 2>&1
    if $condition | grep -q "$erro"; then
        condition=0
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância de banco de dados ativa $dbInstanceId"
    excludedStatus=("deleting" "failed" "stopped" "stopping" "0")
    if [[ ! " ${excludedStatus[@]} " =~ " $condition " ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe a instância de banco de dados ativa $dbInstanceId"
        aws rds describe-db-instances --db-instance-identifier $dbInstanceId --query "DBInstances[].DBInstanceIdentifier" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o endpoint da instância de banco de dados ativa $dbInstanceId"
        aws rds describe-db-instances --db-instance-identifier $dbInstanceId --query "DBInstances[].Endpoint[].Address" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as instâncias de banco de dados criadas ativas"
        aws rds describe-db-instances --query "DBInstances[?contains(['available', 'backing-up', 'creating', 'modifying', 'starting', 'upgrading', 'renaming', 'rebooting', 'maintenance', 'Configuring-enhanced-monitoring'], DBInstanceStatus)].DBInstanceIdentifier" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id dos elementos de rede"
        sgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a instância de banco de dados $dbInstanceId"
        aws rds create-db-instance --db-instance-identifier $dbInstanceId --db-instance-class $dbInstanceClass --engine $engine --engine-version $engineVersion --master-username $masterUsername --master-user-password $masterPassword --allocated-storage $allocatedStorage --storage-type $storageType --db-name $dbName --vpc-security-group-ids $sgId --availability-zone $az --backup-retention-period $periodBackup --tags "Key=Name,Value=$tagName" --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a instância de banco de dados ativa $dbInstanceId"
        aws rds describe-db-instances --db-instance-identifier $dbInstanceId --query "DBInstances[].DBInstanceIdentifier" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS RDS"
echo "DB EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
dbInstanceId="rdsInstanceTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância de banco de dados ativa $dbInstanceId (Ignorando erro)..."
    erro="DBInstanceNotFound"
    condition=(aws rds describe-db-instances --db-instance-identifier $dbInstanceId --query "DBInstances[].DBInstanceStatus" --output text) 2>&1
    if $condition | grep -q "$erro"; then
        condition=0
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância de banco de dados ativa $dbInstanceId"
    excludedStatus=("deleting" "failed" "stopped" "stopping" "0")
    if [[ ! " ${excludedStatus[@]} " =~ " $condition " ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as instâncias de banco de dados criadas ativas"
        aws rds describe-db-instances --query "DBInstances[?contains(['available', 'backing-up', 'creating', 'modifying', 'starting', 'upgrading', 'renaming', 'rebooting', 'maintenance', 'Configuring-enhanced-monitoring'], DBInstanceStatus)].DBInstanceIdentifier" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a instância de banco de dados ativa $dbInstanceId"
        aws rds delete-db-instance --db-instance-identifier $dbInstanceId --skip-final-snapshot --delete-automated-backups --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as instâncias de banco de dados criadas ativas"
        aws rds describe-db-instances --query "DBInstances[?contains(['available', 'backing-up', 'creating', 'modifying', 'starting', 'upgrading', 'renaming', 'rebooting', 'maintenance', 'Configuring-enhanced-monitoring'], DBInstanceStatus)].DBInstanceIdentifier" --output text
    else
        echo "Não existe a instância de banco de dados ativa $dbInstanceId"
    fi
else
    echo "Código não executado"
fi