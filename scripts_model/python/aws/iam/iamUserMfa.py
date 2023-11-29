#!/usr/bin/env python

#pip install qrcode[pil]
#pip install pyotp
import boto3
import os
import pyotp
import qrcode

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM USER MFA CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_user_name = "iamUserTest"
device_name = "deviceTest"
mfa_file = "mfaTest.png"
mfa_path = "G:/Meu Drive/4_PROJ/scripts/scripts_model/python/.default/secrets"
user_account = "005354053245"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam_client = boto3.client('iam')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe um MFA associado ao usuário do IAM {iam_user_name}")
    mfa_devices = iam_client.list_mfa_devices(UserName=iam_user_name)['MFADevices']

    if mfa_devices:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe um MFA associado ao usuário do IAM {iam_user_name}")
        print("Data de ativação:", mfa_devices[0]['EnableDate'])
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas os dispositivos MFA associados ao usuário do IAM {iam_user_name}")
        print(mfa_devices)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Criando um dispositivo MFA")
        response = iam_client.create_virtual_mfa_device(VirtualMFADeviceName=device_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo o seed em Base32 para criação do QRCode")
        base32_seed = response['VirtualMFADevice']['Base32StringSeed']

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Gerando o QRCode e vinculando com a AWS")
        totp = pyotp.TOTP(base32_seed)
        uri = totp.provisioning_uri(name=f"{iam_user_name}:{device_name}", issuer_name="AWS")
        img = qrcode.make(uri)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Salvando o QRCode na pasta")
        img.save(os.path.join(mfa_path, mfa_file))
        # img.show()
        
        print("-----//-----//-----//-----//-----//-----//-----")
        resposta_mfa_configurado = input("O MFA já foi configurado no dispositivo? (y/n) ").lower()
        if resposta_mfa_configurado == 'y':
            print("-----//-----//-----//-----//-----//-----//-----")
            code1 = input("Digite o primeiro código de autenticação fornecido pelo dispositivo: ")
            code2 = input("Digite o segundo código de autenticação fornecido pelo dispositivo: ")

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Extraindo o número de série do primeiro MFA criado")
            device_serial = response['VirtualMFADevice']['SerialNumber']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Ativando o MFA para o usuário do IAM {iam_user_name}")
            iam_client.enable_mfa_device(UserName=iam_user_name, SerialNumber=device_serial, AuthenticationCode1=code1, AuthenticationCode2=code2)
        else:
            print("O MFA precisa ser configurado em um dispositivo")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando a data de ativação do MFA associado ao usuário do IAM {iam_user_name}")
        mfa_devices_after_activation = iam_client.list_mfa_devices(UserName=iam_user_name)['MFADevices']
        print("Data de ativação:", mfa_devices_after_activation[0]['EnableDate'])
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3
import os

print("***********************************************")
print("SERVIÇO: AWS IAM")
print("IAM USER MFA EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
iam_user_name = "iamUserTest"
mfa_file = "mfaTest.png"
mfa_path = "G:/Meu Drive/4_PROJ/scripts/scripts_model/python/.default/secrets"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço IAM")
    iam_client = boto3.client('iam')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe um MFA associado ao usuário do IAM {iam_user_name}")
    mfa_devices = iam_client.list_mfa_devices(UserName=iam_user_name)['MFADevices']

    if mfa_devices:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas os dispositivos MFA associados ao usuário do IAM {iam_user_name}")
        print(mfa_devices)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo o número de série do MFA criado")
        device_serial = mfa_devices[0]['SerialNumber']

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Desativando o MFA associado ao usuário do IAM {iam_user_name}")
        iam_client.deactivate_mfa_device(UserName=iam_user_name, SerialNumber=device_serial)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Removendo o MFA")
        iam_client.delete_virtual_mfa_device(SerialNumber=device_serial)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o arquivo de QRCode do MFA {mfa_file}")
        if os.path.isfile(os.path.join(mfa_path, mfa_file)):
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o arquivo de QRCode do MFA {mfa_file}")
            os.remove(os.path.join(mfa_path, mfa_file))
        else:
            print(f"Não existe o arquivo de QRCode do MFA {mfa_file}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas os dispositivos MFA associados ao usuário do IAM {iam_user_name}")
        mfa_devices_after_removal = iam_client.list_mfa_devices(UserName=iam_user_name)['MFADevices']
        print(mfa_devices_after_removal)
    else:
        print(f"Não existe o usuário do IAM de nome {iam_user_name}")
else:
    print("Código não executado")