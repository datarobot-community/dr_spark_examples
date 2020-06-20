###
#
# CLI command to create EMR cluster on demand, run step task, then terminate the cluster 
# Mike Taveirne (doyouevendata) 5/30/2020
#
###

. env_config.sh

aws $PROFILE emr create-cluster \
   --applications $EMR_APPS \
   --termination-protected \
   --configurations $EMR_CONFIG \
   --service-role $EMR_SERVICE_ROLE \
   --enable-debugging \
   --release-label $EMR_RELEASE \
   --log-uri $EMR_LOGS \
   --auto-terminate \
   --ebs-root-volume-size 10 \
   --enable-debugging \
   --name "$EMR_CLUSTER_NAME_PROD" \
   --scale-down-behavior TERMINATE_AT_TASK_COMPLETION \
   --region $EMR_REGION \
   $EMR_TAGS \
   $EMR_BOOTSTRAP_PROD \
   --auto-scaling-role EMR_AutoScaling_DefaultRole \
   --ec2-attributes '{"KeyName":"'$KEY'","InstanceProfile":"'$EC2_Role'","SubnetId":"'$VPC'","EmrManagedSlaveSecurityGroup":"'$EC2_Slave_SG'","EmrManagedMasterSecurityGroup":"'$EC2_Master_SG'"}' \
   --instance-groups '[{"InstanceCount":1,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"InstanceGroupType":"MASTER","InstanceType":"m5.xlarge","Name":"Master Instance Group"},{"InstanceCount":2,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"InstanceGroupType":"CORE","InstanceType":"m5.xlarge","Name":"Core Instance Group"}]' \
   --steps '[{"Args":["spark-submit","--deploy-mode","cluster","--class","com.comm_demo.snow_example.SnowScore","--packages","net.snowflake:snowflake-jdbc:3.12.5,net.snowflake:spark-snowflake_2.11:2.7.1-spark_2.4,com.datarobot:scoring-code-spark-api_2.4.3:0.0.19,com.datarobot:datarobot-prediction:2.1.4","s3://bucket/ybspark/score_2.11-0.1.0-SNAPSHOT.jar"],"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar","Properties":"","Name":"YB Scoring Job"}]' 

