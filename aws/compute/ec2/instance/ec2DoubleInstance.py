import boto3
import time

print("***********************************************")
print("SERVIÇO: AWS EC2")
print("DOUBLE INSTANCE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tagNameInstance = "ec2Test"
instanceA = "1"
instanceB = "2"
sgName = "default"
az = "us-east-1a"
imageId = "ami-0c7217cdde317cfec"  # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
so = "ubuntu"
# so = "ec2-user"
instanceType = "t2.micro"
keyPairPath = "G:/Meu Drive/4_PROJ/scripts/aws/.default/secrets/awsKeyPair/universal"
keyPairName = "keyPairUniversal"
userDataPath = "G:/Meu Drive/4_PROJ/scripts/aws/compute/ec2/userData/basic/"
userDataFile = "udFile.sh"
# device_name = "/dev/xvda"
deviceName = "/dev/sda1"
volumeSize = 8
volumeType = "gp2"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe as instâncias ativas {tagNameInstance}{instanceA} e {tagNameInstance}{instanceB}")
    ec2 = boto3.client('ec2')
    
    filters = [
        {'Name': 'instance-state-name', 'Values': ['running']},
        {'Name': 'tag:Name', 'Values': [f'{tagNameInstance}{instanceA}', f'{tagNameInstance}{instanceB}']}
    ]

    condition = ec2.describe_instances(Filters=filters)
    instances = condition['Reservations']

    if len(instances) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe as instâncias ativas de nome de tag {tagNameInstance}{instanceA} e {tagNameInstance}{instanceB}")
        for reservation in instances:
            for instance in reservation['Instances']:
                for tag in instance['Tags']:
                    if tag['Key'] == 'Name':
                        print(tag['Value'])
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o IP público das instâncias ativas de nome de tag {tagNameInstance}{instanceA} e {tagNameInstance}{instanceB}")
        for instance in instances:
            for i in instance['Instances']:
                public_ips = i['NetworkInterfaces'][0]['Association'].get('PublicIp', 'N/A')
                print(public_ips)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id das instâncias ativas de nome de tag {tagNameInstance}{instanceA} e {tagNameInstance}{instanceB}")
        instance_ids = [i['InstanceId'] for r in instances for i in r['Instances']]
        instanceIdA = instance_ids[0]
        instanceIdB = instance_ids[1]

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância {tagNameInstance}{instanceA}")
        print(f"ssh -i \"{keyPairPath}/{keyPairName}.pem\" {so}@{public_ips}")
        print(f"aws ssm start-session --target {instanceIdA}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância {tagNameInstance}{instanceB}")
        print(f"ssh -i \"{keyPairPath}/{keyPairName}.pem\" {so}@{public_ips}")
        print(f"aws ssm start-session --target {instanceIdB}")

    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome de tag de todas as instâncias criadas ativas")
        all_active_instances = ec2.describe_instances(
            Filters=[{'Name': 'instance-state-name', 'Values': ['running']}]
        )
        for reservation in all_active_instances['Reservations']:
            for instance in reservation['Instances']:
                print(instance['Tags'][0]['Value'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo o Id dos elementos de rede")
        security_group = ec2.describe_security_groups(
            Filters=[{'Name': 'group-name', 'Values': [sgName]}]
        )
        sgId = security_group['SecurityGroups'][0]['GroupId']

        subnet = ec2.describe_subnets(
            Filters=[{'Name': 'availabilityZone', 'Values': [az]}]
        )
        subnetId = subnet['Subnets'][0]['SubnetId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a instância de nome de tag {tagNameInstance}{instanceA}")
        instanceA_data = ec2.run_instances(
            ImageId=imageId,
            InstanceType=instanceType,
            KeyName=keyPairName,
            SecurityGroupIds=[sgId],
            SubnetId=subnetId,
            UserData=open(userDataPath + userDataFile).read(),
            BlockDeviceMappings=[{
                'DeviceName': deviceName,
                'Ebs': {'VolumeSize': volumeSize, 'VolumeType': volumeType}
            }],
            TagSpecifications=[{'ResourceType': 'instance', 'Tags': [{'Key': 'Name', 'Value': f'{tagNameInstance}{instanceA}'}]}],
            MinCount=1,
            MaxCount=1
        )
        instanceIdA = instanceA_data['Instances'][0]['InstanceId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a instância de nome de tag {tagNameInstance}{instanceB}")
        instanceB_data = ec2.run_instances(
            ImageId=imageId,
            InstanceType=instanceType,
            KeyName=keyPairName,
            SecurityGroupIds=[sgId],
            SubnetId=subnetId,
            UserData=open(userDataPath + userDataFile).read(),
            BlockDeviceMappings=[{
                'DeviceName': deviceName,
                'Ebs': {'VolumeSize': volumeSize, 'VolumeType': volumeType}
            }],
            TagSpecifications=[{'ResourceType': 'instance', 'Tags': [{'Key': 'Name', 'Value': f'{tagNameInstance}{instanceB}'}]}],
            MinCount=1,
            MaxCount=1
        )
        instanceIdB = instanceB_data['Instances'][0]['InstanceId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Aguardando as instâncias criadas entrarem em execução")
        instanceStateA = ''
        instanceStateB = ''

        while instanceStateA != 'running' or instanceStateB != 'running':
            time.sleep(20)
            instanceStateA = ec2.describe_instances(InstanceIds=[instanceIdA])['Reservations'][0]['Instances'][0]['State']['Name']
            print(f"Estado atual da instância {tagNameInstance}{instanceA}: {instanceStateA}")
            instanceStateB = ec2.describe_instances(InstanceIds=[instanceIdB])['Reservations'][0]['Instances'][0]['State']['Name']
            print(f"Estado atual da instância {tagNameInstance}{instanceB}: {instanceStateB}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome de tag de todas as instâncias criadas ativas")
        running_instances = ec2.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
        for r in running_instances['Reservations']:
            for i in r['Instances']:
                for tag in i['Tags']:
                    if tag['Key'] == 'Name':
                        print(tag['Value'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o IP público das instâncias ativas de nome de tag {tagNameInstance}{instanceA} e {tagNameInstance}{instanceB}")
        publicIpA = ec2.describe_instances(InstanceIds=[instanceIdA])['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']
        publicIpB = ec2.describe_instances(InstanceIds=[instanceIdB])['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']
        print(publicIpA)
        print(publicIpB)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância {tagNameInstance}{instanceA}")
        print(f"ssh -i \"{keyPairPath}/{keyPairName}.pem\" {so}@{publicIpA}")
        print(f"aws ssm start-session --target {instanceIdA}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância {tagNameInstance}{instanceB}")
        print(f"ssh -i \"{keyPairPath}/{keyPairName}.pem\" {so}@{publicIpB}")
        print(f"aws ssm start-session --target {instanceIdB}")
else:
    print("Código não executado")




#!/usr/bin/env python3

import boto3
import time

print("***********************************************")
print("SERVIÇO: AWS EC2")
print("DOUBLE INSTANCE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tagNameInstance = "ec2Test"
instanceA = "1"
instanceB = "2"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existem instâncias ativas {tagNameInstance}{instanceA} e {tagNameInstance}{instanceB}")
    ec2_client = boto3.client('ec2')
    filters = [
        {'Name': 'instance-state-name', 'Values': ['running']},
        {'Name': 'tag:Name', 'Values': [f'{tagNameInstance}{instanceA}', f'{tagNameInstance}{instanceB}']}
    ]
    
    response = ec2_client.describe_instances(Filters=filters)
    condition = [instance['Tags'][0]['Value'] for reservation in response['Reservations'] for instance in reservation['Instances']]
    
    if len(condition) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome de tag de todas as instâncias criadas ativas")
        
        all_instances = ec2_client.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
        active_tags = [instance['Tags'][0]['Value'] for reservation in all_instances['Reservations'] for instance in reservation['Instances']]
        print("\n".join(active_tags))

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id das instâncias ativas de nome de tag {tagNameInstance}{instanceA} e {tagNameInstance}{instanceB}")
        
        instanceIdA = None
        instanceIdB = None

        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                tag_name = [tag['Value'] for tag in instance['Tags'] if tag['Key'] == 'Name'][0]
                if tag_name == f"{tagNameInstance}{instanceA}":
                    instanceIdA = instance['InstanceId']
                elif tag_name == f"{tagNameInstance}{instanceB}":
                    instanceIdB = instance['InstanceId']
        
        print(f"InstanceIdA: {instanceIdA}, InstanceIdB: {instanceIdB}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo as instâncias de nome de tag {tagNameInstance}{instanceA} e {tagNameInstance}{instanceB}")
        ec2_client.terminate_instances(InstanceIds=[instanceIdA, instanceIdB])

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Aguardando as instâncias serem removidas")
        instanceStateA = ""
        instanceStateB = ""

        while instanceStateA != "terminated" or instanceStateB != "terminated":
            time.sleep(20)
            responseA = ec2_client.describe_instances(InstanceIds=[instanceIdA])
            instanceStateA = responseA['Reservations'][0]['Instances'][0]['State']['Name']
            print(f"Estado atual da instância {tagNameInstance}{instanceA}: {instanceStateA}")

            responseB = ec2_client.describe_instances(InstanceIds=[instanceIdB])
            instanceStateB = responseB['Reservations'][0]['Instances'][0]['State']['Name']
            print(f"Estado atual da instância {tagNameInstance}{instanceB}: {instanceStateB}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome de tag de todas as instâncias criadas ativas")
        
        all_instances = ec2_client.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
        active_tags = [instance['Tags'][0]['Value'] for reservation in all_instances['Reservations'] for instance in reservation['Instances']]
        print("\n".join(active_tags))
    
    else:
        print(f"Não existem instâncias ativas com o nome de tag {tagNameInstance}{instanceA} ou {tagNameInstance}{instanceB}")
else:
    print("Código não executado")









# #!/usr/bin/env python

# import boto3

# print("***********************************************")
# print("SERVIÇO: AWS EC2")
# print("EC2 DOUBLE CREATION")

# print("-----//-----//-----//-----//-----//-----//-----")
# print("Definindo variáveis")
# tag_name_instance = "ec2Test"
# instanceA = "1"
# instanceB = "2"
# sg_name = "default"
# az = "us-east-1a"
# image_id = "ami-0c7217cdde317cfec"    # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
# so = "ubuntu"
# # so = "ec2-user"
# instance_type = "t2.micro"
# key_pair_path = "G:/Meu Drive/4_PROJ/scripts/aws/.default/secrets/awsKeyPair/universal"
# key_pair_name = "keyPairUniversal"
# user_data_path = "G:/Meu Drive/4_PROJ/scripts/aws/compute/ec2/userData/basic/"
# user_data_file = "udFile.sh"
# # device_name = "/dev/xvda"
# device_name = "/dev/sda1"
# volume_size = 8
# volume_type = "gp2"

# print("-----//-----//-----//-----//-----//-----//-----")
# resposta = input(f"Deseja executar o código? (y/n) ")
# if resposta.lower() == 'y':
#     print("-----//-----//-----//-----//-----//-----//-----")
#     print(f"Verificando se existe as instâncias ativas de nome de tag {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
#     ec2 = boto3.resource('ec2')
#     instances = list(ec2.instances.filter(Filters=[
#         {'Name': 'tag:Name', 'Values': [f'{tag_name_instance}{instanceA}', f'{tag_name_instance}{instanceB}']}
#     ]))

#     if instances:
#         print("-----//-----//-----//-----//-----//-----//-----")
#         print(f"Já existe uma instância ativa de nome de tag {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
#         for instance in instances:
#             print(instance.tags[0]['Value'])

#         print("-----//-----//-----//-----//-----//-----//-----")
#         print(f"Extraindo o Id da instância ativa de nome de tag {tag_name_instance}")
#         instance_id = instances['InstanceId']




#         print("-----//-----//-----//-----//-----//-----//-----")
#         print(f"Listando o IP público das instâncias {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
#         for instance in instances:
#             print(instance.public_ip_address)

#             print("-----//-----//-----//-----//-----//-----//-----")
#             print("Exibindo o comando para acesso remoto via OpenSSH")
#             ip_ec2 = instance.public_ip_address
#             print(f'ssh -i "{key_pair_path}/{key_pair_name}.pem" ubuntu@{ip_ec2}')
#     else:
#         print("-----//-----//-----//-----//-----//-----//-----")
#         print("Listando o nome da tag de todas as instâncias EC2 criadas")
#         all_instances = list(ec2.instances.filter(Filters=[{'Name': 'tag-key', 'Values': ['Name']}]))
#         for instance in all_instances:
#             print(instance.tags[0]['Value'])

#         print("-----//-----//-----//-----//-----//-----//-----")
#         print("Extraindo o Id dos elementos de rede")
#         sg_id = list(ec2.security_groups.filter(Filters=[{'Name': 'group-name', 'Values': [sg_name]}]))[0].id
#         subnet_id = list(ec2.subnets.filter(Filters=[{'Name': 'availability-zone', 'Values': [az]}]))[0].id

#         print("-----//-----//-----//-----//-----//-----//-----")
#         print(f"Criando a instância EC2 de nome de tag {tag_name_instance}{instanceA}")
#         instance_a = ec2.create_instances(
#             ImageId=image_id,
#             InstanceType=instance_type,
#             KeyName=key_pair_name,
#             SecurityGroupIds=[sg_id],
#             SubnetId=subnet_id,
#             MinCount=1,
#             MaxCount=1,
#             UserData=open(f"{user_data_path}/{user_data_file}", "r").read(),
#             BlockDeviceMappings=[
#                 {
#                     'DeviceName': device_name,
#                     'Ebs': {
#                         'VolumeSize': volume_size,
#                         'VolumeType': volume_type,
#                     },
#                 },
#             ],
#             TagSpecifications=[{'ResourceType': 'instance', 'Tags': [{'Key': 'Name', 'Value': f'{tag_name_instance}{instanceA}'}]}]
#         )

#         print("-----//-----//-----//-----//-----//-----//-----")
#         print(f"Criando a instância EC2 de nome de tag {tag_name_instance}{instanceB}")
#         instance_b = ec2.create_instances(
#             ImageId=image_id,
#             InstanceType=instance_type,
#             KeyName=key_pair_name,
#             SecurityGroupIds=[sg_id],
#             SubnetId=subnet_id,
#             MinCount=1,
#             MaxCount=1,
#             UserData=open(f"{user_data_path}/{user_data_file}", "r").read(),
#             BlockDeviceMappings=[
#                 {
#                     'DeviceName': device_name,
#                     'Ebs': {
#                         'VolumeSize': volume_size,
#                         'VolumeType': volume_type,
#                     },
#                 },
#             ],
#             TagSpecifications=[{'ResourceType': 'instance', 'Tags': [{'Key': 'Name', 'Value': f'{tag_name_instance}{instanceB}'}]}]
#         )

#         print("-----//-----//-----//-----//-----//-----//-----")
#         print("Listando o nome da tag de todas as instâncias EC2 criadas")
#         all_instances = list(ec2.instances.filter(Filters=[{'Name': 'tag-key', 'Values': ['Name']}]))
#         for instance in all_instances:
#             print(instance.tags[0]['Value'])

#         print("-----//-----//-----//-----//-----//-----//-----")
#         print(f"Listando o IP público das instâncias {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
#         instances = list(ec2.instances.filter(Filters=[
#                 {'Name': 'tag:Name', 'Values': [f'{tag_name_instance}{instanceA}', f'{tag_name_instance}{instanceB}']}
#             ]))
#         for instance in instances:
#             instance.wait_until_running()
#             print(instance.public_ip_address)

#             print("-----//-----//-----//-----//-----//-----//-----")
#             print("Exibindo o comando para acesso remoto via OpenSSH")
#             ip_ec2 = instance.public_ip_address
#             print(f'ssh -i "{key_pair_path}/{key_pair_name}.pem" ubuntu@{ip_ec2}')
# else:
#     print("Código não executado")




# #!/usr/bin/env python

# import boto3

# print("***********************************************")
# print("SERVIÇO: AWS EC2")
# print("EC2 DOUBLE EXCLUSION")

# print("-----//-----//-----//-----//-----//-----//-----")
# print("Definindo variáveis")
# tag_name_instance = "ec2Test"
# instanceA = "1"
# instanceB = "2"

# print("-----//-----//-----//-----//-----//-----//-----")
# resposta = input("Deseja executar o código? (y/n) ")
# if resposta.lower() == 'y':
#     print("-----//-----//-----//-----//-----//-----//-----")
#     print(f"Criando um cliente para o serviço EC2")
#     ec2 = boto3.resource('ec2')

#     condition = ec2.instances.filter(
#         Filters=[
#             {'Name': 'tag:Name', 'Values': [f'{tag_name_instance}{instanceA}', f'{tag_name_instance}{instanceB}']},
#             {'Name': 'instance-state-name', 'Values': 'running'}
#         ]
#     )

#     print("-----//-----//-----//-----//-----//-----//-----")
#     print(f"Verificando se existe as instâncias {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
#     if condition:
#         print("-----//-----//-----//-----//-----//-----//-----")
#         print("Listando o nome da tag de todas as instâncias EC2 criadas")
#         all_instances = list(ec2.instances.filter(Filters=[{'Name': 'tag-key', 'Values': ['Name']}]))
#         for instance in all_instances:
#             print(instance.tags[0]['Value'])

#         print("-----//-----//-----//-----//-----//-----//-----")
#         print(f"Extraindo o Id das instâncias de nome de tag {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
#         instance_ids = [instance.id for instance in condition]

#         print("-----//-----//-----//-----//-----//-----//-----")
#         print(f"Removendo as instâncias de nome de tag {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
#         ec2.instances.filter(InstanceIds=instance_ids).terminate()

#         print("-----//-----//-----//-----//-----//-----//-----")
#         print("Listando o nome da tag de todas as instâncias EC2 criadas")
#         all_instances = list(ec2.instances.filter(Filters=[{'Name': 'tag-key', 'Values': ['Name']}]))
#         for instance in all_instances:
#             print(instance.tags[0]['Value'])
#     else:
#         print(f"Não existe instâncias com o nome de tag {tag_name_instance}{instanceA} ou {tag_name_instance}{instanceB}")
# else:
#     print("Código não executado")