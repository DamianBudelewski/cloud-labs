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

### Key Route53 features that I research in this repo

##### DNS Failover
Description: Automatically route your website visitors to an alternate location to avoid site outages.

##### Health Checks and Monitoring
Description: Amazon Route 53 can monitor the health and performance of your application as well as your web servers and other resources.






