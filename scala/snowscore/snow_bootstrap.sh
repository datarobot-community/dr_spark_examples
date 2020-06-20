# https://medium.com/@tedherman/compile-scala-on-emr-cb77610559f0

# install sbt 1.3.10 
wget https://piccolo.link/sbt-1.3.10.tgz
tar xf sbt-1.3.10.tgz
sudo mv sbt /opt

# include sbt executable into path
sudo sh -c 'echo "export PATH=$PATH:/opt/sbt/bin" > /etc/profile.d/999-path-export.sh'


# easily grab my source code
sudo sh -c 'echo "alias getcode=\"aws s3 cp s3://bucket/ybspark/snowscore.tar.gz snowscore.tar.gz; gunzip snowscore.tar.gz; tar -xvf snowscore.tar\"" >> /etc/profile.d/999-path-export.sh'

# easily store my source code
sudo sh -c 'echo "alias storecode=\"tar -zcvf snowscore.tar.gz snowscore; aws s3 cp snowscore.tar.gz s3://bucket/ybspark/snowscore.tar.gz\"" >> /etc/profile.d/999-path-export.sh'

# build jar package
sudo sh -c 'echo "alias buildjar=\"sbt clean; sbt package\"" >> /etc/profile.d/999-path-export.sh'

# store jar backage
sudo sh -c 'echo "alias storejar=\"aws s3 cp target/scala-2.11/score_2.11-0.1.0-SNAPSHOT.jar s3://bucket/ybspark/score_2.11-0.1.0-SNAPSHOT.jar\"" >> /etc/profile.d/999-path-export.sh'

# add some packages to zeppelin environment call
# or not - this seems to cause a boostrap failure, perhaps due to the bootstrap taking place before the file below exists!
#sudo sed -i 's/isPython=true/isPython=true --packages net.snowflake:snowflake-jdbc:3.12.5,net.snowflake:spark-snowflake_2.11:2.7.1-spark_2.4,com.datarobot:scoring-code-spark-api_2.4.3:0.0.19,com.datarobot:datarobot-prediction:2.1.4/g' /usr/lib/zeppelin/conf/zeppelin-env.sh

