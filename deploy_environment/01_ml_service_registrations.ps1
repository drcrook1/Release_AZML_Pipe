# storage account name "[concat(toLower(parameters('baseName')), 'amlsa')]" = dacrookamlsa

az ml datastore attach-blob -n "inputstore" -a "dacrookamlsa" -c "rawdata"
az ml datastore attach-blob -n "outputstore" -a "dacrookamlsa" -c "processeddata"
az ml datastore attach-blob -n "predictions" -a "dacrookamlsa" -c "predictions"
az ml pipeline create -name "dacrook-inf-pipe" `
                    -pipeline-yaml "ml_pipelines/inference_pipeline.yml"