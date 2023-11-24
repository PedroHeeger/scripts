#!/usr/bin/env python

print("***********************************************")
print("AWS CLI INSTALLATION (Python)")

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