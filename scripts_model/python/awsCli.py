#!/usr/bin/env python

print("***********************************************")
print("AWS CLI INSTALLATION (Pip)")

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print("Importanto a library subprocess")
    import subprocess

    print("-----//-----//-----//-----//-----//-----//-----")
    print("Baixando e instalando o pacote")
    process = subprocess.run(["pip", "install", "awscli"], capture_output=True)
else:
    print("Código não executado")




#!/usr/bin/env python
 
print("***********************************************")
print("AWS CLI INSTALLATION (PowerShell)")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
link = "https://awscli.amazonaws.com/AWSCLIV2.msi"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print("Importanto a library subprocess")
    import subprocess

    print("-----//-----//-----//-----//-----//-----//-----")
    print("Baixando e instalando o pacote")
    subprocess.run(["msiexec.exe", "/i", link, "/qn"])
else:
    print("Código não executado")




#!/usr/bin/env python
 
print("***********************************************")
print("AWS CLI INSTALLATION (Bash)")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
link = "https://awscli.amazonaws.com/AWSCLIV2.msi"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print("Importanto a library subprocess")
    import subprocess

    print("-----//-----//-----//-----//-----//-----//-----")
    print("Baixando o pacote")
    subprocess.run(["curl", link, "-o", "awscliv2.zip"])

    print("-----//-----//-----//-----//-----//-----//-----")
    print("Descompactando o pacote")
    subprocess.run(["unzip", "awscliv2.zip"])

    print("-----//-----//-----//-----//-----//-----//-----")
    print("Instalando o pacote")
    subprocess.run(["./aws/install"])
else:
    print("Código não executado")




#!/usr/bin/env python
 
import botocore
from botocore import session

print("***********************************************")
print("AWS CLI CONFIGURATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
access_key = "SEU_ACCESS_KEY"
secret_key = "SEU_SECRET_KEY"
region = "us-east-1"
output_format = "json"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    session_data = {
        'aws_access_key_id': access_key,
        'aws_secret_access_key': secret_key,
        'region': region,
        'output': output_format,
    }

    session = botocore.session.get_session()
    session.set_config_variable('region', region)

    config_store = session.get_component('config_store')
    config_store.put('profile', session_data)

    print("Configuração do AWS CLI concluída com sucesso!")
else:
    print("Código não executado")