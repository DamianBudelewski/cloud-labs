# Route53

### Configuring SOPS

##### Encrypt parameters file
`sops --encrypt --input-type binary --kms "arn:aws:kms:......." parameters.json > parameters.enc.json`

##### Decrypt parameters file
`sops --decrypt --output-type binary parameters.enc.json > parameters.json`


### Setup the infrastructure

```bash
aws cloudformation create-stack --stack-name mastering-route53 --template-body file://mastering-route53.yaml --parameters file://parameters.json
```

### Upload index.html to S3
```bash
bucket_name=$(aws cloudformation describe-stacks --stack-name mastering-route53 --query "Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue" --output text)
aws s3 cp index.html s3://$bucket_name/index.html
```

### Key Route53 features that I research in this repo

##### DNS Failover
Description: Automatically route your website visitors to an alternate location to avoid site outages.

##### Health Checks and Monitoring
Description: Amazon Route 53 can monitor the health and performance of your application as well as your web servers and other resources.






