# CoVision API

API for the CoVision project. Provide an endpoint to infer the model and return the Covid results.

The model files are stored with Git LFS. To download the model files, you need to install Git LFS. You can install Git LFS by following the instructions [here](https://git-lfs.github.com/).


## Development
```bash
# build the docker image
docker build -t covision_api:local .

# run the docker container
docker run -p 9000:8080 -e BYPASS_AUTH=true covision_api:local
# using another terminal to test the API
curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
```
