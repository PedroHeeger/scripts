#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS BEDROCK")
print("LISTING FOUNDATION MODEL (FM)")

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Listando os foundation models (FMs)")
    bedrock = boto3.client('bedrock')
    models = bedrock.list_foundation_models().get('modelSummaries')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Exibindo os FMs")
    for model in models:
        print(model['modelName'] + ', Input=' + '-'.join(model['inputModalities']) + ', Providers=' + model['providerName'])

else:
    print("Código não executado")   




#!/usr/bin/env python

import boto3
import json

print("***********************************************")
print("SERVIÇO: AWS BEDROCK")
print("INTERACTION WITH FOUNDATION MODEL (FM)")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
# model_id = "amazon.titan-text-express-v1"
# prompt = "What is capital of Brazil?"
# max_token_count = 10
# temperature = 0
# top_p = 1

model_id = "ai21.j2-ultra-v1"
prompt = "What is capital of Brazil?"
max_tokens = 200
temperature = 0
top_p = 1

content_type='application/json'  # Tipo de conteúdo correto
accept='application/json'       # Tipo de resposta esperado

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':   
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando o body da API request do modelo: {model_id}")
    client = boto3.client("bedrock-runtime", region_name="us-east-1")
    if model_id == "amazon.titan-text-express-v1":
        body = json.dumps(
            {"inputText": prompt,
            "textGenerationConfig": {
                "maxTokenCount": max_token_count,
                "stopSequences": [],
                "temperature": temperature,
                "topP": top_p
            }}
        )
    elif model_id == "ai21.j2-ultra-v1":
        body = json.dumps(
            {"prompt": prompt,
            "maxTokens": max_tokens,
            "temperature": temperature,
            "topP": top_p,
            }
        )

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Invocando o modelo de inferência")
    response = client.invoke_model(
        body=body, 
        contentType=content_type,
        accept=accept,  
        modelId=model_id
    )

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Extraindo a resposta")
    response_body = json.loads(response.get('body').read())
    if model_id == "amazon.titan-text-express-v1":
        outputText = response_body.get('results')[0].get('outputText').replace('"', '')
    elif model_id == "ai21.j2-ultra-v1":
        outputText = response_body.get('completions')[0].get('data').get('text').replace('"', '')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Exibindo a resposta")
    print(outputText)
else:
    print("Código não executado")