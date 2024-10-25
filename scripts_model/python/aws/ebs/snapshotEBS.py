import boto3

print("***********************************************")
print("SERVIÇO: AWS EBS")
print("SNAPSHOT CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
aws_account_id = "001727357081"
tag_name_volume = "volumeEBSTest1"
snapshot_description = "Snapshot Description Test 1"
tag_name_snapshot = "snapshotEBSTest1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").strip().lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o snapshot de tag de nome {tag_name_snapshot}")
    ec2_client = boto3.client('ec2')

    response = ec2_client.describe_snapshots(OwnerIds=[aws_account_id])
    snapshots = [snap for snap in response['Snapshots'] if any(tag['Key'] == 'Name' and tag['Value'] == tag_name_snapshot for tag in snap.get('Tags', []))]

    if snapshots:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o snapshot de tag de nome {tag_name_snapshot}")
        for snap in snapshots:
            for tag in snap.get('Tags', []):
                if tag['Key'] == 'Name':
                    print(tag['Value'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os snapshots do EBS criado da conta especificada")
        for snap in response['Snapshots']:
            print(snap['SnapshotId'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ID do volume do EBS de tag de nome {tag_name_volume}")
        response = ec2_client.describe_volumes()
        volume_id = next((vol['VolumeId'] for vol in response['Volumes'] if any(tag['Key'] == 'Name' and tag['Value'] == tag_name_volume for tag in vol.get('Tags', []))), None)

        if volume_id:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o snapshot de tag de nome {tag_name_snapshot} a partir do volume do EBS de tag de nome {tag_name_volume}")
            ec2_client.create_snapshot(
                VolumeId=volume_id,
                Description=snapshot_description,
                TagSpecifications=[
                    {
                        'ResourceType': 'snapshot',
                        'Tags': [{'Key': 'Name', 'Value': tag_name_snapshot}]
                    }
                ]
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando apenas o snapshot do EBS de tag de nome {tag_name_snapshot}")
            response = ec2_client.describe_snapshots(OwnerIds=[aws_account_id])
            snapshots = [snap for snap in response['Snapshots'] if any(tag['Key'] == 'Name' and tag['Value'] == tag_name_snapshot for tag in snap.get('Tags', []))]
            for snap in snapshots:
                for tag in snap.get('Tags', []):
                    if tag['Key'] == 'Name':
                        print(tag['Value'])
else:
    print("Código não executado")




import boto3

print("***********************************************")
print("SERVIÇO: AWS EBS")
print("SNAPSHOT EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
aws_account_id = "001727357081"
tag_name_snapshot = "snapshotEBSTest1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").strip().lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o snapshot de tag de nome {tag_name_snapshot}")
    ec2_client = boto3.client('ec2')

    response = ec2_client.describe_snapshots(OwnerIds=[aws_account_id])
    snapshots = [snap for snap in response['Snapshots'] if any(tag['Key'] == 'Name' and tag['Value'] == tag_name_snapshot for tag in snap.get('Tags', []))]

    if snapshots:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os snapshots do EBS criado da conta especificada")
        for snap in response['Snapshots']:
            print(snap['SnapshotId'])

        snapshot_id = snapshots[0]['SnapshotId']
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ID do snapshot do EBS de tag de nome {tag_name_snapshot}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o snapshot do EBS de tag de nome {tag_name_snapshot}")
        ec2_client.delete_snapshot(SnapshotId=snapshot_id)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os snapshots do EBS criado da conta especificada")
        response = ec2_client.describe_snapshots(OwnerIds=[aws_account_id])
        for snap in response['Snapshots']:
            print(snap['SnapshotId'])
    else:
        print(f"Não existe o snapshot do EBS de tag de nome {tag_name_snapshot}")
else:
    print("Código não executado")