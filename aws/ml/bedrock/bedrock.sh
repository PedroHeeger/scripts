#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS BEDROCK"
echo "LISTANDO FOUNDATION MODELS (FM)"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [[ "${resposta,,}" == "y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Listando os foundation models (FMs)"
        models=$(aws bedrock list-foundation-models --query "modelSummaries" --output json)
    
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Exibindo os FMs"
    echo "$models" | jq -r '.[] | "\(.modelName), Input=\(.inputModalities | join("-")), Providers=\(.providerName)"'
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS BEDROCK"
echo "INTERACTION WITH FOUNDATION MODEL (FM)"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
# modelId="amazon.titan-text-express-v1"
# prompt="What is capital of Brazil?"
# maxTokenCount=10
# temperature=0
# topP=1

modelId="ai21.j2-ultra-v1"
prompt="What is capital of Brazil?"
max_tokens=200
temperature=0
topP=1

contentType="application/json"  # Tipo de conteúdo correto
accept="application/json"       # Tipo de resposta esperado
filePath="G:/Meu Drive/4_PROJ/scripts/aws/ml/bedrock/.output/output1.json"
outputText=""

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n): " resposta
if [[ "${resposta,,}" == "y" ]]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Criando o body da API request do modelo: $modelId"
    if [[ "$modelId" == "amazon.titan-text-express-v1" ]]; then
        body=$(cat <<EOF
{
    "inputText": "$prompt",
    "textGenerationConfig": {
      "maxTokenCount": $maxTokenCount,
      "temperature": $temperature,
      "topP": $topP
    }
}
EOF
        )
    elif [[ "$modelId" == "ai21.j2-ultra-v1" ]]; then
        body=$(cat <<EOF
{
    "prompt": "$prompt",
    "maxTokens": $max_tokens,
    "temperature": $temperature,
    "topP": $topP
}
EOF
        )
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Codificando o body em Base64"
    encodedBody=$(echo -n "$body" | base64)

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o arquivo de saída $filePath"
    if [[ ! -f "$filePath" ]]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o arquivo de saída $filePath"
        touch "$filePath"
    else
        echo "O arquivo de saída $filePath já existe"
    fi

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Invocando o modelo de inferência"
    aws bedrock-runtime invoke-model --body "$encodedBody" --content-type "$contentType" --accept "$accept" --model-id "$modelId" "$filePath"

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Exibindo o output (JSON)"
    fileContent=$(cat "$filePath")
    echo "$fileContent"

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Exibindo a resposta"
    fileContent=$(cat "$filePath" | jq -r)
    
    if [[ "$modelId" == "amazon.titan-text-express-v1" ]]; then
        outputText=$(echo "$fileContent" | jq -r '.results[0].outputText')
    elif [[ "$modelId" == "ai21.j2-ultra-v1" ]]; then
        outputText=$(echo "$fileContent" | jq -r '.completions[0].data.text')
    fi
    echo "$outputText"

    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o arquivo de saída $filePath"
    if [[ ! -f "$filePath" ]]; then
        echo "O arquivo de saída $filePath não existe"
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o arquivo de saída $filePath"
        rm -f "$filePath"
    fi
else
    echo "Código não executado"
fi