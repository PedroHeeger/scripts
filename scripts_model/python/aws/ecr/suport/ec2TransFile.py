#!/usr/bin/env python

import subprocess
import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2")
print("EC2 TRANSFER FILES")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
tagNameInstance = "ec2Test2"
keyPairPath = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/secrets/awsKeyPair"
keyPairName = "keyPairUniversal"
awsCliPath = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/secrets/awscli/iamUserWorker"
awsCliFolder = ".aws"
dockerPath = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/secrets"
dockerFolder = ".docker"
vmPath = "/home/ubuntu"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço EC2")
    ec2 = boto3.resource('ec2') 

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a instância {tagNameInstance}")
    instances = list(ec2.instances.filter(Filters=[{'Name': 'tag:Name', 'Values': [tagNameInstance]}]))
    if instances:
        instance = instances[0]
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo o IP público da instância de nome de tag {tagNameInstance}")
        ipEc2 = instance.public_ip_address

        print("Exibindo o comando para acesso remoto via OpenSSH")
        print(f'ssh -i "{keyPairPath}/{keyPairName}.pem" ubuntu@{ipEc2}')

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se a pasta {awsCliFolder} já existe na instância de nome de tag {tagNameInstance}")
        cmd = f'test -d "{vmPath}/{awsCliFolder}" && echo "true" || echo "false"'
        folderExists = subprocess.getoutput(f'ssh -i "{keyPairPath}/{keyPairName}.pem" -o StrictHostKeyChecking=no ubuntu@{ipEc2} "{cmd}"')

        if folderExists == 'true':
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"A pasta {awsCliFolder} já existe na instância de nome de tag {tagNameInstance}. Transferência cancelada.")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Transferindo a pasta {awsCliFolder} para a instância de nome de tag {tagNameInstance}")
            subprocess.run(f'scp -i "{keyPairPath}/{keyPairName}.pem" -o StrictHostKeyChecking=no -r "{awsCliPath}/{awsCliFolder}" ubuntu@{ipEc2}:{vmPath}')

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se a pasta {dockerFolder} já existe na instância de nome de tag {tagNameInstance}")
        cmd = f'test -d "{vmPath}/{dockerFolder}" && echo "true" || echo "false"'
        folderExists = subprocess.getoutput(f'ssh -i "{keyPairPath}/{keyPairName}.pem" -o StrictHostKeyChecking=no ubuntu@{ipEc2} "{cmd}"')

        if folderExists == 'true':
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"A pasta {dockerFolder} já existe na instância de nome de tag {tagNameInstance}. Transferência cancelada.")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Transferindo a pasta {dockerFolder} para a instância de nome de tag {tagNameInstance}")
            subprocess.run(f'scp -i "{keyPairPath}/{keyPairName}.pem" -o StrictHostKeyChecking=no -r "{dockerPath}/{dockerFolder}" ubuntu@{ipEc2}:{vmPath}')
    else:
        print(f"Não existe instâncias com o nome de tag {tagNameInstance}")
else:
    print("Código não executado")
