import boto3

print("***********************************************")
print("SERVIÇO: AWS EFS")
print("FILE SYSTEM CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
efs_token = "fsTokenEFSTest1"
tag_name_fs = "fsEFSTest1"
performance_mode = "generalPurpose"
throughput_mode = "bursting"
a_z = "us-east-1a"
# a_z = "us-east-1b"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").strip().lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o sistema de arquivos de tag de nome {tag_name_fs}")
    efs_client = boto3.client('efs')
    response = efs_client.describe_file_systems()
    file_systems = [fs for fs in response['FileSystems'] if any(tag['Key'] == 'Name' and tag['Value'] == tag_name_fs for tag in fs.get('Tags', []))]
    
    if file_systems:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o sistema de arquivos de tag de nome {tag_name_fs}")
        for fs in file_systems:
            for tag in fs.get('Tags', []):
                if tag['Key'] == 'Name':
                    print(tag['Value'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando a tag de nome de todos os sistemas de arquivos")
        all_filesystems = efs_client.describe_file_systems()
        tags = [tag['Value'] for fs in all_filesystems['FileSystems'] for tag in fs.get('Tags', []) if tag['Key'] == 'Name']
        for tag in tags:
            print(tag)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o sistema de arquivos de tag de nome {tag_name_fs}")
        efs_client.create_file_system(
            CreationToken=efs_token,
            PerformanceMode=performance_mode,
            ThroughputMode=throughput_mode,
            Tags=[{'Key': 'Name', 'Value': tag_name_fs}]
        )

        # Descomentar este bloco se desejar usar o parâmetro de zona de disponibilidade
        # print("-----//-----//-----//-----//-----//-----//-----")
        # print(f"Criando o sistema de arquivos de tag de nome {tag_name_fs}")
        # efs_client.create_file_system(
        #     CreationToken=efs_token,
        #     PerformanceMode=performance_mode,
        #     ThroughputMode=throughput_mode,
        #     AvailabilityZoneName=a_z,
        #     Tags=[{'Key': 'Name', 'Value': tag_name_fs}]
        # )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando apenas o sistema de arquivos de tag de nome {tag_name_fs}")
        file_systems = efs_client.describe_file_systems()
        tags = [tag['Value'] for fs in file_systems['FileSystems'] for tag in fs.get('Tags', []) if tag['Key'] == 'Name' and tag['Value'] == tag_name_fs]
        for tag in tags:
            print(tag)
else:
    print("Código não executado")




import boto3
import time

print("***********************************************")
print("SERVIÇO: AWS EFS")
print("FILE SYSTEM EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_fs = "fsEFSTest1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").strip().lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o sistema de arquivos de tag de nome {tag_name_fs}")
    efs_client = boto3.client('efs')
    response = efs_client.describe_file_systems()
    file_systems = [fs for fs in response['FileSystems'] if any(tag['Key'] == 'Name' and tag['Value'] == tag_name_fs for tag in fs.get('Tags', []))]
    
    if file_systems:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando a tag de nome de todos os sistemas de arquivos")
        for fs in response['FileSystems']:
            for tag in fs.get('Tags', []):
                if tag['Key'] == 'Name':
                    print(tag['Value'])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ID do sistema de arquivos de tag de nome {tag_name_fs}")
        fs_id = next(fs['FileSystemId'] for fs in file_systems)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existem pontos de montagem no sistema de arquivos de tag de nome {tag_name_fs}")
        mount_targets_response = efs_client.describe_mount_targets(FileSystemId=fs_id)
        mount_target_ids = [mt['MountTargetId'] for mt in mount_targets_response['MountTargets']]
        
        if mount_target_ids:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo todos os pontos de montagem no sistema de arquivos de tag de nome {tag_name_fs}")
            for mount_target_id in mount_target_ids:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Removendo ponto de montagem {mount_target_id}")
                efs_client.delete_mount_target(MountTargetId=mount_target_id)

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Aguardando a remoção do ponto de montagem {mount_target_id}")
                state = "deleting"
                while state in ["creating", "available", "deleting"]:
                    time.sleep(5)
                    mount_target = efs_client.describe_mount_targets(FileSystemId=fs_id)
                    states = [mt['LifeCycleState'] for mt in mount_target['MountTargets'] if mt['MountTargetId'] == mount_target_id]
                    state = states[0] if states else ""
                    print(f"Current state: {state}")

        else:
            print(f"Não existem pontos de montagem no sistema de arquivos de tag de nome {tag_name_fs}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o sistema de arquivos de tag de nome {tag_name_fs}")
        efs_client.delete_file_system(FileSystemId=fs_id)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando a tag de nome de todos os sistemas de arquivos")
        response = efs_client.describe_file_systems()
        for fs in response['FileSystems']:
            for tag in fs.get('Tags', []):
                if tag['Key'] == 'Name':
                    print(tag['Value'])
    else:
        print(f"Não existe o sistema de arquivos de tag de nome {tag_name_fs}")
else:
    print("Código não executado")