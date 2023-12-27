#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM USER MFA CREATION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamUserName = "iamUserTest"
$deviceName = "deviceTest"
$mfaFile = "mfaTest.png"
$mfaPath = "G:\Meu Drive\4_PROJ\scripts\scripts_model\power_shell\.default\secrets"
$userAccount = "001727357081"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe um MFA associado ao usuário do IAM $iamUserName"
    if ((aws iam list-mfa-devices --user-name $iamUserName --query "MFADevices[].UserName[]").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Já existe um MFA associado ao usuário do IAM $iamUserName"
        aws iam list-mfa-devices --user-name $iamUserName --query "MFADevices[].EnableDate[]" --output text
    } else {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas os dispositivos MFA associados ao usuário do IAM $iamUserName"
        aws iam list-mfa-devices --user-name $iamUserName
    
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Criando um dispositivo MFA"
        aws iam create-virtual-mfa-device --virtual-mfa-device-name $deviceName --outfile "$mfaPath\$mfaFile" --bootstrap-method QRCodePNG

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        $resposta = Read-Host "O MFA já foi configurado no dispositivo? (y/n) "
        if ($resposta.ToLower() -eq 'y') {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            $code1 = Read-Host "Digite o primeiro código de autenticação fornecido pelo dispositivo "
            $code2 = Read-Host "Digite o segundo código de autenticação fornecido pelo dispositivo "

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Extraindo o número de série do primeiro MFA criado"
            $deviceSerial = "arn:aws:iam::${userAccount}:mfa/${deviceName}"

            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Output "Ativando o MFA para o usuário do IAM $iamUserName"
            aws iam enable-mfa-device --user-name $iamUserName --serial-number $deviceSerial --authentication-code1 $code1 --authentication-code2 $code2
        } else {Write-Host "O MFA precisa ser configurado em um dispositivo"}

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando a data de ativação do MFA associado ao usuário do IAM $iamUserName"
        aws iam list-mfa-devices --user-name $iamUserName --query "MFADevices[].EnableDate[]" --output text
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Output "***********************************************"
Write-Output "SERVIÇO: AWS IAM"
Write-Output "IAM USER MFA EXCLUSION"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
Write-Output "Definindo variáveis"
$iamUserName = "iamUserTest"
$mfaFile = "mfaTest.png"
$mfaPath = "G:\Meu Drive\4_PROJ\scripts\scripts_model\power_shell\.default\secrets"

Write-Output "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n) "
if ($resposta.ToLower() -eq 'y') {
    Write-Output "-----//-----//-----//-----//-----//-----//-----"
    Write-Output "Verificando se existe um MFA associado ao usuário do IAM $iamUserName"
    if ((aws iam list-mfa-devices --user-name $iamUserName --query "MFADevices[].UserName[]").Count -gt 1) {
        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas os dispositivos MFA associados ao usuário do IAM $iamUserName"
        aws iam list-mfa-devices --user-name $iamUserName

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Extraindo o número de série do MFA criado"
        $deviceSerial = aws iam list-mfa-devices --user-name $iamUserName --query "MFADevices[].SerialNumber[]" --output text

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Desativando o MFA associado ao usuário do IAM $iamUserName"
        aws iam deactivate-mfa-device --user-name $iamUserName --serial-number $deviceSerial

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Removendo o MFA"
        aws iam delete-virtual-mfa-device --serial-number $deviceSerial

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Verificando se existe o arquivo de QRCode do MFA $mfaFile"
        if (Test-Path "$mfaPath\$mfaFile" -PathType Leaf) {
            Write-Output "-----//-----//-----//-----//-----//-----//-----"
            Write-Host "Removendo o arquivo de QRCode do MFA $mfaFile"
            Remove-Item "$mfaPath\$mfaFile"
        } else {Write-Host "Não existe o arquivo de QRCode do MFA $mfaFile"}

        Write-Output "-----//-----//-----//-----//-----//-----//-----"
        Write-Output "Listando todas os dispositivos MFA associados ao usuário do IAM $iamUserName"
        aws iam list-mfa-devices --user-name $iamUserName
    } else {Write-Output "Não existe o usuário do IAM de nome $iamUserName"}
} else {Write-Host "Código não executado"}