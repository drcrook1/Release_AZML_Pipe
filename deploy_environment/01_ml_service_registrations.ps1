# storage account name "[concat(toLower(parameters('baseName')), 'amlsa')]" = dacrookamlsa

param(
    [string]$pypiurl = "None",
    [string]$pypipackagename = "None"
)

$storage_key = ([string](az storage account keys list -g "dacrook-test-arm" -n "dacrookamlsa") | ConvertFrom-Json)[0].value

#
# Build Custom Image w/ Baked Custom Python Package
#
cd custom_docker
$acr_creds = az acr credential show --name "dacrookcustomacr" --resource-group "dacrook-test-arm" | ConvertFrom-Json
$acr_username = $acr_creds.username
$acr_password = $acr_creds.passwords[0].value

docker login -u $acr_username -p $acr_password "dacrookcustomacr.azurecr.io"
docker build -t "dacrookcustomacr.azurecr.io/customimage:latest" .
docker push "dacrookcustomacr.azurecr.io/customimage:latest"
cd ..

#
# Inject Custom Image to Run Configuration for Inference Pipeline
#
cd ..
((Get-Content -path src/Inference_Pipeline/src/base_run_config.yml -Raw) -replace '{{#YOUR_BASE_IMAGE#}}',"dacrookcustomacr.azurecr.io/customimage:latest") | Set-Content -Path src/Inference_Pipeline/src/run_config.yml
((Get-Content -path src/Inference_Pipeline/src/run_config.yml -Raw) -replace '{{#YOUR_ACR_SERVER#}}',"dacrookcustomacr.azurecr.io") | Set-Content -Path src/Inference_Pipeline/src/run_config.yml
((Get-Content -path src/Inference_Pipeline/src/run_config.yml -Raw) -replace '{{#YOUR_ACR_USER#}}',$acr_username) | Set-Content -Path src/Inference_Pipeline/src/run_config.yml
((Get-Content -path src/Inference_Pipeline/src/run_config.yml -Raw) -replace '{{#YOUR_ACR_PASSWORD#}}',$acr_password) | Set-Content -Path src/Inference_Pipeline/src/run_config.yml

((Get-Content -path src/Inference_Pipeline/src/base_conda_dependencies.yml -Raw) -replace '{{#PACKAGE_URL#}}',$pypiurl) | Set-Content -Path src/Inference_Pipeline/src/conda_dependencies.yml
((Get-Content -path src/Inference_Pipeline/src/conda_dependencies.yml -Raw) -replace '{{#PACKAGE_NAME#}}',$pypipackagename) | Set-Content -Path src/Inference_Pipeline/src/conda_dependencies.yml
cd .\deploy_environment

az ml datastore attach-blob -n "inputstore" -a "dacrookamlsa" -c "rawdata" -w "dacrook-AML-WS" --resource-group "dacrook-test-arm" -k $storage_key
az ml datastore attach-blob -n "outputstore" -a "dacrookamlsa" -c "processeddata" -w "dacrook-AML-WS" --resource-group "dacrook-test-arm" -k $storage_key
az ml datastore attach-blob -n "predictions" -a "dacrookamlsa" -c "predictions" -w "dacrook-AML-WS" --resource-group "dacrook-test-arm" -k $storage_key
$result_pipeline_create = az ml pipeline create -n "dacrook-inf-pipe" -y "ml_pipelines/inference_pipeline.yml" -w "dacrook-AML-WS" --resource-group "dacrook-test-arm"

Write-Host "Pipeline Endpoint: '$result_pipeline_create'";