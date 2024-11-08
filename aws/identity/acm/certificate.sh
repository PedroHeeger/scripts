#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ACM"
echo "CERTIFICATE CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
# domainName="hosted-zone-test1.com.br"
domainName="pedroheeger.dev.br"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe um certificado para o domínio $domainName"
    condition=$(aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].DomainName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe um certificado para o domínio $domainName"
        aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].DomainName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando os nomes de domínio de todos certificados existentes"
        aws acm list-certificates --query "CertificateSummaryList[].DomainName" --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando um certificado para o domínio $domainName"
        aws acm request-certificate --domain-name $domainName --validation-method DNS

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando um certificado para o domínio $domainName"
        aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].DomainName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS ACM"
echo "CERTIFICATE EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
# domainName="hosted-zone-test1.com.br"
domainName="pedroheeger.dev.br"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$(echo "$resposta" | tr '[:upper:]' '[:lower:]')" == "y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe um certificado para o domínio $domainName"
    condition=$(aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].DomainName" --output text | wc -l)
    if [[ "$condition" -gt 0 ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando os nomes de domínio de todos certificados existentes"
        aws acm list-certificates --query "CertificateSummaryList[].DomainName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Extraindo o ARN do certificado para o domínio $domainName"
        certificateArn=$(aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$domainName'].CertificateArn" --output text)

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o certificado para o domínio $domainName"
        aws acm delete-certificate --certificate-arn $certificateArn
        sleep 5

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando os nomes de domínio de todos certificados existentes"
        aws acm list-certificates --query "CertificateSummaryList[].DomainName" --output text
    else
        echo "Não existe o certificado para o domínio $domainName"
    fi
else
    echo "Código não executado"
fi