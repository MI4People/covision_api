# Todos


### Local
- [x] enable function to read streaming image data instead of image path
- [ ] save requirements version into requirements.txt
- [ ] clean code locally, only keep core code
- [ ] test local core code

### AWS
- [ ] identify AWS architecture
 
- [ ] update absolute path for model
- [ ] upload model to repo


### Test lambda docker image locally
```bash
docker run -p 9000:8080 covision:latest


curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"version": "2.0", "routeKey": "POST /update", "rawPath": "/dev/update", "rawQueryString": "", "headers": {"accept": "*/*", "accept-encoding": "gzip, deflate, br", "content-length": "43", "content-type": "application/json", "host": "f9yw5j3nwj.execute-api.us-east-1.amazonaws.com", "postman-token": "63529c37-6f41-475f-a880-173070c9a8df", "user-agent": "PostmanRuntime/7.42.0", "x-amzn-trace-id": "Root=1-671dffa7-2f03720c75b684e646079aa0", "x-forwarded-for": "92.72.32.115", "x-forwarded-port": "443", "x-forwarded-proto": "https"}, "requestContext": {"accountId": "381492001354", "apiId": "f9yw5j3nwj", "domainName": "f9yw5j3nwj.execute-api.us-east-1.amazonaws.com", "domainPrefix": "f9yw5j3nwj", "http": {"method": "POST", "path": "/dev/update", "protocol": "HTTP/1.1", "sourceIp": "92.72.32.115", "userAgent": "PostmanRuntime/7.42.0"}, "requestId": "ATTiQjARoAMEcaA=", "routeKey": "POST /update", "stage": "dev", "time": "27/Oct/2024:08:53:59 +0000", "timeEpoch": 1730019239655}, "body": "{\r\n    \"image_data\":\"this is image data\"\r\n}", "isBase64Encoded": false}'



echo eyJwYXlsb2FkIjoiVUhucG5aeWR1T1Z4WE84ZmtUbGxQZWNocG9lTjdoM2kzb3h3MkN0NGt5OEpabVZLKzN1QVB2Wm5MRFRhTzFVN1J4b3F0ZXcxL3liUzF2SjlZWFlJSkxjeVp6K2pqK1RPbmNPSHQ3NS9IM3VZc2pzTjJwWXVpOVFpbVFocTVyWnR2d1BoWlJsMkE2aUtLdDZ1UGdVanBicjFqYSsyQ3QraEpxbWNabENFR2swMHEvY1N4T0w2SUFFN085NXhHM1AySG11cWRzVWZ6ZWRMeUp1aHBzQUJoQ1hVcFJMTnBwblJvUllGM0FLNGdlYUYvektoYlQ5S3cvZjEwMWhpN0RpL09wS1Jvd0Z0VXdQYVlFT01XVUZhNnBjN29HaDZLY044a1NWVzdlS0ptUENwMGIwWE1oOFNQZ3ozdXJhVUpwVDROY0xYallJQjUyYWtHRXNrazI2c0pOOW1EcEdEWElpaUNFd3ZnWHNUekNvd1N5M2ViNFpsdGN5L1ZCTXQvU3VGOXhnLzdUc3ZlZ3I3cGJ1a1k4VHpXZGNUYXE3OFlVeEh1TjJMTUFPQUtHcWp3RHNTTm5rM2N2a2FHbDFRWUtlaEcveGN0bFJLYjZVUStsTlpnRW01QmlOQU8xeFlCWDJDbXdzcHJleDQ2ajF1Q3NyVUI1WkZpcVlYenJ6VjNRUDgxY3lsbDdFbTI5Z0FwaDhnZW5LdGVMcEl3a2pnVkdPY0hEYXdGK1JsMFh4eVppNW1pYWsxNWswRG55UFhOTmN1bXkzTExscUphbTZVM3MyVDZSS0xnczFFZVF6dFBCNms4N2ZZR2d5TzU3bjlyWXhERUExU1A3Vm0yZVNQOUVUcnMyOFpkR1ZSVlREaW9Jb1dEZTZJK1JVSzhoK2VDV2lpL3hRYWpHcThrVi9EN3RZWHNQV3ZXeDVMNG83T0QwSzRUWEhPRmZTNTFvZ3FYNnhyVTh6aXROQkswMGp5WDNkai9WbDZrWGhZRTR3eG9qRERvMFVwVnFKUXJFMkd6TDdOS0FGQWhNUi9SdkVwMXNnNGJORU1RYm9ydnYrMStxWkxQekJvelFpekVhMFRmbnMxaVJESHpNeGR4NGQ1enNiVWdoakhxSTdEZExYeUhTb1dTa1EvRVY5T0hSNU9KQ0VCczRWOFZKU2RFNm9UVVk3SWlKK2VkOFF4dzIxOW9aeDc5MjN4N3FETE5kZ05ISGZubUltblpBTnhxckxDQjRYVklRd2NMQzVBMzJZUW1YUkxiVWFOT1ljSURTa1ZnUnhLaW9GZ2I1d3l3cVlsNENiSFlHcGNZWUNha0hDRy9wU1NQQ0FZc0dtcER0Y0c0d1VVWkZyOG8vU1VtTXdyS1F2SnQ4dHFZUUNzVXI1cnM1bFRIVW5zV3Q1RlJqVGZVbTRYOVEwN2U4WGJBNGZsQkpZRC9JMzY2cEdpQUVnU1FnMFl5THhVSnA1dFIxU3dBR0ZJRytDUk96QXBKRU0vbXViMkZxcXoybDRDRlN6NktOYlFXeGZQQ0NaRUIzUVo0YUZKWWsrWUdHc1p4dlJLTUlwc3lybWRobFhnam9VYUdhNlhoSzh2N21Yc2loV3EyTStWa0tVUWFGRDNtR1NhOWhDZ1lnaDIvMlowUXEzS3NqQ2pOMjgraWo4SGF5V1ciLCJkYXRha2V5IjoiQVFFQkFIaHdtMFlhSVNKZVJ0Sm01bjFHNnVxZWVrWHVvWFhQZTVVRmNlOVJxOC8xNHdBQUFINHdmQVlKS29aSWh2Y05BUWNHb0c4d2JRSUJBREJvQmdrcWhraUc5dzBCQndFd0hnWUpZSVpJQVdVREJBRXVNQkVFRE5WZmtSaTlWSmNXbFp3V0tBSUJFSUE3c0J1U1VIWlJrYUNQU2xBRVA4S0lBd28rYjAwZlR2dit5MUFvTG1IcGpTNkloMUxLbFBocGgwWFVVcVIreXRUQndrYUNwQkpaVGVFL0RpVT0iLCJ2ZXJzaW9uIjoiMiIsInR5cGUiOiJEQVRBX0tFWSIsImV4cGlyYXRpb24iOjE3MzAwNjY4OTN9 | docker login --username AWS 381492219349.dkr.ecr.us-east-1.amazonaws.com --password-stdin

```