#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2")
print("KEY PAIR CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
key_pair_name = "keyPair1"
key_pair_path = "G:/Meu Drive/4_PROJ/scripts/scripts_model/power_shell/aws/"  # path

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")

if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço EC2")
    ec2 = boto3.client('ec2', region_name='us-east-1')

    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o par de chaves {key_pair_name}")
        existing_key_pairs = ec2.describe_key_pairs(KeyNames=[key_pair_name])
        
        if existing_key_pairs["KeyPairs"]:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"O par de chaves {key_pair_name} já foi criado!")
            print(f"Chave Pública:\n{existing_key_pairs['KeyPairs'][0]['KeyName']}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o par de chaves {key_pair_name}")
            key_pair = ec2.create_key_pair(KeyName=key_pair_name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Salvando a chave privada no arquivo .pem")
            with open(f"{key_pair_path}{key_pair_name}.pem", 'w') as pem_file:
                pem_file.write(key_pair['KeyMaterial'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Par de chaves {key_pair_name} criado com sucesso!")
            print(f"Chave Pública:\n{key_pair['KeyMaterial']}")

    # Caso de Erro: InvalidKeyPair.NotFound
    except ec2.exceptions.ClientError as e:
        if e.response['Error']['Code'] == 'InvalidKeyPair.NotFound':
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o par de chaves {key_pair_name}")
            key_pair = ec2.create_key_pair(KeyName=key_pair_name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Salvando a chave privada no arquivo .pem")
            with open(f"{key_pair_path}{key_pair_name}.pem", 'w') as pem_file:
                pem_file.write(key_pair['KeyMaterial'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Par de chaves {key_pair_name} criado com sucesso!")
            print(f"Chave Pública:\n{key_pair['KeyMaterial']}")
else:
    print("Código não executado")