#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS RDS"
Write-Output "DB CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$dbInstanceId = "rdsInstanceTest1"
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
$az = "us-east-1a"
$tagName = "rdsInstanceTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a instância de banco de dados ativa $dbInstanceId (Ignorando erro)..."
    $erro = "DBInstanceNotFound"
    $condition = (aws rds describe-db-instances --db-instance-identifier $dbInstanceId --query "DBInstances[].DBInstanceStatus" --output text) 2>&1
    if (($condition) -match $erro) {$condition = 0}

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a instância de banco de dados ativa $dbInstanceId"
    $excludedStatus = "deleting", "failed", "stopped", "stopping", 0
    if ($condition -notin $excludedStatus) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe a instância de banco de dados ativa $dbInstanceId"
        aws rds describe-db-instances --db-instance-identifier $dbInstanceId --query "DBInstances[].DBInstanceIdentifier" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando o endpoint da instância de banco de dados ativa $dbInstanceId"
        aws rds describe-db-instances --db-instance-identifier $dbInstanceId --query "DBInstances[].Endpoint[].Address" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as instâncias de banco de dados criadas ativas"
        aws rds describe-db-instances --query "DBInstances[?contains(['available', 'backing-up', 'creating', 'modifying', 'starting', 'upgrading', 'renaming', 'rebooting', 'maintenance', 'Configuring-enhanced-monitoring'], DBInstanceStatus)].DBInstanceIdentifier" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o Id dos elementos de rede"
        $sgId = aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='$sgName'].GroupId" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando a instância de banco de dados $dbInstanceId"
        aws rds create-db-instance --db-instance-identifier $dbInstanceId --db-instance-class $dbInstanceClass --engine $engine --engine-version $engineVersion --master-username $masterUsername --master-user-password $masterPassword --allocated-storage $allocatedStorage --storage-type $storageType --db-name $dbName --vpc-security-group-ids $sgId --availability-zone $az --backup-retention-period $periodBackup --tags "Key=Name,Value=$tagName" --no-cli-pager
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a instância de banco de dados ativa $dbInstanceId"
        aws rds describe-db-instances --db-instance-identifier $dbInstanceId --query "DBInstances[].DBInstanceIdentifier" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS RDS"
Write-Output "DB EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$dbInstanceId = "rdsInstanceTest1"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a instância de banco de dados ativa $dbInstanceId (Ignorando erro)..."
    $erro = "DBInstanceNotFound"
    $condition = (aws rds describe-db-instances --db-instance-identifier $dbInstanceId --query "DBInstances[].DBInstanceStatus" --output text) 2>&1
    if (($condition) -match $erro) {$condition = 0}

    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe a instância de banco de dados ativa $dbInstanceId"
    $excludedStatus = "deleting", "failed", "stopped", "stopping", 0
    if ($condition -notin $excludedStatus) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as instâncias de banco de dados criadas ativas"
        aws rds describe-db-instances --query "DBInstances[?contains(['available', 'backing-up', 'creating', 'modifying', 'starting', 'upgrading', 'renaming', 'rebooting', 'maintenance', 'Configuring-enhanced-monitoring'], DBInstanceStatus)].DBInstanceIdentifier" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo a instância de banco de dados ativa $dbInstanceId"
        aws rds delete-db-instance --db-instance-identifier $dbInstanceId --skip-final-snapshot --delete-automated-backups --no-cli-pager

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas as instâncias de banco de dados criadas ativas"
        aws rds describe-db-instances --query "DBInstances[?contains(['available', 'backing-up', 'creating', 'modifying', 'starting', 'upgrading', 'renaming', 'rebooting', 'maintenance', 'Configuring-enhanced-monitoring'], DBInstanceStatus)].DBInstanceIdentifier" --output text
    } else {Write-Output "Não existe a instância de banco de dados ativa $dbInstanceId"}
} else {Write-Host "Código não executado"}