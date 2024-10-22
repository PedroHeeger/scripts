#!/usr/bin/env python3

import boto3
import time
import os

print("***********************************************")
print("SERVIÇO: AWS EC2")
print("INSTANCE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_instance = "ec2Test1"
sg_name = "default"
az = "us-east-1a"
image_id = "ami-0c7217cdde317cfec"  # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
so = "ubuntu"
# so = "ec2-user"
instance_type = "t2.micro"
key_pair_path = "G:/Meu Drive/4_PROJ/scripts/aws/.default/secrets/awsKeyPair/universal"
key_pair_name = "keyPairUniversal"
user_data_path = "G:/Meu Drive/4_PROJ/scripts/aws/compute/ec2/userData/basic/"
user_data_file = "udFile.sh"
# device_name = "/dev/xvda"
device_name = "/dev/sda1"
volume_size = 8
volume_type = "gp2"
instance_profile_name = "instanceProfileTest"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe uma instância ativa de nome de tag {tag_name_instance}")
    ec2_client = boto3.client('ec2')
    
    condition = ec2_client.describe_instances(
        Filters=[
            {'Name': 'tag:Name', 'Values': [tag_name_instance]},
            {'Name': 'instance-state-name', 'Values': ['running']}
        ]
    )
    
    if len(condition['Reservations']) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe uma instância ativa de nome de tag {tag_name_instance}")
        active_instance = condition['Reservations'][0]['Instances'][0]
        print(active_instance['Tags'][0]['Value'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o IP público da instância ativa de nome de tag {tag_name_instance}")
        instance_ip = active_instance['NetworkInterfaces'][0]['Association']['PublicIp']
        print(instance_ip)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da instância ativa de nome de tag {tag_name_instance}")
        instance_id = active_instance['InstanceId']
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Exibindo o comando para acesso remoto via SSH ou AWS SSM")
        print(f"ssh -i \"{key_pair_path}/{key_pair_name}.pem\" {so}@{instance_ip}")
        print(f"aws ssm start-session --target {instance_id}")
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome de tag de todas as instâncias criadas ativas")
        all_active_instances = ec2_client.describe_instances(
            Filters=[{'Name': 'instance-state-name', 'Values': ['running']}]
        )
        for reservation in all_active_instances['Reservations']:
            for instance in reservation['Instances']:
                print(instance['Tags'][0]['Value'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo o Id dos elementos de rede")
        sg_id = ec2_client.describe_security_groups(
            Filters=[{'Name': 'group-name', 'Values': [sg_name]}]
        )['SecurityGroups'][0]['GroupId']
        
        subnet_id = ec2_client.describe_subnets(
            Filters=[{'Name': 'availabilityZone', 'Values': [az]}]
        )['Subnets'][0]['SubnetId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a instância de nome de tag {tag_name_instance}")
        instance_response = ec2_client.run_instances(
            ImageId=image_id,
            InstanceType=instance_type,
            KeyName=key_pair_name,
            SecurityGroupIds=[sg_id],
            SubnetId=subnet_id,
            MinCount=1,
            MaxCount=1,
            UserData=open(os.path.join(user_data_path, user_data_file)).read(),
            TagSpecifications=[{
                'ResourceType': 'instance',
                'Tags': [{'Key': 'Name', 'Value': tag_name_instance}]
            }],
            BlockDeviceMappings=[{
                'DeviceName': device_name,
                'Ebs': {
                    'VolumeSize': volume_size,
                    'VolumeType': volume_type
                }
            }],
            # IamInstanceProfile={instance_profile_name}
        )
        instance_id = instance_response['Instances'][0]['InstanceId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Aguardando a instância criada entrar em execução")
        instance_state = ""
        while instance_state != "running":
            time.sleep(20)
            instance_state = ec2_client.describe_instances(
                InstanceIds=[instance_id]
            )['Reservations'][0]['Instances'][0]['State']['Name']
            print(f"Estado atual da instância: {instance_state}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome de tag de todas as instâncias criadas ativas")
        all_active_instances = ec2_client.describe_instances(
            Filters=[{'Name': 'instance-state-name', 'Values': ['running']}]
        )
        for reservation in all_active_instances['Reservations']:
            for instance in reservation['Instances']:
                print(instance['Tags'][0]['Value'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o IP público da instância ativa de nome de tag {tag_name_instance}")
        instance_ip = ec2_client.describe_instances(
            Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]},
                     {'Name': 'instance-state-name', 'Values': ['running']}]
        )['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']
        print(instance_ip)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Exibindo o comando para acesso remoto via SSH ou AWS SSM")
        print(f"ssh -i \"{key_pair_path}/{key_pair_name}.pem\" {so}@{instance_ip}")
        print(f"aws ssm start-session --target {instance_id}")
else:
    print("Código não executado")




#!/usr/bin/env python3

import boto3
import time

print("***********************************************")
print("SERVIÇO: AWS EC2")
print("INSTANCE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_instance = "ec2Test1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe uma instância ativa de nome de tag {tag_name_instance}")
    ec2_client = boto3.client('ec2')
    
    condition = ec2_client.describe_instances(
        Filters=[
            {'Name': 'tag:Name', 'Values': [tag_name_instance]},
            {'Name': 'instance-state-name', 'Values': ['running']}
        ]
    )
    
    if len(condition['Reservations']) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome de tag de todas as instâncias criadas ativas")
        all_active_instances = ec2_client.describe_instances(
            Filters=[{'Name': 'instance-state-name', 'Values': ['running']}]
        )
        for reservation in all_active_instances['Reservations']:
            for instance in reservation['Instances']:
                print(instance['Tags'][0]['Value'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da instância de nome de tag {tag_name_instance}")
        instance_id = condition['Reservations'][0]['Instances'][0]['InstanceId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a instância de nome de tag {tag_name_instance}")
        ec2_client.terminate_instances(InstanceIds=[instance_id], DryRun=False)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Aguardando a instância ser removida")
        instance_state = ""
        while instance_state != "terminated":
            time.sleep(20)
            instance_state = ec2_client.describe_instances(
                InstanceIds=[instance_id]
            )['Reservations'][0]['Instances'][0]['State']['Name']
            print(f"Estado atual da instância: {instance_state}")
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome de tag de todas as instâncias criadas ativas")
        all_active_instances = ec2_client.describe_instances(
            Filters=[{'Name': 'instance-state-name', 'Values': ['running']}]
        )
        for reservation in all_active_instances['Reservations']:
            for instance in reservation['Instances']:
                print(instance['Tags'][0]['Value'])
    else:
        print(f"Não existe uma instância ativa com o nome de tag {tag_name_instance}")
else:
    print("Código não executado")

























































# #!/usr/bin/env python

# import boto3
# from botocore.exceptions import ClientError

# print("***********************************************")
# print("SERVIÇO: AWS EC2")
# print("EC2 CREATION")

# print("-----//-----//-----//-----//-----//-----//-----")
# print("Definindo variáveis")
# tag_name_instance = "ec2Test1"
# sg_name = "default"
# aZ = "us-east-1a"
# image_id = "ami-0c7217cdde317cfec"    # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
# instance_type = "t2.micro"
# key_pair_path = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/secrets/awsKeyPair"
# key_pair_name = "keyPairUniversal"
# user_data_path = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/aws/ec2_userData/basic"
# user_data_file = "udFile.sh"
# # $device_name = "/dev/xvda" 
# device_name = "/dev/sda1"
# volume_size = 8
# volume_type = "gp2"
# instance_profile_name = "instanceProfileTest"

# print("-----//-----//-----//-----//-----//-----//-----")
# resposta = input("Deseja executar o código? (y/n) ")
# if resposta.lower() == 'y':
#     try:
#         print("-----//-----//-----//-----//-----//-----//-----")
#         print(f"Criando um objeto de recurso para o serviço EC2")
#         ec2 = boto3.resource('ec2')

#         print("-----//-----//-----//-----//-----//-----//-----")
#         print(f"Verificando se existe a instância {tag_name_instance}")
#         instances = list(ec2.instances.filter(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}]))
#         if instances:
#             print("-----//-----//-----//-----//-----//-----//-----")
#             print(f"Já existe uma instância EC2 com o nome de tag {tag_name_instance}")
#             for instance in instances:
#                 print(f"ID da Instância: {instance.id}")
#                 print(f"IP Público: {instance.public_ip_address}")

#                 print("-----//-----//-----//-----//-----//-----//-----")
#                 print("Exibindo o comando para acesso remoto via OpenSSH")
#                 ip_ec2 = instance.public_ip_address
#                 print(f'ssh -i "{key_pair_path}/{key_pair_name}.pem" ubuntu@{ip_ec2}')
#         else:
#             print("-----//-----//-----//-----//-----//-----//-----")
#             print("Listando o nome da tag de todas as instâncias EC2 criadas")
#             for instance in ec2.instances.all():
#                 for tag in instance.tags:
#                     if tag['Key'] == 'Name':
#                         print(f"Nome da Instância: {tag['Value']}")

#             print("-----//-----//-----//-----//-----//-----//-----")
#             print("Extraindo o Id dos elementos de rede")
#             sg_id = list(ec2.security_groups.filter(Filters=[{'Name': 'group-name', 'Values': [sg_name]}]))[0].id
#             subnet_id = list(ec2.subnets.filter(Filters=[{'Name': 'availabilityZone', 'Values': [aZ]}]))[0].id

#             print("-----//-----//-----//-----//-----//-----//-----")
#             print(f"Criando a instância EC2 de nome de tag {tag_name_instance}")
#             instances = ec2.create_instances(
#                 ImageId=image_id,
#                 InstanceType=instance_type,
#                 KeyName=key_pair_name,
#                 SecurityGroupIds=[sg_id],
#                 SubnetId=subnet_id,
#                 MinCount=1,
#                 MaxCount=1,
#                 UserData=open(f"{user_data_path}/{user_data_file}", "r").read(),
#                 BlockDeviceMappings=[
#                     {
#                         'DeviceName': device_name,
#                         'Ebs': {
#                             'VolumeSize': volume_size,
#                             'VolumeType': volume_type,
#                         },
#                     },
#                 ],
#                 TagSpecifications=[{
#                     'ResourceType': 'instance',
#                     'Tags': [{'Key': 'Name', 'Value': tag_name_instance}]
#                 }]
#             )

#             # print("-----//-----//-----//-----//-----//-----//-----")
#             # print(f"Criando a instância EC2 de nome de tag {tag_name_instance}")
#             # instances = ec2.create_instances(
#             #     ImageId=image_id,
#             #     InstanceType=instance_type,
#             #     KeyName=key_pair_name,
#             #     SecurityGroupIds=[sg_id],
#             #     SubnetId=subnet_id,
#             #     MinCount=1,
#             #     MaxCount=1,
#             #     UserData=open(f"{user_data_path}/{user_data_file}", "r").read(),
#             #     BlockDeviceMappings=[
#             #         {
#             #             'DeviceName': '/dev/xvda',
#             #             'Ebs': {
#             #                 'VolumeSize': volume_size,
#             #                 'VolumeType': volume_type,
#             #             },
#             #         },
#             #     ],
#             #     IamInstanceProfile={
#             #         'Name': instance_profile_name,
#             #     },
#             #     TagSpecifications=[{
#             #         'ResourceType': 'instance',
#             #         'Tags': [{'Key': 'Name', 'Value': tag_name_instance}]
#             #     }]
#             # )

#             print("-----//-----//-----//-----//-----//-----//-----")
#             print("Listando o nome da tag de todas as instâncias EC2 criadas")
#             for instance in ec2.instances.all():
#                 for tag in instance.tags:
#                     if tag['Key'] == 'Name':
#                         print(f"Nome da Instância: {tag['Value']}")

#             print("-----//-----//-----//-----//-----//-----//-----")
#             print(f"Listando o IP público da instância {tag_name_instance}")
#             instances = list(ec2.instances.filter(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}]))
#             for instance in instances:
#                 print(f"ID da Instância: {instance.id}")
#                 print(f"IP Público: {instance.public_ip_address}")

#                 print("-----//-----//-----//-----//-----//-----//-----")
#                 print("Exibindo o comando para acesso remoto via OpenSSH")
#                 ip_ec2 = instance.public_ip_address
#                 print(f'ssh -i "{key_pair_path}/{key_pair_name}.pem" ubuntu@{ip_ec2}')

#     except ClientError as e:
#         print(f"Erro ao interagir com a AWS: {e}")
# else:
#     print("Código não executado")




# #!/usr/bin/env python
    
# import boto3
# from botocore.exceptions import ClientError

# print("***********************************************")
# print("SERVIÇO: AWS EC2")
# print("EC2 EXCLUSION")

# print("-----//-----//-----//-----//-----//-----//-----")
# print("Definindo variáveis")
# tag_name_instance = "ec2Test1"

# print("-----//-----//-----//-----//-----//-----//-----")
# resposta = input("Deseja executar o código? (y/n) ")
# if resposta.lower() == 'y':
#     try:
#         print("-----//-----//-----//-----//-----//-----//-----")
#         print(f"Criando um objeto de recurso para o serviço EC2")
#         ec2 = boto3.resource('ec2')

#         print("-----//-----//-----//-----//-----//-----//-----")
#         print(f"Criando um cliente para o serviço EC2")
#         client = boto3.client('ec2')

#         print("-----//-----//-----//-----//-----//-----//-----")
#         print(f"Verificando se existe a instância {tag_name_instance}")
#         instances = list(ec2.instances.filter(Filters=[
#             {'Name': 'tag:Name', 'Values': [tag_name_instance]},
#             {'Name': 'instance-state-name', 'Values': 'running'}
#         ]))
        
#         if instances:
#             print("-----//-----//-----//-----//-----//-----//-----")
#             print(f"Listando o nome da tag de todas as instâncias EC2 criadas")
#             for instance in ec2.instances.all():
#                 for tag in instance.tags:
#                     if tag['Key'] == 'Name':
#                         print(f"Nome da Instância: {tag['Value']}")
            
#             print("-----//-----//-----//-----//-----//-----//-----")
#             print(f"Extraindo o Id da instância de nome de tag {tag_name_instance}")
#             instance_id = instances[0].id
            
#             print("-----//-----//-----//-----//-----//-----//-----")
#             print(f"Removendo a instância de nome de tag {tag_name_instance}")
#             client.terminate_instances(InstanceIds=[instance_id], DryRun=False)
            
#             print("-----//-----//-----//-----//-----//-----//-----")
#             print(f"Listando o nome da tag de todas as instâncias EC2 criadas")
#             for instance in ec2.instances.all():
#                 for tag in instance.tags:
#                     if tag['Key'] == 'Name':
#                         print(f"Nome da Instância: {tag['Value']}")
#         else:
#             print("-----//-----//-----//-----//-----//-----//-----")
#             print(f"Não existe instâncias com o nome de tag {tag_name_instance}")

#     except ClientError as e:
#         print(f"Erro ao interagir com a AWS: {e}")
# else:
#     print("Código não executado")