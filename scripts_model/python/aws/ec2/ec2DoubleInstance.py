#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2")
print("EC2 DOUBLE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_instance = "ec2Test"
instanceA = "1"
instanceB = "2"
sg_name = "default"
aZ = "us-east-1a"
image_id = "ami-0c7217cdde317cfec"    # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
instance_type = "t2.micro"
key_pair_path = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/secrets/awsKeyPair"
key_pair_name = "keyPairUniversal"
user_data_path = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/aws/ec2_userData/basic"
user_data_file = "udFile.sh"
device_name = "/dev/sda1"
volume_size = 8
volume_type = "gp2"

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

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Exibindo o comando para acesso remoto via OpenSSH")
            ip_ec2 = instance.public_ip_address
            print(f'ssh -i "{key_pair_path}/{key_pair_name}.pem" ubuntu@{ip_ec2}')
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome da tag de todas as instâncias EC2 criadas")
        all_instances = list(ec2.instances.filter(Filters=[{'Name': 'tag-key', 'Values': ['Name']}]))
        for instance in all_instances:
            print(instance.tags[0]['Value'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo o Id dos elementos de rede")
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
            UserData=open(f"{user_data_path}/{user_data_file}", "r").read(),
            BlockDeviceMappings=[
                {
                    'DeviceName': device_name,
                    'Ebs': {
                        'VolumeSize': volume_size,
                        'VolumeType': volume_type,
                    },
                },
            ],
            TagSpecifications=[{'ResourceType': 'instance', 'Tags': [{'Key': 'Name', 'Value': f'{tag_name_instance}{instanceA}'}]}]
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
            UserData=open(f"{user_data_path}/{user_data_file}", "r").read(),
            BlockDeviceMappings=[
                {
                    'DeviceName': device_name,
                    'Ebs': {
                        'VolumeSize': volume_size,
                        'VolumeType': volume_type,
                    },
                },
            ],
            TagSpecifications=[{'ResourceType': 'instance', 'Tags': [{'Key': 'Name', 'Value': f'{tag_name_instance}{instanceB}'}]}]
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
            instance.wait_until_running()
            print(instance.public_ip_address)

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Exibindo o comando para acesso remoto via OpenSSH")
            ip_ec2 = instance.public_ip_address
            print(f'ssh -i "{key_pair_path}/{key_pair_name}.pem" ubuntu@{ip_ec2}')
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2")
print("EC2 DOUBLE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_instance = "ec2Test"
instanceA = "1"
instanceB = "2"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço EC2")
    ec2 = boto3.resource('ec2')

    condition = ec2.instances.filter(
        Filters=[
            {'Name': 'tag:Name', 'Values': [f'{tag_name_instance}{instanceA}', f'{tag_name_instance}{instanceB}']},
            {'Name': 'instance-state-name', 'Values': 'running'}
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