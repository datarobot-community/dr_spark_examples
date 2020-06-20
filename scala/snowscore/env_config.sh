###
#
# Non-secrets environmental property file for EMR environments
# Mike Taveirne (doyouevendata) 5/30/2020
#
# specifies several existing properties
#
# - EC2: instance profile yb_EMR - IAM Role with SecretsManagerReadWrite and AmazonElasticMapReduceforEC2Role
# - VPC: "SubnetId":"subnet-0123456789" - public subnet of VPC
# - EC2_Master_SG: "EmrManagedMasterSecurityGroup":"sg-0123456788" - masster group built off of EMR defaults, with allowed ssh inbound
# - EC2_Slave_SG: "EmrManagedSlaveSecurityGroup":"sg-0123456789" - slave group built off of EMR defaults
#
###

# set .pem file to use for ssh connectivity
KEY="pem_key"

# could be empty string if not using a profile
PROFILE="--profile support"

# applications
EMR_APPS="Name=Spark Name=Zeppelin"

# release
EMR_RELEASE="emr-5.30.0"

# region
EMR_REGION="us-east-1"

# config
EMR_CONFIG='[{"Classification":"spark","Properties":{}}]'

# service role
EMR_SERVICE_ROLE="EMR_DefaultRole"

# where logs will go
EMR_LOGS="s3n://bucket/ybspark/emr_logs/"

# could be empty string if not using a bootstrap script
EMR_BOOTSTRAP_DEV='--bootstrap-actions Path="s3://bucket/ybspark/snow_bootstrap.sh"'
EMR_BOOTSTRAP_PROD=''

# could be empty string if not using a bootstrap script
EMR_TAGS="--tags owner=doyouevendata environment=non-development cost_center=Success"
SECRETS_TAGS='--tags [{"Key":"owner","Value":"doyouevendata"},{"Key":"environment","Value":"non-development"},{"Key":"cost_center","Value":"Success"}]'

# cluster name
EMR_CLUSTER_NAME_DEV="YB Dev"
EMR_CLUSTER_NAME_PROD="YB Prod"

# VPC
VPC="subnet-01234565be02"

# EC2 info
EC2_Role="yb_EMR"
EC2_Master_SG="sg-07b123456"
EC2_Slave_SG="sg-050123456"


