import boto3
import time

print("***********************************************")
print("SERVIÇO: AWS EBS")
print("VOLUME CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
size = 10
az = "us-east-1a"
volume_type = "gp2"
tag_name_volume = "volumeEBSTest1"
aws_account_id = "001727357081"
tag_name_snapshot = "snapshotEBSTest1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").strip().lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o volume do EBS {tag_name_volume}")
    ec2_client = boto3.client('ec2')
    response = ec2_client.describe_volumes()
    volumes = [vol for vol in response['Volumes'] if any(tag['Key'] == 'Name' and tag['Value'] == tag_name_volume for tag in vol.get('Tags', []))]

    if volumes:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o volume do EBS {tag_name_volume}")
        for vol in volumes:
            for tag in vol.get('Tags', []):
                if tag['Key'] == 'Name':
                    print(tag['Value'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os volumes do EBS criado")
        response = ec2_client.describe_volumes()
        for vol in response['Volumes']:
            print(vol['VolumeId'])

        # print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o volume do EBS {tag_name_volume}")
        ec2_client.create_volume(
            Size=size,
            AvailabilityZone=az,
            VolumeType=volume_type,
            TagSpecifications=[
                {
                    'ResourceType': 'volume',
                    'Tags': [{'Key': 'Name', 'Value': tag_name_volume}]
                }
            ],
            Encrypted=True
        )

        # Descomente as linhas abaixo se precisar criar um volume a partir de um snapshot e comente a linha de criação acima
        # print("-----//-----//-----//-----//-----//-----//-----")
        # print(f"Verificando se existe o snapshot {tag_name_snapshot}")
        # response = ec2_client.describe_snapshots(OwnerIds=[aws_account_id])
        # snapshots = [snap for snap in response['Snapshots'] if any(tag['Key'] == 'Name' and tag['Value'] == tag_name_snapshot for tag in snap.get('Tags', []))]
        # if snapshots:
        #     print("-----//-----//-----//-----//-----//-----//-----")
        #     print(f"Extraindo o ID do snapshot do EBS {tag_name_snapshot}")
        #     response = ec2_client.describe_snapshots(OwnerIds=[aws_account_id])
        #     snapshot_id = next((snap['SnapshotId'] for snap in response['Snapshots'] if any(tag['Key'] == 'Name' and tag['Value'] == tag_name_snapshot for tag in snap.get('Tags', []))), None)
            
        #     print("-----//-----//-----//-----//-----//-----//-----")
        #     print(f"Criando o volume do EBS {tag_name_volume} a partir do snapshot {tag_name_snapshot}")
        #     ec2_client.create_volume(
        #         SnapshotId=snapshot_id,
        #         Size=size,
        #         AvailabilityZone=az,
        #         VolumeType=volume_type,
        #         TagSpecifications=[
        #             {
        #                 'ResourceType': 'volume',
        #                 'Tags': [{'Key': 'Name', 'Value': tag_name_volume}]
        #             }
        #         ],
        #         Encrypted=True
        #     )
        # else:
        #     print(f"Não existe o snapshot do EBS {tag_name_snapshot}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Aguardando o volume do EBS {tag_name_volume} ficar disponível")
        time.sleep(5)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando apenas o volume do EBS {tag_name_volume}")
        ec2_client = boto3.client('ec2')
        response = ec2_client.describe_volumes()
        volumes = [vol for vol in response['Volumes'] if any(tag['Key'] == 'Name' and tag['Value'] == tag_name_volume for tag in vol.get('Tags', []))]
        for vol in volumes:
            for tag in vol.get('Tags', []):
                if tag['Key'] == 'Name':
                    print(tag['Value'])
else:
    print("Código não executado")




import boto3
import time

print("***********************************************")
print("SERVIÇO: AWS EBS")
print("VOLUME EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_volume = "volumeEBSTest1"

resposta = input("Deseja executar o código? (y/n) ").strip().lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o volume do EBS {tag_name_volume}")
    ec2_client = boto3.client('ec2')
    response = ec2_client.describe_volumes()
    volumes = [vol for vol in response['Volumes'] if any(tag['Key'] == 'Name' and tag['Value'] == tag_name_volume for tag in vol.get('Tags', []))]

    if volumes:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os volumes do EBS criado")
        for vol in response['Volumes']:
            print(vol['VolumeId'])

        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ID do volume do EBS {tag_name_volume}")
        volume_id = volumes[0]['VolumeId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe instâncias anexadas ao volume do EBS {tag_name_volume}")
        if 'Attachments' in volumes[0] and volumes[0]['Attachments']:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Desanexando o volume do EBS {tag_name_volume} da instância")
            ec2_client.detach_volume(VolumeId=volume_id)
        else:
            print(f"Não existe instâncias anexadas ao volume do EBS {tag_name_volume}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Aguardando o volume do EBS {tag_name_volume} ficar disponível")
        state = ""
        while state != "available":
            time.sleep(5)
            response = ec2_client.describe_volumes(VolumeIds=[volume_id])
            state = response['Volumes'][0]['State']
            print(f"Current state: {state}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o volume do EBS {tag_name_volume}")
        ec2_client.delete_volume(VolumeId=volume_id)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os volumes do EBS criado")
        response = ec2_client.describe_volumes()
        for vol in response['Volumes']:
            print(vol['VolumeId'])
    else:
        print(f"Não existe o volume do EBS {tag_name_volume}")
else:
    print("Código não executado")