#!/usr/bin/env powershell

Write-Host "***********************************************"
Write-Host "SERVIÇO: AWS BEDROCK"
Write-Host "LISTANDO FOUNDATION MODELS (FM)"

Write-Host "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n)"
if ($resposta.ToLower() -eq 'y') {
    Write-Host "-----//-----//-----//-----//-----//-----//-----"
    Write-Host "Listando os foundation models (FMs)"
    $models = aws bedrock list-foundation-models --query "modelSummaries" --output json | ConvertFrom-Json

    Write-Host "-----//-----//-----//-----//-----//-----//-----"
    Write-Host "Exibindo os FMs"
    foreach ($model in $models) {
        $inputModalities = $model.inputModalities -join "-"
        Write-Host "$($model.modelName), Input=$inputModalities, Providers=$($model.providerName)"
    }
} else {Write-Host "Código não executado"}




#!/usr/bin/env powershell

Write-Host "***********************************************"
Write-Host "SERVIÇO: AWS BEDROCK"
Write-Host "INTERACTION WITH FOUNDATION MODEL (FM)"

Write-Host "-----//-----//-----//-----//-----//-----//-----"
Write-Host "Definindo variáveis"
# $modelId = "amazon.titan-text-express-v1"
# $prompt = "What is capital of Brazil?"
# $maxTokenCount = 10
# $temperature = 0
# $topP = 1

$modelId = "ai21.j2-ultra-v1"
$prompt = "What is capital of Brazil?"
$max_tokens = 200
$temperature = 0
$topP = 1

$contentType = "application/json"  # Tipo de conteúdo correto
$accept = "application/json"       # Tipo de resposta esperado
$filePath = "G:/Meu Drive/4_PROJ/scripts/aws/ml/bedrock/.output/output1.json"
$outputText = $null

Write-Host "-----//-----//-----//-----//-----//-----//-----"
$resposta = Read-Host "Deseja executar o código? (y/n)"
if ($resposta.ToLower() -eq 'y') {
    Write-Host "-----//-----//-----//-----//-----//-----//-----"
    Write-Host "Criando o body da API request do modelo: $modelId"
    if ($modelId -eq "amazon.titan-text-express-v1") {
        $body = "{
            `"inputText`": `"$prompt`",
            `"textGenerationConfig`": {
              `"maxTokenCount`": $maxTokenCount,
              `"temperature`": $temperature,
              `"topP`": $topP
            }
          }"
    } elseif ($modelId -eq "ai21.j2-ultra-v1") {
        $body = "{
            `"prompt`": `"$prompt`",
            `"maxTokens`": $max_tokens,
            `"temperature`": $temperature,
            `"topP`": $topP
          }"
    }

    Write-Host "-----//-----//-----//-----//-----//-----//-----"
    Write-Host "Codificando o body em Base64"
    $encodedBody = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($body))

    Write-Host "-----//-----//-----//-----//-----//-----//-----"
    Write-Host "Verificando se existe o arquivo de saída $filePath"
    if (-not (Test-Path -Path $filePath)) {
        Write-Host "-----//-----//-----//-----//-----//-----//-----"
        Write-Host "Criando o arquivo de saída $filePath"
        New-Item -Path $filePath -ItemType File
    } else {Write-Host "O arquivo de saída $filePath já existe"}

    Write-Host "-----//-----//-----//-----//-----//-----//-----"
    Write-Host "Invocando o modelo de inferência"
    aws bedrock-runtime invoke-model --body $encodedBody --content-type $contentType --accept $accept --model-id $modelId $filePath

    Write-Host "-----//-----//-----//-----//-----//-----//-----"
    Write-Host "Exibindo o output (JSON)"
    $fileContent = Get-Content -Path $filePath
    Write-Host $fileContent

    Write-Host "-----//-----//-----//-----//-----//-----//-----"
    Write-Host "Exibindo a resposta"
    $fileContent = Get-Content -Path $filePath | ConvertFrom-Json
    if ($modelId -eq "amazon.titan-text-express-v1") {$outputText = $fileContent.results[0].outputText}
    elseif ($modelId -eq "ai21.j2-ultra-v1") {$outputText = $fileContent.completions[0].data.text}
    Write-Host $outputText  

    Write-Host "-----//-----//-----//-----//-----//-----//-----"
    Write-Host "Verificando se existe o arquivo de saída $filePath"
    if (-not (Test-Path -Path $filePath)) {Write-Host "O arquivo de saída $filePath não existe"}
    else {
        Write-Host "-----//-----//-----//-----//-----//-----//-----"
        Write-Host "Removendo o arquivo de saída $filePath"
        Remove-Item -Path $filePath
    }
} else {Write-Host "Código não executado"}