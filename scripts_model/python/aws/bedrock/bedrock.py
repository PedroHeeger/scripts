#!/usr/bin/env python

import boto3
import json

print("***********************************************")
print("SERVIÇO: AWS BEDROCK")
print("INTERACTION WITH FOUNDATION MODEL (FM)")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
modelId = "amazon.titan-text-express-v1"
# modelId = "ai21.j2-ultra-v1"
contentType='application/json'  # Tipo de conteúdo correto
accept='application/json'       # Tipo de resposta esperado

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Bedrock")
    client = boto3.client("bedrock-runtime", region_name="us-east-1")

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando o body da API request do modelo: {modelId}")
    body = json.dumps(
        {"inputText": "What is capital of Brazil?",
         "textGenerationConfig": {
            "maxTokenCount": 10,
            "stopSequences": [],
            "temperature": 0,
            "topP": 1
        }}
    )

    # print("-----//-----//-----//-----//-----//-----//-----")
    # print(f"Criando o body da API request do modelo: ai21.j2-ultra-v1")
    # body = json.dumps(
    #     {"prompt": "What is capital of Australia?",
    #      "maxTokens": 200,
    #      "temperature": 0.7,
    #      "topP": 1,
    #     }
    # )

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Invocando o modelo de inferência")
    response = client.invoke_model(
        body=body, 
        contentType=contentType,
        accept=accept,  
        modelId=modelId
    )

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Extraindo a resposta")
    response_body = json.loads(response.get('body').read())
    outputText = response_body.get('results')[0].get('outputText').replace('"', '')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Exibindo a resposta")
    print(outputText)

else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS BEDROCK")
print("LISTING FOUNDATION MODEL (FM)")

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço Bedrock")
    bedrock = boto3.client('bedrock')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Listando os foundation models (FMs)")
    models = bedrock.list_foundation_models().get('modelSummaries')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Exibindo os FMs")
    for model in models:
        print(model['modelName'] + ', Input=' + '-'.join(model['inputModalities']) + ', Providers=' + model['providerName'])

else:
    print("Código não executado")   