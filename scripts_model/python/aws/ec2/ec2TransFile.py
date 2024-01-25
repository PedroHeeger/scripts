#!/usr/bin/env python

import subprocess
import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2")
print("EC2 TRANSFER FILES")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tag_name_instance = "ec2Test2"
key_pair_path = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/secrets/awsKeyPair"
key_pair_name = "keyPairUniversal"
aws_cli_path = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/secrets/awscli/iamUserWorker"
aws_cli_folder = ".aws"
docker_path = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/secrets"
docker_folder = ".docker"
vm_path = "/home/ubuntu"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço EC2")
    ec2 = boto3.resource('ec2') 

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a instância {tag_name_instance}")
    instances = list(ec2.instances.filter(Filters=[{'Name': 'tag:Name', 'Values': [tag_name_instance]}]))
    if instances:
        instance = instances[0]
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o IP público da instância de nome de tag {tag_name_instance}")
        ipEc2 = instance.public_ip_address

        print("Exibindo o comando para acesso remoto via OpenSSH")
        print(f'ssh -i "{key_pair_path}/{key_pair_name}.pem" ubuntu@{ipEc2}')

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se a pasta {aws_cli_folder} já existe na instância de nome de tag {tag_name_instance}")
        cmd = f'test -d "{vm_path}/{aws_cli_folder}" && echo "true" || echo "false"'
        folderExists = subprocess.getoutput(f'ssh -i "{key_pair_path}/{key_pair_name}.pem" -o StrictHostKeyChecking=no ubuntu@{ipEc2} "{cmd}"')

        if folderExists == 'true':
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"A pasta {aws_cli_folder} já existe na instância de nome de tag {tag_name_instance}. Transferência cancelada.")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Transferindo a pasta {aws_cli_folder} para a instância de nome de tag {tag_name_instance}")
            subprocess.run(f'scp -i "{key_pair_path}/{key_pair_name}.pem" -o StrictHostKeyChecking=no -r "{aws_cli_path}/{aws_cli_folder}" ubuntu@{ipEc2}:{vm_path}')

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se a pasta {docker_folder} já existe na instância de nome de tag {tag_name_instance}")
        cmd = f'test -d "{vm_path}/{docker_folder}" && echo "true" || echo "false"'
        folderExists = subprocess.getoutput(f'ssh -i "{key_pair_path}/{key_pair_name}.pem" -o StrictHostKeyChecking=no ubuntu@{ipEc2} "{cmd}"')

        if folderExists == 'true':
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"A pasta {docker_folder} já existe na instância de nome de tag {tag_name_instance}. Transferência cancelada.")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Transferindo a pasta {docker_folder} para a instância de nome de tag {tag_name_instance}")
            subprocess.run(f'scp -i "{key_pair_path}/{key_pair_name}.pem" -o StrictHostKeyChecking=no -r "{docker_path}/{docker_folder}" ubuntu@{ipEc2}:{vm_path}')
    else:
        print(f"Não existe instâncias com o nome de tag {tag_name_instance}")
else:
    print("Código não executado")
