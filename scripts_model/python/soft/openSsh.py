# #!/usr/bin/env python

# import subprocess

# print("***********************************************")
# print("OPENSSH INSTALLATION")

# print("-----//-----//-----//-----//-----//-----//-----")
# resposta = input("Deseja executar o código? (y/n) ").lower()
# if resposta == 'y':
#     print("-----//-----//-----//-----//-----//-----//-----")
#     print("Verificando se o OpenSSH está instalado")

#     try:
#         print("-----//-----//-----//-----//-----//-----//-----")
#         print("Verificando se o pacote está instalado")
#         subprocess.run(["dpkg", "-l", "openssh-server"], check=True)
#         print("OpenSSH já está instalado.")
#     except subprocess.CalledProcessError:
#         print("OpenSSH não está instalado")

#         print("-----//-----//-----//-----//-----//-----//-----")
#         print("Instalando o pacote")
#         subprocess.run(["sudo", "apt-get", "install", "-y", "openssh-server"], check=True)

#     print("-----//-----//-----//-----//-----//-----//-----")
#     print("Iniciando o serviço")
#     subprocess.run(["sudo", "service", "ssh", "start"], check=True)

#     print("-----//-----//-----//-----//-----//-----//-----")
#     print("Configurando para iniciar automaticamente")
#     subprocess.run(["sudo", "systemctl", "enable", "ssh"], check=True)

#     print("-----//-----//-----//-----//-----//-----//-----")
#     print("Verificando se a regra do firewall está configurada")
#     try:
#         subprocess.run(["sudo", "ufw", "status", "verbose"] , check=True)
#         print("A regra do firewall para o SSH já existe")
#     except subprocess.CalledProcessError:
#         print("Configurando a regra do firewall para o SSH")
#         subprocess.run(["sudo", "ufw", "allow", "22"], check=True)
# else:
#     print("Código não executado")




#!/usr/bin/env python

import os

print("***********************************************")
print("OPENSSH CREATION KEY")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
key_pair_name = "keyPair1"
key_pair_path = "G:/Meu Drive/4_PROJ/scripts/scripts_model/python/.default/test"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print("Construindo o caminho do arquivo de chave .pem")
    key_pair_file_path = os.path.join(key_pair_path, f"{key_pair_name}.pem")

    print("-----//-----//-----//-----//-----//-----//-----")
    print("Criando uma chave com senha vazia")
    os.system(f'ssh-keygen -t rsa -b 2048 -N "" -f "{key_pair_file_path}"')
else:
    print("Código não executado")
