#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2")
print("EC2 CONTAINER INSTANCE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_instance = "ec2ContainerInstanceTest"
instanceA = "7"
instanceB = "8"
sg_name = "default"
aZ = "us-east-1a"
image_id = "ami-079db87dc4c10ac91"    # Amazon Linux 2023 AMI 2023.3.20231218.0 x86_64 HVM kernel-6.1
instance_type = "t2.micro"
key_pair_name = "keyPairUniversal"
instance_profile_name = "ecs-ec2InstanceIProfile"
cluster_name = "clusterEC2Test1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input(f"Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço EC2")
    ec2 = boto3.resource('ec2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe as instâncias {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
    instances = list(ec2.instances.filter(Filters=[
        {'Name': 'tag:Name', 'Values': [f'{tag_name_instance}{instanceA}', f'{tag_name_instance}{instanceB}']}
    ]))

    if instances:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe uma instância EC2 com o nome de tag {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
        for instance in instances:
            print(instance.tags[0]['Value'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o IP público das instâncias {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
        for instance in instances:
            print(instance.public_ip_address)
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome da tag de todas as instâncias EC2 criadas")
        all_instances = list(ec2.instances.filter(Filters=[{'Name': 'tag-key', 'Values': ['Name']}]))
        for instance in all_instances:
            print(instance.tags[0]['Value'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo os Ids do grupo de segurança e das sub-redes padrões")
        sg_id = list(ec2.security_groups.filter(Filters=[{'Name': 'group-name', 'Values': [sg_name]}]))[0].id
        subnet_id = list(ec2.subnets.filter(Filters=[{'Name': 'availability-zone', 'Values': [aZ]}]))[0].id

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a instância EC2 de nome de tag {tag_name_instance}{instanceA}")
        instance_a = ec2.create_instances(
            ImageId=image_id,
            InstanceType=instance_type,
            KeyName=key_pair_name,
            SecurityGroupIds=[sg_id],
            SubnetId=subnet_id,
            MinCount=1,
            MaxCount=1,
            UserData=f"""#!/bin/bash
                        echo 'EXECUTANDO O SCRIPT BASH'
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Atualizando os pacotes'
                        sudo yum update -y
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Atualizando o sistema'
                        sudo yum upgrade -y
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Criando o diretório do ECS'        
                        sudo mkdir -p /etc/ecs
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Configurando o ECS'  
                        echo "ECS_CLUSTER={cluster_name}" | sudo tee -a /etc/ecs/ecs.config
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Aguardando alguns segundos (TEMPO 1)'  
                        sleep 20
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Instalando o agente do ECS'  
                        sudo yum install -y ecs-init
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Aguardando alguns segundos (TEMPO 2)'
                        sleep 30
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Habilitando o ECS'  
                        sudo systemctl enable ecs
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Aguardando alguns segundos (TEMPO 3)'  
                        sleep 30
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Reiniciando o sistema'  
                        sudo reboot
                        """,
            TagSpecifications=[{'ResourceType': 'instance', 'Tags': [{'Key': 'Name', 'Value': f'{tag_name_instance}{instanceA}'}]}],
            IamInstanceProfile={'Name': instance_profile_name}
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a instância EC2 de nome de tag {tag_name_instance}{instanceB}")
        instance_b = ec2.create_instances(
            ImageId=image_id,
            InstanceType=instance_type,
            KeyName=key_pair_name,
            SecurityGroupIds=[sg_id],
            SubnetId=subnet_id,
            MinCount=1,
            MaxCount=1,
            UserData=f"""#!/bin/bash
                        echo 'EXECUTANDO O SCRIPT BASH'
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Atualizando os pacotes'
                        sudo yum update -y
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Atualizando o sistema'
                        sudo yum upgrade -y
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Criando o diretório do ECS'        
                        sudo mkdir -p /etc/ecs
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Configurando o ECS'  
                        echo "ECS_CLUSTER={cluster_name}" | sudo tee -a /etc/ecs/ecs.config
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Aguardando alguns segundos (TEMPO 1)'  
                        sleep 20
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Instalando o agente do ECS'  
                        sudo yum install -y ecs-init
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Habilitando o ECS'  
                        sudo systemctl enable ecs
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Aguardando alguns segundos (TEMPO 3)'  
                        sleep 60
                        echo '-----//-----//-----//-----//-----//-----//-----'
                        echo 'Reiniciando o sistema'  
                        sudo reboot
                        """,
            TagSpecifications=[{'ResourceType': 'instance', 'Tags': [{'Key': 'Name', 'Value': f'{tag_name_instance}{instanceB}'}]}],
            IamInstanceProfile={'Name': instance_profile_name}
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome da tag de todas as instâncias EC2 criadas")
        all_instances = list(ec2.instances.filter(Filters=[{'Name': 'tag-key', 'Values': ['Name']}]))
        for instance in all_instances:
            print(instance.tags[0]['Value'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o IP público das instâncias {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
        instances = list(ec2.instances.filter(Filters=[
                {'Name': 'tag:Name', 'Values': [f'{tag_name_instance}{instanceA}', f'{tag_name_instance}{instanceB}']}
            ]))
        for instance in instances:
            # instance.wait_until_running()
            print(instance.public_ip_address)
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2")
print("EC2 CONTAINER INSTANCE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_instance = "ec2ContainerInstanceTest"
instanceA = "7"
instanceB = "8"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço EC2")
    ec2 = boto3.resource('ec2')

    condition = ec2.instances.filter(
        Filters=[
            {'Name': 'tag:Name', 'Values': [f'{tag_name_instance}{instanceA}', f'{tag_name_instance}{instanceB}']}
        ]
    )

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe as instâncias {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
    if condition:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome da tag de todas as instâncias EC2 criadas")
        all_instances = list(ec2.instances.filter(Filters=[{'Name': 'tag-key', 'Values': ['Name']}]))
        for instance in all_instances:
            print(instance.tags[0]['Value'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id das instâncias de nome de tag {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
        instance_ids = [instance.id for instance in condition]

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo as instâncias de nome de tag {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
        ec2.instances.filter(InstanceIds=instance_ids).terminate()

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome da tag de todas as instâncias EC2 criadas")
        all_instances = list(ec2.instances.filter(Filters=[{'Name': 'tag-key', 'Values': ['Name']}]))
        for instance in all_instances:
            print(instance.tags[0]['Value'])
    else:
        print(f"Não existe instâncias com o nome de tag {tag_name_instance}{instanceA} ou {tag_name_instance}{instanceB}")
else:
    print("Código não executado")