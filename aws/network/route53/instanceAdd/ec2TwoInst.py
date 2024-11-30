import boto3
import time

print("***********************************************")
print("SERVIÇO: AWS EC2 E AWS ROUTE 53")
print("TWO INSTANCE CREATION FOR ROUTE 53")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tagNameInstance = "ec2Test"
instanceA = "1"
instanceB = "2"
az = "us-east-1a"
otherAZ = "sa-east-1a"
sgName = "default"
imageIdA = "ami-0c7217cdde317cfec"  # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
imageIdB = "ami-0f16d0d3ac759edfa"  # Canonical, Ubuntu, 24.04, amd64 noble image
so = "ubuntu"
# so = "ec2-user"
instanceType = "t2.micro"
keyPairPathA = "G:/Meu Drive/4_PROJ/scripts/aws/.default/secrets/awsKeyPair/universal"
keyPairNameA = "keyPairUniversal"
keyPairPathB = "G:/Meu Drive/4_PROJ/scripts/aws/.default/secrets/awsKeyPair/test"
keyPairNameB = "keyPairTest"
userDataPath = "G:/Meu Drive/4_PROJ/scripts/aws/compute/ec2/userData/httpd/"
userDataFile = "udFileDeb.sh"
# deviceName = "/dev/xvda" 
deviceName = "/dev/sda1"
volumeSize = 8
volumeType = "gp2"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    def create_ec2_instance(tagNameInstance, instanceNum, region, keyPairPath, keyPairName, so, sgName, az, imageId, instanceType, userDataPath, userDataFile, deviceName, volumeSize, volumeType):
        print(f"-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a instância ativa {tagNameInstance}{instanceNum}")
        ec2 = boto3.client('ec2', region_name=region)
        instances = ec2.describe_instances(
            Filters=[{'Name': 'instance-state-name', 'Values': ['running']}, 
                     {'Name': 'tag:Name', 'Values': [f'{tagNameInstance}{instanceNum}']}]
        )
        
        if len(instances['Reservations']) > 0:
            print(f"-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe as instâncias ativas {tagNameInstance}{instanceNum}")
            for reservation in instances['Reservations']:
                for instance in reservation['Instances']:
                    for tag in instance['Tags']:
                        if tag['Key'] == 'Name' and tag['Value'] == f'{tagNameInstance}{instanceNum}':
                            print(f"Tag Name: {tag['Value']}")
            
            print(f"-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o IP público da instância ativa {tagNameInstance}{instanceNum}")
            instance_ip = ec2.describe_instances(
                Filters=[{'Name': 'tag:Name', 'Values': [f'{tagNameInstance}{instanceNum}']}, 
                         {'Name': 'instance-state-name', 'Values': ['running']}]
            )
            for reservation in instance_ip['Reservations']:
                for instance in reservation['Instances']:
                    instance_ip = instance['PublicIpAddress']
                    print(instance['PublicIpAddress'])
            
            print(f"-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o Id da instância ativa {tagNameInstance}{instanceNum}")
            instance_id = ec2.describe_instances(
                Filters=[{'Name': 'tag:Name', 'Values': [f'{tagNameInstance}{instanceNum}']}, 
                         {'Name': 'instance-state-name', 'Values': ['running']}]
            )
            for reservation in instance_id['Reservations']:
                for instance in reservation['Instances']:
                    instance_id = instance['InstanceId']
                    print(f"InstanceId: {instance['InstanceId']}")
            
            print(f"-----//-----//-----//-----//-----//-----//-----")
            print(f"Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância {tagNameInstance}{instanceNum}")
            print(f"ssh -i \"{keyPairPath}/{keyPairName}.pem\" {so}@{instance_ip}")
            print(f"aws ssm start-session --target {instance_id}")
        
        else:
            print(f"-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o nome de tag de todas as instâncias criadas ativas")
            instances = ec2.describe_instances(
                Filters=[{'Name': 'instance-state-name', 'Values': ['running']}]
            )
            for reservation in instances['Reservations']:
                for instance in reservation['Instances']:
                    for tag in instance['Tags']:
                        if tag['Key'] == 'Name':
                            print(tag['Value'])
            
            print(f"-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o Id dos elementos de rede para a instância {tagNameInstance}{instanceNum}")
            sg_id = ec2.describe_security_groups(
                Filters=[{'Name': 'group-name', 'Values': [sgName]}]
            )
            subnet_id = ec2.describe_subnets(
                Filters=[{'Name': 'availabilityZone', 'Values': [az]}]
            )
            
            print(f"-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando a instância {tagNameInstance}{instanceNum}")
            instance = ec2.run_instances(
                ImageId=imageId,
                InstanceType=instanceType,
                KeyName=keyPairName,
                SecurityGroupIds=[sg_id['SecurityGroups'][0]['GroupId']],
                SubnetId=subnet_id['Subnets'][0]['SubnetId'],
                MinCount=1,
                MaxCount=1,
                UserData=open(f"{userDataPath}/{userDataFile}", 'r').read(),
                TagSpecifications=[{
                    'ResourceType': 'instance',
                    'Tags': [{'Key': 'Name', 'Value': f'{tagNameInstance}{instanceNum}'}]
                }],
                BlockDeviceMappings=[{
                    'DeviceName': deviceName,
                    'Ebs': {
                        'VolumeSize': volumeSize,
                        'VolumeType': volumeType
                    }
                }]
            )
            instance_id = instance['Instances'][0]['InstanceId']

            print(f"-----//-----//-----//-----//-----//-----//-----")
            print(f"Aguardando a instância criada entrar em execução")
            instance_state = ""
            while instance_state != "running":
                time.sleep(20)
                instance_state = ec2.describe_instances(InstanceIds=[instance_id])
                instance_state = instance_state['Reservations'][0]['Instances'][0]['State']['Name']
                print(f"Estado atual da instância {tagNameInstance}{instanceNum}: {instance_state}")
            
            print(f"-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o nome de tag de todas as instâncias criadas ativas")
            instances = ec2.describe_instances(
                Filters=[{'Name': 'instance-state-name', 'Values': ['running']}]
            )
            for reservation in instances['Reservations']:
                for instance in reservation['Instances']:
                    for tag in instance['Tags']:
                        if tag['Key'] == 'Name':
                            print(tag['Value'])
           
            print(f"-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o IP público das instâncias ativas {tagNameInstance}{instanceNum}")
            instance_ip = ec2.describe_instances(
                Filters=[{'Name': 'tag:Name', 'Values': [f'{tagNameInstance}{instanceNum}']}, 
                         {'Name': 'instance-state-name', 'Values': ['running']}]
            )
            for reservation in instance_ip['Reservations']:
                for instance in reservation['Instances']:
                    instance_ip = instance['PublicIpAddress']
                    print(instance['PublicIpAddress'])
            
            print(f"-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o Id das instâncias ativas {tagNameInstance}{instanceNum}")
            instance_id = ec2.describe_instances(
                Filters=[{'Name': 'tag:Name', 'Values': [f'{tagNameInstance}{instanceNum}']}, 
                         {'Name': 'instance-state-name', 'Values': ['running']}]
            )
            for reservation in instance_id['Reservations']:
                for instance in reservation['Instances']:
                    instance_id = instance['InstanceId']
                    print(f"InstanceId: {instance['InstanceId']}")
            
            print(f"-----//-----//-----//-----//-----//-----//-----")
            print(f"Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância {tagNameInstance}{instanceNum}")
            print(f"ssh -i \"{keyPairPath}/{keyPairName}.pem\" {so}@{instance_ip}")
            print(f"aws ssm start-session --target {instance_id}")
    

    if int(instanceA) < int(instanceB):
        region = az[:-1]
        create_ec2_instance(tagNameInstance, instanceA, region, keyPairPathA, keyPairNameA, so, sgName, az, imageIdA, instanceType, userDataPath, userDataFile, deviceName, volumeSize, volumeType)
    if int(instanceB) > int(instanceA):
        region = otherAZ[:-1]
        create_ec2_instance(tagNameInstance, instanceB, region, keyPairPathB, keyPairNameB, so, sgName, otherAZ, imageIdB, instanceType, userDataPath, userDataFile, deviceName, volumeSize, volumeType)
