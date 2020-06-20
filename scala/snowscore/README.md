# snowscore

This project creates a scoring pipeline for data coming from a Snowflake database, which is scored through a DataRobot scoring code (binary jar export) model, then written back to Snowflake or written to S3.  This pipeline is executed on AWS EMR.  The code is written in scala.  Helper functions for creating a development environment and production job are included which leverage the AWS CLI.  

## Usage 

See the associated DataRobot community article written by [doyouevendata](https://community.datarobot.com/t5/user/viewprofilepage/user-id/50) for detailed usage info of associated assets.

create_dev_cluster.sh - AWS CLI script to create development EMR cluster with connectivity links for convenience \
create_secrets.sh - AWS CLI script to create/replace secrets string with AWS Secrets Manager \
env_config.sh - AWS environment variables \
run_emr_prod_job.sh - AWS CLI script to create production run EMR job with a step submit jar \
secrets.properties - sensitive properties to store in secret string \
snow.query - SQL query input to scoring job (stored in S3) \
snow_bootstrap.sh - post EC2 instance creation, pre EMR applications installation script (used in dev cluster) \
snowflake_scala_note.json - Zeppelin note containing scala code \
spark_env.sh - Spark environment variables (packages used by the project) \
snowscore/build.sbt - Spark packages used in sbt compilation of scala into jar \
snowscore/create_jar_package.sh - simple sbt script to create jar (executed in snowscore directory) \
snowscore/run_spark-shell.sh - run spark-shell with command to get necessary packages when invoked \
snowscore/run_spark-submit.sh - run spark-submit with command to get necessary packages when invoked \
snowscore/spark_env.sh - Spark environment packages (same as above) \
snowscore/src/main/scala/com/comm_demo/SnowScore.scala - scala source code for compiling into jar, to be able to spark-submit the job as a step on EMR
