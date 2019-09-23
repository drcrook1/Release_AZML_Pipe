#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

#Switching to Project Directory
cd $(System.DefaultWorkingDirectory)/src/python_release

#Docker Build Inf Container
echo "Building Promotion Container"
docker build -t mlbuild .

echo "Running Pipeline Promotion"
docker run -e SRC_SUBSCRIPTION_ID=$(SRC_SUBSCRIPTION_ID) 
            -e SRC_RESOURCE_GROUP=$(SRC_RESOURCE_GROUP) 
            -e SRC_WORKSPACE_NAME=$(SRC_WORKSPACE_NAME) 
            -e DEST_SUBSCRIPTION_ID=$(DEST_SUBSCRIPTION_ID) 
            -e DEST_RESOURCE_GROUP=$(DEST_RESOURCE_GROUP) 
            -e DEST_WORKSPACE_NAME=$(DEST_WORKSPACE_NAME) 
            -v /home/vsts/.azure/:/root/.azure/ # See Note 1
            -v $(Agent.HomeDirectory)/ml_temp/artifacts:/artifacts/ # See Note 2
            --name mlbuild --rmmlbuild

# NOTES
# ## Note 1 ##
#  This is for ADO Build Servers.  Essentially copy azure creds into containers /root/.azure folder is what you need to do.
#  Copies build servers azure logged in session to the running container's azure logged in session.
#  Replace with "-v c:/Users/%USERNAME%/.azure/:/root/.azure/" for local users wishing to build on a windows machine.
#
# ## Note 2 ##
#  This is a mapping to the /artifacts folder in the docker image such that key data required between build
#  Steps can be shared between build steps.