#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM USER MFA CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamUserName="iamUserTest"
deviceName="deviceTest"
mfaFile="mfaTest.png"
mfaPath="G:\Meu Drive\4_PROJ\scripts\scripts_model\bash\.default\secrets"
userAccount="005354053245"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o usuário do IAM $iamUserName"
    condition=$(aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe um MFA associado ao usuário do IAM $iamUserName"
        condition=$(aws iam list-mfa-devices --user-name $iamUserName --query "MFADevices[].UserName[]" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Já existe um MFA associado ao usuário do IAM $iamUserName"
            aws iam list-mfa-devices --user-name $iamUserName --query "MFADevices[].EnableDate[]" --output text
        else
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas os dispositivos MFA associados ao usuário do IAM $iamUserName"
            aws iam list-mfa-devices --user-name $iamUserName

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Criando um dispositivo MFA"
            aws iam create-virtual-mfa-device --virtual-mfa-device-name $deviceName --outfile "$mfaPath/$mfaFile" --bootstrap-method QRCodePNG

            echo "-----//-----//-----//-----//-----//-----//-----"
            read -p "O MFA já foi configurado no dispositivo? (y/n) " resposta_mfa_configurado
            if [ "$(echo "$resposta_mfa_configurado" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                read -p "Digite o primeiro código de autenticação fornecido pelo dispositivo " code1
                read -p "Digite o segundo código de autenticação fornecido pelo dispositivo " code2

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Extraindo o número de série do primeiro MFA criado"
                deviceSerial="arn:aws:iam::${userAccount}:mfa/${deviceName}"

                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Ativando o MFA para o usuário do IAM $iamUserName"
                aws iam enable-mfa-device --user-name $iamUserName --serial-number $deviceSerial --authentication-code1 $code1 --authentication-code2 $code2
            else
                echo "O MFA precisa ser configurado em um dispositivo"
            fi

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando a data de ativação do MFA associado ao usuário do IAM $iamUserName"
            aws iam list-mfa-devices --user-name $iamUserName --query "MFADevices[].EnableDate[]" --output text
        fi
    else
        echo "Não existe o usuário do IAM $iamUserName"
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS IAM"
echo "IAM USER MFA EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
iamUserName="iamUserTest"
mfaFile="mfaTest.png"
mfaPath="G:\Meu Drive\4_PROJ\scripts\scripts_model\bash\.default\secrets"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o usuário do IAM $iamUserName"
    condition=$(aws iam list-users --query "Users[?UserName=='$iamUserName'].UserName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe um MFA associado ao usuário do IAM $iamUserName"
        condition=$(aws iam list-mfa-devices --user-name $iamUserName --query "MFADevices[].UserName[]" --output text | wc -l)
        if [[ "$condition" -gt 0 ]]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas os dispositivos MFA associados ao usuário do IAM $iamUserName"
            aws iam list-mfa-devices --user-name $iamUserName

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Extraindo o número de série do MFA criado"
            deviceSerial=$(aws iam list-mfa-devices --user-name $iamUserName --query "MFADevices[].SerialNumber[]" --output text)

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Desativando o MFA associado ao usuário do IAM $iamUserName"
            aws iam deactivate-mfa-device --user-name $iamUserName --serial-number $deviceSerial

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o MFA"
            aws iam delete-virtual-mfa-device --serial-number $deviceSerial

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Verificando se existe o arquivo de QRCode do MFA $mfaFile"
            if [ -f "$mfaPath/$mfaFile" ]; then
                echo "-----//-----//-----//-----//-----//-----//-----"
                echo "Removendo o arquivo de QRCode do MFA $mfaFile"
                rm "$mfaPath/$mfaFile"
            else
                echo "Não existe o arquivo de QRCode do MFA $mfaFile"
            fi

            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Listando todas os dispositivos MFA associados ao usuário do IAM $iamUserName"
            aws iam list-mfa-devices --user-name $iamUserName
        else
            echo "Não existe um MFA associado ao usuário do IAM $iamUserName"
        fi
    else
        echo "Não existe o usuário do IAM $iamUserName"
    fi
else
    echo "Código não executado"
fi