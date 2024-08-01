import boto3

print("***********************************************")
print("SERVIÇO: AWS EBS")
print("ATTACH VOLUME")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_volume = "volumeEBSTest1"
# device_name = "/dev/sdf"
device_name = "/dev/xvdf"
tag_name_instance = "ec2Test1"

resposta = input("Deseja executar o código? (y/n) ").strip().lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o volume do EBS de tag de nome {tag_name_volume}")
    ec2_client = boto3.client('ec2')
    response = ec2_client.describe_volumes(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_volume]}])
    volumes = response['Volumes']

    if volumes:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da instância de nome de tag {tag_name_instance}")
        response = ec2_client.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}])
        instances = response['Reservations']

        if instances:
            instance_id = instances[0]['Instances'][0]['InstanceId']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se o volume do EBS de tag de nome {tag_name_volume} está anexado à instância de tag de nome {tag_name_instance}")
            volume = volumes[0]
            attachments = volume['Attachments']
            attached_instances = [att['InstanceId'] for att in attachments if att['InstanceId'] == instance_id]

            if attached_instances:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Já está anexado o volume do EBS de tag de nome {tag_name_volume} à instância de tag de nome {tag_name_instance}")
                for instance in attached_instances:
                    print(instance)
            else:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o ID de todas as instâncias anexadas ao volume do EBS de tag de nome {tag_name_volume}")
                for attachment in attachments:
                    print(attachment['InstanceId'])

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Extraindo o ID do volume do EBS de tag de nome {tag_name_volume}")
                volume_id = volume['VolumeId']

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Anexando o volume do EBS de tag de nome {tag_name_volume} à instância de nome de tag {tag_name_instance}")
                ec2_client.attach_volume(VolumeId=volume_id, InstanceId=instance_id, Device=device_name)

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando apenas a instância de tag de nome {tag_name_instance} anexada ao volume do EBS de tag de nome {tag_name_volume}")
                response = ec2_client.describe_volumes(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_volume]}])
                volume = response['Volumes'][0]
                attachments = volume['Attachments']
                attached_instances = [att['InstanceId'] for att in attachments if att['InstanceId'] == instance_id]
                for instance in attached_instances:
                    print(instance)
        else:
            print(f"Não existe instância com a tag de nome {tag_name_instance}")
    else:
        print(f"Não existe o volume do EBS de tag de nome {tag_name_volume}")
else:
    print("Código não executado")




import boto3
import time

print("***********************************************")
print("SERVIÇO: AWS EBS")
print("DETACH VOLUME")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_volume = "volumeEBSTest1"
tag_name_instance = "ec2Test1"

resposta = input("Deseja executar o código? (y/n) ").strip().lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o volume do EBS de tag de nome {tag_name_volume}")
    ec2_client = boto3.client('ec2')

    response = ec2_client.describe_volumes(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_volume]}])
    volumes = response['Volumes']
    if volumes:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o Id da instância de nome de tag {tag_name_instance}")
        response = ec2_client.describe_instances(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}])
        instances = response['Reservations']

        if instances:
            instance_id = instances[0]['Instances'][0]['InstanceId']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se o volume do EBS de tag de nome {tag_name_volume} está anexado à instância de tag de nome {tag_name_instance}")
            volume = volumes[0]
            attachments = volume['Attachments']
            attached_instances = [att['InstanceId'] for att in attachments if att['InstanceId'] == instance_id]

            if attached_instances:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o ID de todas as instâncias anexadas ao volume do EBS de tag de nome {tag_name_volume}")
                for attachment in attachments:
                    print(attachment['InstanceId'])

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Extraindo o ID do volume do EBS de tag de nome {tag_name_volume}")
                volume_id = volume['VolumeId']

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Desanexando o volume do EBS de tag de nome {tag_name_volume} da instância de tag de nome {tag_name_instance}")
                ec2_client.detach_volume(VolumeId=volume_id)

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Aguardando o volume do EBS de tag de nome {tag_name_volume} ficar disponível")
                state = ""
                while state != "available":
                    time.sleep(5)
                    response = ec2_client.describe_volumes(VolumeIds=[volume_id])
                    state = response['Volumes'][0]['State']
                    print(f"Current state: {state}")

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o ID de todas as instâncias anexadas ao volume do EBS de tag de nome {tag_name_volume}")
                response = ec2_client.describe_volumes(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_volume]}])
                volume = response['Volumes'][0]
                attachments = volume['Attachments']
                for attachment in attachments:
                    print(attachment['InstanceId'])
            else:
                print(f"Não está anexado o volume do EBS de tag de nome {tag_name_volume} à instância de nome de tag {tag_name_instance}")
        else:
            print(f"Não existe instância com a tag de nome {tag_name_instance}")
    else:
        print(f"Não existe o volume do EBS de tag de nome {tag_name_volume}")
else:
    print("Código não executado")