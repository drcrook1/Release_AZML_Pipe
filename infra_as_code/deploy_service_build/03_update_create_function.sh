#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

#Switching to Project Directory
cd $(System.DefaultWorkingDirectory)/src/deploy_function

#Docker Build Inf Container
echo "Building Promotion Container"
docker build -t funcbuild .

echo "Running Pipeline Promotion"
docker run -e SUBSCRIPTION_ID=$(SUBSCRIPTION_ID) 
            -e RESOURCE_GROUP=$(RESOURCE_GROUP) 
            -v /home/vsts/.azure/:/root/.azure/ # See Note 1
            -v $(Agent.HomeDirectory)/ml_temp/artifacts:/artifacts/ # See Note 2 & 3
            -v $(Agent.HomeDirectory)/drops/function_drop:/function_drop # See Note 4
            --name funcbuild funcbuild

# NOTES
# ## Note 1 ##
#  This is for ADO Build Servers.  Essentially copy azure creds into containers /root/.azure folder is what you need to do.
#  Copies build servers azure logged in session to the running container's azure logged in session.
#  Replace with "-v c:/Users/%USERNAME%/.azure/:/root/.azure/" for local users wishing to build on a windows machine.
#
# ## Note 2 ##
#  This is a mapping to the /artifacts folder in the docker image such that key data required between build
#  Steps can be shared between build steps.  
#
# ## Note 3 ##
#  The file update_create_pipe_artifacts.json is being dropped by the step which creates the pipeline.sh
#  This file is available on the build server and the directory is mapped into the executing container.
#
# ## Note 4 ##
#  A continuous Build should drop a .zip file for azure functions to deploy.  We map that into the container doing
#  the release.