#!/usr/bin/env python

import boto3
from botocore.exceptions import ClientError

print("***********************************************")
print("SERVIÇO: AWS EC2")
print("EC2 CREATION WITH DOCKER AND AWS CLI")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_instance = "ec2Test1"
sg_name = "default"
aZ = "us-east-1a"
image_id = "ami-0c7217cdde317cfec"  # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
instance_type = "t2.micro"
key_pair_name = "keyPairUniversal"
user_data_path = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/aws/ec2_userData/aws_dock"
user_data_file = "udFile.sh"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um objeto de recurso para o serviço EC2")
        ec2 = boto3.resource('ec2')

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a instância {tag_name_instance}")
        instances = list(ec2.instances.filter(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}]))
        if instances:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe uma instância EC2 com o nome de tag {tag_name_instance}")
            for instance in instances:
                print(f"ID da Instância: {instance.id}")
                print(f"IP Público: {instance.public_ip_address}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando o nome da tag de todas as instâncias EC2 criadas")
            for instance in ec2.instances.all():
                for tag in instance.tags:
                    if tag['Key'] == 'Name':
                        print(f"Nome da Instância: {tag['Value']}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Extraindo os Ids do grupo de segurança e sub-redes padrões")
            sg_id = list(ec2.security_groups.filter(Filters=[{'Name': 'group-name', 'Values': [sg_name]}]))[0].id
            subnet_id = list(ec2.subnets.filter(Filters=[{'Name': 'availabilityZone', 'Values': [aZ]}]))[0].id

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando a instância EC2 de nome de tag {tag_name_instance}")
            instances = ec2.create_instances(
                ImageId=image_id,
                InstanceType=instance_type,
                KeyName=key_pair_name,
                SecurityGroupIds=[sg_id],
                SubnetId=subnet_id,
                MinCount=1,
                MaxCount=1,
                UserData=open(f"{user_data_path}/{user_data_file}", "r").read(),
                TagSpecifications=[{
                    'ResourceType': 'instance',
                    'Tags': [{'Key': 'Name', 'Value': tag_name_instance}]
                }]
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando o nome da tag de todas as instâncias EC2 criadas")
            for instance in ec2.instances.all():
                for tag in instance.tags:
                    if tag['Key'] == 'Name':
                        print(f"Nome da Instância: {tag['Value']}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o IP público da instância {tag_name_instance}")
            instances = list(ec2.instances.filter(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}]))
            for instance in instances:
                print(f"ID da Instância: {instance.id}")
                print(f"IP Público: {instance.public_ip_address}")

    except ClientError as e:
        print(f"Erro ao interagir com a AWS: {e}")
else:
    print("Código não executado")




#!/usr/bin/env python
    
import boto3
from botocore.exceptions import ClientError

print("***********************************************")
print("SERVIÇO: AWS EC2")
print("EC2 EXCLUSION WITH DOCKER AND AWS CLI")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_instance = "ec2Test1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um objeto de recurso para o serviço EC2")
        ec2 = boto3.resource('ec2')

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um cliente para o serviço EC2")
        client = boto3.client('ec2')

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a instância {tag_name_instance}")
        instances = list(ec2.instances.filter(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}]))
        
        if instances:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o nome da tag de todas as instâncias EC2 criadas")
            for instance in ec2.instances.all():
                for tag in instance.tags:
                    if tag['Key'] == 'Name':
                        print(f"Nome da Instância: {tag['Value']}")
            
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o Id da instância de nome de tag {tag_name_instance}")
            instance_id = instances[0].id
            
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo a instância de nome de tag {tag_name_instance}")
            client.terminate_instances(InstanceIds=[instance_id], DryRun=False)
            
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o nome da tag de todas as instâncias EC2 criadas")
            for instance in ec2.instances.all():
                for tag in instance.tags:
                    if tag['Key'] == 'Name':
                        print(f"Nome da Instância: {tag['Value']}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Não existe instâncias com o nome de tag {tag_name_instance}")

    except ClientError as e:
        print(f"Erro ao interagir com a AWS: {e}")
else:
    print("Código não executado")