else:
    print("Código não executado")
    



#!/usr/bin/env python3

import boto3
import time

print("***********************************************")
print("SERVIÇO: AWS EC2 E AWS ROUTE 53")
print("TWO INSTANCE EXCLUSION FOR ROUTE 53")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_instance = "ec2Test"
instance_a = "1"
instance_b = "2"
az = "us-east-1a"
other_az = "sa-east-1a"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    def delete_ec2_instance(tag_name_instance, instance_num, region):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe a instância ativa {tag_name_instance}{instance_num}")
        ec2_client = boto3.client('ec2', region_name=region)

        response = ec2_client.describe_instances(
            Filters=[
                {'Name': 'instance-state-name', 'Values': ['running']},
                {'Name': 'tag:Name', 'Values': [f'{tag_name_instance}{instance_num}']}
            ]
        )
        
        instances = response.get('Reservations', [])
        if instances:
            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando o nome de tag de todas as instâncias criadas ativas")
            response = ec2_client.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
            for reservation in response['Reservations']:
                for instance in reservation['Instances']:
                    for tag in instance.get('Tags', []):
                        if tag['Key'] == 'Name':
                            print(tag['Value'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o Id da instância ativa {tag_name_instance}{instance_num}")
            instance_id = instances[0]['Instances'][0]['InstanceId']
            print(f"ID da instância: {instance_id}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo a instância {tag_name_instance}{instance_num}")
            ec2_client.terminate_instances(InstanceIds=[instance_id])

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Aguardando a instância ser removida")
            instance_state = ''
            while instance_state != 'terminated':
                time.sleep(20)
                response = ec2_client.describe_instances(InstanceIds=[instance_id])
                instance_state = response['Reservations'][0]['Instances'][0]['State']['Name']
                print(f"Estado atual da instância {tag_name_instance}{instance_num}: {instance_state}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Listando o nome de tag de todas as instâncias criadas ativas")
            response = ec2_client.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
            for reservation in response['Reservations']:
                for instance in reservation['Instances']:
                    for tag in instance.get('Tags', []):
                        if tag['Key'] == 'Name':
                            print(tag['Value'])
        else:
            print(f"Não existe a instância ativa {tag_name_instance}{instance_num}")


    if int(instance_a) < int(instance_b):
        region = az[:-1]
        delete_ec2_instance(tag_name_instance, instance_a, region)
    if int(instance_b) > int(instance_a):
        region = other_az[:-1]
        delete_ec2_instance(tag_name_instance, instance_b, region)
else:
    print("Código não executado")