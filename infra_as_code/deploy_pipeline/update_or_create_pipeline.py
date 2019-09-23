from azureml.core.workspace import Workspace
from azureml.core.authentication import ServicePrincipalAuthentication
from azureml.pipeline.core import PublishedPipeline
from azureml.data.data_reference import DataReference
from azureml.pipeline.core import PipelineData
from azureml.core import Datastore

import os
import json

def resolve_sub_id():
    return os.environ["SUBSCRIPTION_ID"]

def resolve_rg():
    return os.environ["RESOURCE_GROUP"]

def resolve_workspace_name():
    return os.environ["WORKSPACE_NAME"]

def resolve_pipeline_name():
    return os.environ["PIPELINE_NAME"]

def resolve_pipeline_version():
    return os.environ["PIPELINE_VERSION"]

def disable_old_pipes(az_ws : Workspace) -> None:
    pipes_list = PublishedPipeline.list(az_ws, active_only=True)
    pipe_name = resolve_pipeline_name()
    for pipe in pipes_list:
        if(pipe.name is pipe_name):
            pipe.disable()

def create_new_pipe(az_ws) -> str:
    data_store = Datastore(az_ws, "TODO")
    data_in = DataReference(
        datastore = data_store,
        data_reference_name="TODO",
        path_on_datastore="TODO"
    )

def write_temp_data(pipe_name : str, pipe_version : str, pipe_endpoint : str):
    if(not os.path.exists("/artifacts/")):
        os.makedirs("/artifacts/")
    artifacts = {}
    artifacts["pipe_name"] = pipe_name
    artifacts["pipe_version"] = pipe_version
    artifacts["pipe_endpoint"] = pipe_endpoint
    with open("/artifacts/update_create_pipe_artifacts.json", "w") as outjson:
        json.dump(artifacts, outjson)

def run():
    """
    No need to login due to mapping of az creds from ADO via -v docker mappings
    if not using ADO, 
    You must supply Service Principal Auth in similar env var fashion.
    """
    az_ws = Workspace(resolve_sub_id(), resolve_rg(), resolve_workspace_name())
    disable_old_pipes(az_ws)
    pipe_endpoint


if __name__ == "__main__":
    run()