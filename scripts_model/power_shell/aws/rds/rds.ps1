#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS RDS"
Write-Output "DB CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$dbInstanceName = "dbInstanceTest1"
$dbInstanceClass = "db.t3.micro"
$engine = "postgres"
$engineVersion = "16.1"
$masterUsername = "masterUsernameTest1"
$masterPassword = "masterPasswordTest1"
$allocatedStorage = 20
$storageType = "gp2"
$dbName = "dbTest1"
$periodBackup = 7
$sgName = "default"
$aZ = "us-east-1a"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a instância de banco de nome $dbInstanceName (Ignorando erro)..."
    $erro = "DBInstanceNotFound"
    if ((aws rds describe-db-instances --db-instance-identifier $dbInstanceName --query "DBInstances[].DBInstanceIdentifier" 2>&1) -match $erro)
    {$condition = 0} 
    else{$condition = (aws rds describe-db-instances --db-instance-identifier $dbInstanceName --query "DBInstances[].DBInstanceIdentifier").Count}

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a instância de banco de nome $dbInstanceName"
    if ($condition -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe a instância de banco de nome $dbInstanceName"
        aws rds describe-db-instances --db-instance-identifier $dbInstanceName --query "DBInstances[].DBInstanceIdentifier" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as instâncias de banco criadas"
        aws rds describe-db-instances --query "DBInstances[].DBInstanceIdentifier" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id dos elementos de rede"
        $sgId = aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --output text
        $subnetId = aws ec2 describe-subnets --query "Subnets[?AvailabilityZone=='$aZ'].SubnetId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a instância de banco de nome $dbInstanceName"
        aws rds create-db-instance --db-instance-identifier $dbInstanceName --db-instance-class $dbInstanceClass --engine $engine --engine-version $engineVersion --master-username $masterUsername --master-user-password $masterPassword --allocated-storage $allocatedStorage --storage-type $storageType --db-name $dbName --vpc-security-group-ids $sgId --availability-zone $aZ --backup-retention-period $periodBackup --no-cli-pager
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a instância de banco de nome $dbInstanceName"
        aws rds describe-db-instances --db-instance-identifier $dbInstanceName --query "DBInstances[].DBInstanceIdentifier" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS RDS"
Write-Output "DB EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$dbInstanceName = "dbInstanceTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a instância de banco de nome $dbInstanceName (Ignorando erro)..."
    $erro = "DBInstanceNotFound"
    if ((aws rds describe-db-instances --db-instance-identifier $dbInstanceName --query "DBInstances[].DBInstanceIdentifier" 2>&1) -match $erro)
    {$condition = 0} 
    else{$condition = (aws rds describe-db-instances --db-instance-identifier $dbInstanceName --query "DBInstances[].DBInstanceIdentifier").Count}

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a instância de banco de nome $dbInstanceName"
    if ($condition -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as instâncias de banco criadas"
        aws rds describe-db-instances --query "DBInstances[].DBInstanceIdentifier" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a instância de banco de nome $dbInstanceName"
        aws rds delete-db-instance --db-instance-identifier $dbInstanceName --skip-final-snapshot --delete-automated-backups --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as instâncias de banco criadas"
        aws rds describe-db-instances --query "DBInstances[].DBInstanceIdentifier" --output text
    } else {Write-Output "Não existe a instância de banco de nome $dbInstanceName"}
} else {Write-Host "Código não executado"}