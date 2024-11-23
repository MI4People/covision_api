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


## Deployment
```bash
cd terraform
terraform apply
```


push the docker image to ecr
```bash
# Login to ecr repo from aws cloud cli
export ECR_REPO=181232496617.dkr.ecr.eu-central-1.amazonaws.com/covision-api
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ECR_REPO}
###


export ECR_REPO=181232496617.dkr.ecr.eu-central-1.amazonaws.com/covision-api

# pull public image
docker pull diskun00/covision-api:v2

# add ecr tag
docker tag diskun00/covision:v3 ${ECR_REPO}/covision-api:v3

# push to ecr
docker push ${ECR_REPO}/covision-api:v3
```


```bash
export ECR_REPO=181232496617.dkr.ecr.eu-central-1.amazonaws.com/covision-api
# login to your github container registry via your own PAT
docker login ghcr.io -u diskun00

docker pull ghcr.io/mi4people/covision-api:latest
docker tag ghcr.io/mi4people/covision-api:latest ${ECR_REPO}/covision-api:v3
#docker tag ghcr.io/mi4people/covision-api:latest ${ECR_REPO}/covision-api:latest

```