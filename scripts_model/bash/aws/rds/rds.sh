#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS RDS"
echo "DB CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
dbInstanceName="dbInstanceTest1"
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
aZ="us-east-1a"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância de banco de nome $dbInstanceName (Ignorando erro)..."
    erro="DBInstanceNotFound"
    if aws rds describe-db-instances --db-instance-identifier $dbInstanceName --query "DBInstances[].DBInstanceIdentifier" 2>&1 | grep -q "$erro"; then
        condition=0
    else
        condition=$(aws rds describe-db-instances --db-instance-identifier $dbInstanceName --query "DBInstances[].DBInstanceIdentifier" --output text | wc -l)
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância de banco de nome $dbInstanceName"
    if [ $condition -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe a instância de banco de nome $dbInstanceName"
        aws rds describe-db-instances --db-instance-identifier $dbInstanceName --query "DBInstances[].DBInstanceIdentifier" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as instâncias de banco criadas"
        aws rds describe-db-instances --query "DBInstances[].DBInstanceIdentifier" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o Id dos elementos de rede"
        sgId=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --output text)
        subnetId=$(aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$aZ'].SubnetId" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando a instância de banco de nome $dbInstanceName"
        aws rds create-db-instance --db-instance-identifier $dbInstanceName --db-instance-class $dbInstanceClass --engine $engine --engine-version $engineVersion --master-username $masterUsername --master-user-password $masterPassword --allocated-storage $allocatedStorage --storage-type $storageType --db-name $dbName --vpc-security-group-ids $sgId --availability-zone $aZ --backup-retention-period $periodBackup --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando a instância de banco de nome $dbInstanceName"
        aws rds describe-db-instances --db-instance-identifier $dbInstanceName --query "DBInstances[].DBInstanceIdentifier" --output text
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
dbInstanceName="dbInstanceTest1"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância de banco de nome $dbInstanceName (Ignorando erro)..."
    erro="DBInstanceNotFound"
    if aws rds describe-db-instances --db-instance-identifier $dbInstanceName --query "DBInstances[].DBInstanceIdentifier" 2>&1 | grep -q "$erro"; then
        condition=0
    else
        condition=$(aws rds describe-db-instances --db-instance-identifier $dbInstanceName --query "DBInstances[].DBInstanceIdentifier" --output text | wc -l)
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe a instância de banco de nome $dbInstanceName"
    if [ $condition -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as instâncias de banco criadas"
        aws rds describe-db-instances --query "DBInstances[].DBInstanceIdentifier" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo a instância de banco de nome $dbInstanceName"
        aws rds delete-db-instance --db-instance-identifier $dbInstanceName --skip-final-snapshot --delete-automated-backups --no-cli-pager

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando todas as instâncias de banco criadas"
        aws rds describe-db-instances --query "DBInstances[].DBInstanceIdentifier" --output text
    else
        echo "Não existe a instância de banco de nome $dbInstanceName"
    fi
else
    echo "Código não executado"
fi