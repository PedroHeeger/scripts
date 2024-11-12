#!/usr/bin/env python3

import boto3
from botocore.exceptions import ClientError
import time

print("***********************************************")
print("SERVIÇO: AWS EC2")
print("DOUBLE INSTANCE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_instance = "ec2ELBTest"
instanceA = "1"
instanceB = "2"
sg_name = "default"
az = "us-east-1a"
image_id = "ami-0c7217cdde317cfec"  # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
so = "ubuntu"
# so = "ec2-user"
instance_type = "t2.micro"
key_pair_path = "G:/Meu Drive/4_PROJ/scripts/aws/.default/secrets/awsKeyPair/universal"
key_pair_name = "keyPairUniversal"
user_data_path = "G:/Meu Drive/4_PROJ/scripts/aws/compute/ec2/userData/httpd/"
user_data_file = "udFileDeb.sh"
# device_name = "/dev/xvda"
device_name = "/dev/sda1"
volume_size = 8
volume_type = "gp2"
# elb_name = "albTest1"
elb_name = "clbTest1"
tg_name = "tgTest1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    def add_instance_lb(elb_name, tg_name, tag_name_instance, instance_id):
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Verificando o tipo de load balancer")
        elb = boto3.client('elb')
        elbv2 = boto3.client('elbv2')
        
        is_classic_lb = False
        is_application_lb = False
        try:
            classicLB = elb.describe_load_balancers(LoadBalancerNames=[elb_name])
            for lb in classicLB['LoadBalancerDescriptions']:
                if lb['LoadBalancerName'] == elb_name:
                    is_classic_lb = True
        except ClientError as e:
            pass

        try:
            applicationLB = elbv2.describe_load_balancers(Names=[elb_name])
            for lb in applicationLB['LoadBalancers']:
                if lb['LoadBalancerName'] == elb_name:
                    is_application_lb = True
        except ClientError as e:
            pass

        if is_classic_lb:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se a instância {tag_name_instance} está associada ao classic load balancer {elb_name}")
            lb_instances = elb.describe_load_balancers(LoadBalancerNames=[elb_name])
            condition = [i for i in lb_instances['LoadBalancerDescriptions'][0]['Instances'] if i['InstanceId'] == instance_id]
            
            if len(condition) > 0:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Já existe a instância {tag_name_instance} associada ao classic load balancer {elb_name}")
                elbs = elb.describe_load_balancers(LoadBalancerNames=[elb_name])['LoadBalancerDescriptions']
                for lb in elbs:
                    for instance in lb.get('Instances', []):
                        if instance['InstanceId'] == instance_id:
                            print(f"Instância associada: {instance['InstanceId']}")
            else:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando todas as instâncias associadas ao classic load balancer {elb_name}")
                elbs = elb.describe_load_balancers()['LoadBalancerDescriptions']
                for lb in elbs:
                    for instance in lb.get('Instances', []):
                        print(f"Instância associada: {instance['InstanceId']}") 

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Registrando a instância {tag_name_instance} ao classic load balancer {elb_name}")
                elb.register_instances_with_load_balancer(
                    LoadBalancerName=elb_name,
                    Instances=[{'InstanceId': instance_id}]
                )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando a instância {tag_name_instance} associada ao classic load balancer {elb_name}")
                elbs = elb.describe_load_balancers(LoadBalancerNames=[elb_name])['LoadBalancerDescriptions']
                for lb in elbs:
                    for instance in lb.get('Instances', []):
                        if instance['InstanceId'] == instance_id:
                            print(f"Instância associada: {instance['InstanceId']}")
        
        elif is_application_lb:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se existe o target group {tg_name}")
            tg_exists = False
            tg_arn = ""
            tg_response = elbv2.describe_target_groups()
            for tg in tg_response['TargetGroups']:
                if tg['TargetGroupName'] == tg_name:
                    tg_exists = True
                    
            if tg_exists:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Extraindo a ARN do target group {tg_name}")
                tg_arn = tg['TargetGroupArn']
    
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Verificando se existe a instância {tag_name_instance} no target group {tg_name}")
                tg_health = elbv2.describe_target_health(TargetGroupArn=tg_arn)
                condition = [
                    t['Target']['Id'] 
                    for t in tg_health['TargetHealthDescriptions'] 
                    if t['Target']['Id'] == instance_id and t['TargetHealth']['State'] != 'draining'
                ]
                if len(condition) > 0:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Já existe a instância {tag_name_instance} no target group {tg_name}")
                    response = elbv2.describe_target_health(TargetGroupArn=tg_arn)
                    for target in response['TargetHealthDescriptions']:
                        if target['Target']['Id'] == instance_id and target['TargetHealth']['State'] != 'draining':
                            print(f"Instance ID: {target['Target']['Id']}")
                else:
                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Listando todas as instâncias no target group {tg_name}")
                    response = elbv2.describe_target_health(TargetGroupArn=tg_arn)
                    for target in response['TargetHealthDescriptions']:
                        if target['TargetHealth']['State'] != 'draining':
                            print(f"Instance ID: {target['Target']['Id']}")

                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Registrando a instância {tag_name_instance} no target group {tg_name}")
                    elbv2.register_targets(
                        TargetGroupArn=tg_arn,
                        Targets=[{'Id': instance_id}]
                    )
                    time.sleep(5)

                    print("-----//-----//-----//-----//-----//-----//-----")
                    print(f"Listando a instância {tag_name_instance} no target group {tg_name}")
                    response = elbv2.describe_target_health(TargetGroupArn=tg_arn)
                    for target in response['TargetHealthDescriptions']:
                        if target['Target']['Id'] == instance_id and target['TargetHealth']['State'] != 'draining':
                            print(f"Instance ID: {target['Target']['Id']}")
            else:
                print(f"Não existe o target group {tg_name}. A instância {tag_name_instance} não pôde ser adicionada. Certifique-se de criar o target group")
        else:
            print(f"Não existe o load balancer {elb_name} ou não pertence aos tipos Classic ou Application. A instância {tag_name_instance} não foi vinculada ao load balancer")


    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe as instâncias ativas {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
    ec2 = boto3.client('ec2')
    
    filters = [
        {'Name': 'instance-state-name', 'Values': ['running']},
        {'Name': 'tag:Name', 'Values': [f'{tag_name_instance}{instanceA}', f'{tag_name_instance}{instanceB}']}
    ]

    condition = ec2.describe_instances(Filters=filters)
    instances = condition['Reservations']

    if len(instances) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe as instâncias ativas {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
        for reservation in instances:
            for instance in reservation['Instances']:
                for tag in instance['Tags']:
                    if tag['Key'] == 'Name':
                        print(tag['Value'])
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o IP público das instâncias ativas {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
        for instance in instances:
            for i in instance['Instances']:
                public_ips = i['NetworkInterfaces'][0]['Association'].get('PublicIp', 'N/A')
                print(public_ips)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id das instâncias ativas {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
        instance_ids = [i['InstanceId'] for r in instances for i in r['Instances']]
        instance_idA = instance_ids[0]
        instance_idB = instance_ids[1]

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância {tag_name_instance}{instanceA}")
        print(f"ssh -i \"{key_pair_path}/{key_pair_name}.pem\" {so}@{public_ips}")
        print(f"aws ssm start-session --target {instance_idA}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância {tag_name_instance}{instanceB}")
        print(f"ssh -i \"{key_pair_path}/{key_pair_name}.pem\" {so}@{public_ips}")
        print(f"aws ssm start-session --target {instance_idB}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Adicionando as instâncias ao load balancer {elb_name}")
        add_instance_lb(elb_name=elb_name, tg_name=tg_name, tag_name_instance=f"{tag_name_instance}{instanceA}", instance_id=instance_idA)
        add_instance_lb(elb_name=elb_name, tg_name=tg_name, tag_name_instance=f"{tag_name_instance}{instanceB}", instance_id=instance_idB)
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
            Filters=[{'Name': 'group-name', 'Values': [sg_name]}]
        )
        sgId = security_group['SecurityGroups'][0]['GroupId']

        subnet = ec2.describe_subnets(
            Filters=[{'Name': 'availabilityZone', 'Values': [az]}]
        )
        subnetId = subnet['Subnets'][0]['SubnetId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a instância {tag_name_instance}{instanceA}")
        instanceA_data = ec2.run_instances(
            ImageId=image_id,
            InstanceType=instance_type,
            KeyName=key_pair_name,
            SecurityGroupIds=[sgId],
            SubnetId=subnetId,
            UserData=open(user_data_path + user_data_file).read(),
            BlockDeviceMappings=[{
                'DeviceName': device_name,
                'Ebs': {'VolumeSize': volume_size, 'VolumeType': volume_type}
            }],
            TagSpecifications=[{'ResourceType': 'instance', 'Tags': [{'Key': 'Name', 'Value': f'{tag_name_instance}{instanceA}'}]}],
            MinCount=1,
            MaxCount=1
        )
        instance_idA = instanceA_data['Instances'][0]['InstanceId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando a instância {tag_name_instance}{instanceB}")
        instanceB_data = ec2.run_instances(
            ImageId=image_id,
            InstanceType=instance_type,
            KeyName=key_pair_name,
            SecurityGroupIds=[sgId],
            SubnetId=subnetId,
            UserData=open(user_data_path + user_data_file).read(),
            BlockDeviceMappings=[{
                'DeviceName': device_name,
                'Ebs': {'VolumeSize': volume_size, 'VolumeType': volume_type}
            }],
            TagSpecifications=[{'ResourceType': 'instance', 'Tags': [{'Key': 'Name', 'Value': f'{tag_name_instance}{instanceB}'}]}],
            MinCount=1,
            MaxCount=1
        )
        instance_idB = instanceB_data['Instances'][0]['InstanceId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Aguardando as instâncias criadas entrarem em execução")
        instanceStateA = ''
        instanceStateB = ''

        while instanceStateA != 'running' or instanceStateB != 'running':
            time.sleep(20)
            instanceStateA = ec2.describe_instances(InstanceIds=[instance_idA])['Reservations'][0]['Instances'][0]['State']['Name']
            print(f"Estado atual da instância {tag_name_instance}{instanceA}: {instanceStateA}")
            instanceStateB = ec2.describe_instances(InstanceIds=[instance_idB])['Reservations'][0]['Instances'][0]['State']['Name']
            print(f"Estado atual da instância {tag_name_instance}{instanceB}: {instanceStateB}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome de tag de todas as instâncias criadas ativas")
        running_instances = ec2.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
        for r in running_instances['Reservations']:
            for i in r['Instances']:
                for tag in i['Tags']:
                    if tag['Key'] == 'Name':
                        print(tag['Value'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o IP público das instâncias ativas {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
        publicIpA = ec2.describe_instances(InstanceIds=[instance_idA])['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']
        publicIpB = ec2.describe_instances(InstanceIds=[instance_idB])['Reservations'][0]['Instances'][0]['NetworkInterfaces'][0]['Association']['PublicIp']
        print(publicIpA)
        print(publicIpB)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância {tag_name_instance}{instanceA}")
        print(f"ssh -i \"{key_pair_path}/{key_pair_name}.pem\" {so}@{publicIpA}")
        print(f"aws ssm start-session --target {instance_idA}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Exibindo o comando para acesso remoto via SSH ou AWS SSM na instância {tag_name_instance}{instanceB}")
        print(f"ssh -i \"{key_pair_path}/{key_pair_name}.pem\" {so}@{publicIpB}")
        print(f"aws ssm start-session --target {instance_idB}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Adicionando as instâncias ao load balancer {elb_name}")
        add_instance_lb(elb_name=elb_name, tg_name=tg_name, tag_name_instance=f"{tag_name_instance}{instanceA}", instance_id=instance_idA)
        add_instance_lb(elb_name=elb_name, tg_name=tg_name, tag_name_instance=f"{tag_name_instance}{instanceB}", instance_id=instance_idB)
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
tag_name_instance = "ec2ELBTest"
instanceA = "1"
instanceB = "2"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existem instâncias ativas {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
    ec2_client = boto3.client('ec2')
    filters = [
        {'Name': 'instance-state-name', 'Values': ['running']},
        {'Name': 'tag:Name', 'Values': [f'{tag_name_instance}{instanceA}', f'{tag_name_instance}{instanceB}']}
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
        print(f"Extraindo o Id das instâncias ativas {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
        
        instance_idA = None
        instance_idB = None

        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                tag_name = [tag['Value'] for tag in instance['Tags'] if tag['Key'] == 'Name'][0]
                if tag_name == f"{tag_name_instance}{instanceA}":
                    instance_idA = instance['InstanceId']
                elif tag_name == f"{tag_name_instance}{instanceB}":
                    instance_idB = instance['InstanceId']
        
        print(f"InstanceIdA: {instance_idA}, InstanceIdB: {instance_idB}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo as instâncias {tag_name_instance}{instanceA} e {tag_name_instance}{instanceB}")
        ec2_client.terminate_instances(InstanceIds=[instance_idA, instance_idB])

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Aguardando as instâncias serem removidas")
        instanceStateA = ""
        instanceStateB = ""

        while instanceStateA != "terminated" or instanceStateB != "terminated":
            time.sleep(20)
            responseA = ec2_client.describe_instances(InstanceIds=[instance_idA])
            instanceStateA = responseA['Reservations'][0]['Instances'][0]['State']['Name']
            print(f"Estado atual da instância {tag_name_instance}{instanceA}: {instanceStateA}")

            responseB = ec2_client.describe_instances(InstanceIds=[instance_idB])
            instanceStateB = responseB['Reservations'][0]['Instances'][0]['State']['Name']
            print(f"Estado atual da instância {tag_name_instance}{instanceB}: {instanceStateB}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome de tag de todas as instâncias criadas ativas")
        
        all_instances = ec2_client.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
        active_tags = [instance['Tags'][0]['Value'] for reservation in all_instances['Reservations'] for instance in reservation['Instances']]
        print("\n".join(active_tags))
    
    else:
        print(f"Não existem instâncias ativas {tag_name_instance}{instanceA} ou {tag_name_instance}{instanceB}")
else:
    print("Código não executado")