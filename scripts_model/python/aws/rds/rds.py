#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS RDS")
print("DB CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
db_instance_name = "dbInstanceTest1"
db_instance_class = "db.t3.micro"
engine = "postgres"
engine_version = "16.1"
master_username = "masterUsernameTest1"
master_password = "masterPasswordTest1"
allocated_storage = 20
storage_type = "gp2"
db_name = "dbTest1"
period_backup = 7
sg_name = "default"
aZ = "us-east-1a"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")

if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a instância de banco de nome {db_instance_name} (Ignorando erro)...")
    erro = "DBInstanceNotFound"
    try:
        client = boto3.client('rds')
        response = client.describe_db_instances(DBInstanceIdentifier=db_instance_name)
        condition = len(response['DBInstances'])
    except client.exceptions.DBInstanceNotFoundFault:
        condition = 0

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a instância de banco de nome {db_instance_name}")
    if condition > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe a instância de banco de nome {db_instance_name}")
        print(response['DBInstances'][0]['DBInstanceIdentifier'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as instâncias de banco criadas")
        response = client.describe_db_instances()
        for instance in response['DBInstances']:
            print(instance['DBInstanceIdentifier'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo o Id dos elementos de rede")
        client_ec2 = boto3.client('ec2')
        sg_id = client_ec2.describe_security_groups(GroupNames=[sg_name])['SecurityGroups'][0]['GroupId']
        subnet_id = client_ec2.describe_subnets(Filters=[{'Name': 'availabilityZone', 'Values': [aZ]}])['Subnets'][0]['SubnetId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a instância de banco de nome {db_instance_name}")
        client.create_db_instance(
            DBInstanceIdentifier=db_instance_name,
            DBInstanceClass=db_instance_class,
            Engine=engine,
            EngineVersion=engine_version,
            MasterUsername=master_username,
            MasterUserPassword=master_password,
            AllocatedStorage=allocated_storage,
            StorageType=storage_type,
            DBName=db_name,
            VpcSecurityGroupIds=[sg_id],
            AvailabilityZone=aZ,
            BackupRetentionPeriod=period_backup
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a instância de banco de nome {db_instance_name}")
        response = client.describe_db_instances(DBInstanceIdentifier=db_instance_name)
        print(response['DBInstances'][0]['DBInstanceIdentifier'])
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3

print("***********************************************")
print("SERVIÇO: AWS RDS")
print("DB EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
db_instance_name = "dbInstanceTest1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")

if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a instância de banco de nome {db_instance_name} (Ignorando erro)...")
    erro = "DBInstanceNotFound"
    try:
        client = boto3.client('rds')
        response = client.describe_db_instances(DBInstanceIdentifier=db_instance_name)
        condition = len(response['DBInstances'])
    except client.exceptions.DBInstanceNotFoundFault:
        condition = 0

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a instância de banco de nome {db_instance_name}")
    if condition > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as instâncias de banco criadas")
        response = client.describe_db_instances()
        for instance in response['DBInstances']:
            print(instance['DBInstanceIdentifier'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a instância de banco de nome {db_instance_name}")
        client.delete_db_instance(
            DBInstanceIdentifier=db_instance_name,
            SkipFinalSnapshot=True,
            DeleteAutomatedBackups=True
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as instâncias de banco criadas")
        response = client.describe_db_instances()
        for instance in response['DBInstances']:
            print(instance['DBInstanceIdentifier'])
    else:
        print(f"Não existe a instância de banco de nome {db_instance_name}")
else:
    print("Código não executado")