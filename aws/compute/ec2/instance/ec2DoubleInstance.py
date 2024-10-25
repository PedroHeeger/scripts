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
        print(f"Já existe as instâncias ativas {tagNameInstance}{instanceA} e {tagNameInstance}{instanceB}")
        for reservation in instances:
            for instance in reservation['Instances']:
                for tag in instance['Tags']:
                    if tag['Key'] == 'Name':
                        print(tag['Value'])
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o IP público das instâncias ativas {tagNameInstance}{instanceA} e {tagNameInstance}{instanceB}")
        for instance in instances:
            for i in instance['Instances']:
                public_ips = i['NetworkInterfaces'][0]['Association'].get('PublicIp', 'N/A')
                print(public_ips)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id das instâncias ativas {tagNameInstance}{instanceA} e {tagNameInstance}{instanceB}")
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
        print(f"Criando a instância {tagNameInstance}{instanceA}")
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
        print(f"Criando a instância {tagNameInstance}{instanceB}")
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
        print(f"Listando o IP público das instâncias ativas {tagNameInstance}{instanceA} e {tagNameInstance}{instanceB}")
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
        print(f"Extraindo o Id das instâncias ativas {tagNameInstance}{instanceA} e {tagNameInstance}{instanceB}")
        
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
        print(f"Removendo as instâncias {tagNameInstance}{instanceA} e {tagNameInstance}{instanceB}")
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
        print(f"Não existem instâncias ativas {tagNameInstance}{instanceA} ou {tagNameInstance}{instanceB}")
else:
    print("Código não executado")