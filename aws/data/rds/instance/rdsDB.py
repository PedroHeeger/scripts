#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS RDS")
print("DB CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
db_instance_id = "rdsInstanceTest1"
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
az = "us-east-1a"
tag_name = "rdsInstanceTest1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a instância de banco de dados ativa {db_instance_id} (Ignorando erro)...")
    try:
        client = boto3.client('rds')
        response = client.describe_db_instances(DBInstanceIdentifier=db_instance_id)
        condition = response['DBInstances'][0]['DBInstanceStatus']
    except client.exceptions.DBInstanceNotFoundFault:
        condition = 0

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a instância de banco de dados ativa {db_instance_id}")
    excluded_status = ["deleting", "failed", "stopped", "stopping", 0]
    if condition not in excluded_status:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe a instância de banco de dados ativa {db_instance_id}")
        print(response['DBInstances'][0]['DBInstanceIdentifier'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o endpoint da instância de banco de dados ativa {db_instance_id}")
        if 'Endpoint' in response['DBInstances'][0] and 'Address' in response['DBInstances'][0]['Endpoint']:
            endpoint = response['DBInstances'][0]['Endpoint']['Address']
            print(f"Endpoint da instância de banco de dados {db_instance_id}: {endpoint}")
        else:
            print(f"A instância {db_instance_id} não possui endpoint ainda.")
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as instâncias de banco de dados criadas ativas")
        valid_statuses = ['available', 'backing-up', 'creating', 'modifying', 'starting', 'upgrading', 'renaming', 'rebooting', 'maintenance', 'Configuring-enhanced-monitoring']
        response = client.describe_db_instances()
        for instance in response['DBInstances']:
            if instance['DBInstanceStatus'] in valid_statuses:
                print(instance['DBInstanceIdentifier'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo o Id dos elementos de rede")
        client_ec2 = boto3.client('ec2')
        sg_id = client_ec2.describe_security_groups(GroupNames=[sg_name])['SecurityGroups'][0]['GroupId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a instância de banco de dados {db_instance_id}")
        client.create_db_instance(
            DBInstanceIdentifier=db_instance_id,
            DBInstanceClass=db_instance_class,
            Engine=engine,
            EngineVersion=engine_version,
            MasterUsername=master_username,
            MasterUserPassword=master_password,
            AllocatedStorage=allocated_storage,
            StorageType=storage_type,
            DBName=db_name,
            VpcSecurityGroupIds=[sg_id],
            AvailabilityZone=az,
            BackupRetentionPeriod=period_backup,
            Tags=[{'Key': 'Name', 'Value': tag_name}]
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a instância de banco de dados ativa {db_instance_id}")
        response = client.describe_db_instances(DBInstanceIdentifier=db_instance_id)
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
db_instance_id = "rdsInstanceTest1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a instância de banco de dados ativa {db_instance_id} (Ignorando erro)...")
    try:
        client = boto3.client('rds')
        response = client.describe_db_instances(DBInstanceIdentifier=db_instance_id)
        condition = response['DBInstances'][0]['DBInstanceStatus']
    except client.exceptions.DBInstanceNotFoundFault:
        condition = 0

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a instância de banco de dados ativa {db_instance_id}")
    excluded_status = ["deleting", "failed", "stopped", "stopping", 0]
    if condition not in excluded_status:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as instâncias de banco de dados criadas ativas")
        valid_statuses = ['available', 'backing-up', 'creating', 'modifying', 'starting', 'upgrading', 'renaming', 'rebooting', 'maintenance', 'Configuring-enhanced-monitoring']
        response = client.describe_db_instances()
        for instance in response['DBInstances']:
            if instance['DBInstanceStatus'] in valid_statuses:
                print(instance['DBInstanceIdentifier'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a instância de banco de dados ativa {db_instance_id}")
        client.delete_db_instance(
            DBInstanceIdentifier=db_instance_id,
            SkipFinalSnapshot=True,
            DeleteAutomatedBackups=True
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todas as instâncias de banco de dados criadas ativas")
        valid_statuses = ['available', 'backing-up', 'creating', 'modifying', 'starting', 'upgrading', 'renaming', 'rebooting', 'maintenance', 'Configuring-enhanced-monitoring']
        response = client.describe_db_instances()
        for instance in response['DBInstances']:
            if instance['DBInstanceStatus'] in valid_statuses:
                print(instance['DBInstanceIdentifier'])
    else:
        print(f"Não existe a instância de banco de dados ativa {db_instance_id}")
else:
    print("Código não executado")