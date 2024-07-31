import boto3
import time

print("***********************************************")
print("SERVIÇO: AWS EFS")
print("MOUNT TARGET CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_fs = "fsEFSTest1"
sg_name = "default"
a_z = "us-east-1a"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").strip().lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o sistema de arquivos de tag de nome {tag_name_fs}")
    efs_client = boto3.client('efs')
    ec2_client = boto3.client('ec2')

    response = efs_client.describe_file_systems()
    file_systems = [fs for fs in response['FileSystems'] if any(tag['Key'] == 'Name' and tag['Value'] == tag_name_fs for tag in fs.get('Tags', []))]
    
    if file_systems:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ID do sistema de arquivos de tag de nome {tag_name_fs}")
        fs_id = file_systems[0]['FileSystemId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo o Id dos elementos de rede")
        sg_response = ec2_client.describe_security_groups(GroupNames=[sg_name])
        sg_id = sg_response['SecurityGroups'][0]['GroupId']
        subnet_response = ec2_client.describe_subnets(Filters=[{'Name': 'availability-zone', 'Values': [a_z]}])
        subnet_id = subnet_response['Subnets'][0]['SubnetId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe um ponto de montagem no sistema de arquivos de tag de nome {tag_name_fs} na AZ {a_z}")
        mount_targets_response = efs_client.describe_mount_targets(FileSystemId=fs_id)
        mount_targets = [mt for mt in mount_targets_response['MountTargets'] if mt['AvailabilityZoneName'] == a_z]
        
        if mount_targets:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe um ponto de montagem no sistema de arquivos de tag de nome {tag_name_fs} na AZ {a_z}")
            for mt in mount_targets:
                print(mt['MountTargetId'])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os pontos de montagem existentes no sistema de arquivo de tag de nome {tag_name_fs}")
            for mt in mount_targets_response['MountTargets']:
                print(mt['MountTargetId'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando um ponto de montagem no sistema de arquivos de tag de nome {tag_name_fs} na AZ {a_z}")
            efs_client.create_mount_target(FileSystemId=fs_id, SubnetId=subnet_id, SecurityGroups=[sg_id])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Aguardando o ponto de montagem no sistema de arquivos de tag de nome {tag_name_fs} na AZ {a_z} ficar disponível")

            state = ""
            while state != "available":
                time.sleep(8)
                mount_targets_response = efs_client.describe_mount_targets(FileSystemId=fs_id)
                mount_targets = [mt for mt in mount_targets_response['MountTargets'] if mt['AvailabilityZoneName'] == a_z]
                if mount_targets:
                    state = mount_targets[0]['LifeCycleState']
                print(f"Current state: {state}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando apenas o ponto de montagem no sistema de arquivos de tag de nome {tag_name_fs} na AZ {a_z}")
            for mt in mount_targets_response['MountTargets']:
                if mt['AvailabilityZoneName'] == a_z:
                    print(mt['MountTargetId'])
    else:
        print(f"Não existe o sistema de arquivos de tag de nome {tag_name_fs}")
else:
    print("Código não executado")




import boto3
import time

print("***********************************************")
print("SERVIÇO: AWS EFS")
print("MOUNT TARGET EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_fs = "fsEFSTest1"
sg_name = "default"
a_z = "us-east-1a"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").strip().lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o sistema de arquivos de tag de nome {tag_name_fs}")
    efs_client = boto3.client('efs')
    ec2_client = boto3.client('ec2')

    response = efs_client.describe_file_systems()
    file_systems = [fs for fs in response['FileSystems'] if any(tag['Key'] == 'Name' and tag['Value'] == tag_name_fs for tag in fs.get('Tags', []))]
    
    if file_systems:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o ID do sistema de arquivos de tag de nome {tag_name_fs}")
        fs_id = file_systems[0]['FileSystemId']

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo o Id dos elementos de rede")
        sg_response = ec2_client.describe_security_groups(GroupNames=[sg_name])
        sg_id = sg_response['SecurityGroups'][0]['GroupId']
        subnet_response = ec2_client.describe_subnets(Filters=[{'Name': 'availability-zone', 'Values': [a_z]}])
        subnet_id = subnet_response['Subnets'][0]['SubnetId']
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe um ponto de montagem no sistema de arquivos de tag de nome {tag_name_fs} na AZ {a_z}")
        mount_targets_response = efs_client.describe_mount_targets(FileSystemId=fs_id)
        mount_targets = [mt for mt in mount_targets_response['MountTargets'] if mt['AvailabilityZoneName'] == a_z]
        
        if mount_targets:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os pontos de montagem existentes no sistema de arquivo de tag de nome {tag_name_fs}")
            for mt in mount_targets_response['MountTargets']:
                print(mt['MountTargetId'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo o ID do ponto de montagem do sistema de arquivos de tag de nome {tag_name_fs} na AZ {a_z}")
            mount_target_id = [mt['MountTargetId'] for mt in mount_targets if mt['AvailabilityZoneName'] == a_z]
            
            if mount_target_id:
                mount_target_id = mount_target_id[0]

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Removendo o ponto de montagem do sistema de arquivos de tag de nome {tag_name_fs} na AZ {a_z}")
                efs_client.delete_mount_target(MountTargetId=mount_target_id)

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Aguardando o ponto de montagem no sistema de arquivos de tag de nome {tag_name_fs} na AZ {a_z} ser deletado")
                state = "deleting"
                while state in ["creating", "available", "deleting"]:
                    time.sleep(5)
                    mount_target = efs_client.describe_mount_targets(FileSystemId=fs_id)
                    states = [mt['LifeCycleState'] for mt in mount_target['MountTargets'] if mt['MountTargetId'] == mount_target_id]
                    state = states[0] if states else ""
                    print(f"Current state: {state}")                

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando todos os pontos de montagem existentes no sistema de arquivo de tag de nome {tag_name_fs}")
                for mt in mount_targets_response['MountTargets']:
                    print(mt['MountTargetId'])
        else:
            print(f"Não existe nenhum ponto de montagem no sistema de arquivos de tag de nome {tag_name_fs} na AZ {a_z}")
    else:
        print(f"Não existe o sistema de arquivos de tag de nome {tag_name_fs}")
else:
    print("Código não executado")