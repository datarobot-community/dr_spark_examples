###
#
# CLI command to create EMR cluster on demand for developer environment or ad-hoc script running
# Mike Taveirne (doyouevendata) 5/30/2020
#
###

. env_config.sh

aws $PROFILE emr create-cluster \
   --applications $EMR_APPS \
   --configurations $EMR_CONFIG \
   --service-role $EMR_SERVICE_ROLE \
   --enable-debugging \
   --release-label $EMR_RELEASE \
   --log-uri $EMR_LOGS \
   --name "$EMR_CLUSTER_NAME_DEV" \
   --scale-down-behavior TERMINATE_AT_TASK_COMPLETION \
   --region $EMR_REGION \
   $EMR_TAGS \
   $EMR_BOOTSTRAP_DEV \
   --ec2-attributes '{"KeyName":"'$KEY'","InstanceProfile":"'$EC2_Role'","SubnetId":"'$VPC'","EmrManagedSlaveSecurityGroup":"'$EC2_Slave_SG'","EmrManagedMasterSecurityGroup":"'$EC2_Master_SG'"}' \
   --instance-groups '[{"InstanceCount":1,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"InstanceGroupType":"MASTER","InstanceType":"m5.xlarge","Name":"Master Instance Group"},{"InstanceCount":2,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"InstanceGroupType":"CORE","InstanceType":"m5.xlarge","Name":"Core Instance Group"}]' 

export DATE_SEARCH=`date -u -v -60S +%FT%T`

export CLUSTER=`aws $PROFILE emr list-clusters --active --created-after $DATE_SEARCH | grep Id | awk '{print $2}' | tr -d \"\, | head -1`

sleep 20

export MASTER_IP=`aws $PROFILE ec2 describe-instances --filters 'Name=tag:aws:elasticmapreduce:job-flow-id,Values='$CLUSTER 'Name=tag:aws:elasticmapreduce:instance-group-role,Values=MASTER' --query 'Reservations[*].Instances[*].PublicIpAddress' --output text`

# public DNS needs to be available instead of just IP to use the tunnel this simply
export MASTER_DNS=`aws $PROFILE ec2 describe-instances --filters 'Name=tag:aws:elasticmapreduce:job-flow-id,Values='$CLUSTER 'Name=tag:aws:elasticmapreduce:instance-group-role,Values=MASTER' --query 'Reservations[*].Instances[*].PublicDnsName' --output text`

echo ""
echo ""
echo "Master node can be connected to via ssh with: "
echo "ssh -i ~/$KEY.pem hadoop@$MASTER_IP"
echo ""
echo "Remote Zeppelin can be port forwarded to localhost with: "
echo "ssh -i ~/$KEY.pem -L 8890:$MASTER_DNS:8890 hadoop@$MASTER_DNS -Nv"
echo ""
echo "Cluster is $CLUSTER and can be terminated with: "
echo "aws $PROFILE emr terminate-clusters --cluster-ids $CLUSTER"
echo ""

#tag:aws:elasticmapreduce:job-flow-id : j-7MZKCPITBRW0
#tag:aws:elasticmapreduce:instance-group-role : MASTER
