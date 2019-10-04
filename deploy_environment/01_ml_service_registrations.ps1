# storage account name "[concat(toLower(parameters('baseName')), 'amlsa')]" = dacrookamlsa

$storage_key = ([string](az storage account keys list -g "dacrook-test-arm" -n "dacrookamlsa") | ConvertFrom-Json)[0].value

az ml datastore attach-blob -n "inputstore" -a "dacrookamlsa" -c "rawdata" -w "dacrook-AML-WS" --resource-group "dacrook-test-arm" -k $storage_key
az ml datastore attach-blob -n "outputstore" -a "dacrookamlsa" -c "processeddata" -w "dacrook-AML-WS" --resource-group "dacrook-test-arm" -k $storage_key
az ml datastore attach-blob -n "predictions" -a "dacrookamlsa" -c "predictions" -w "dacrook-AML-WS" --resource-group "dacrook-test-arm" -k $storage_key
az ml pipeline create -n "dacrook-inf-pipe" -y "ml_pipelines/inference_pipeline.yml" -w "dacrook-AML-WS" --resource-group "dacrook-test-arm"