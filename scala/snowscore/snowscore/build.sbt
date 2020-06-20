//import Dependencies._

ThisBuild / scalaVersion     := "2.11.12"
ThisBuild / version          := "0.1.0-SNAPSHOT"
ThisBuild / organization     := "com.comm_demo"
ThisBuild / organizationName := "comm_demo"

lazy val root = (project in file("."))
  .settings(
    name := "score",
    libraryDependencies ++= Seq(
      "net.snowflake" % "snowflake-jdbc" % "3.12.5",
      "net.snowflake" % "spark-snowflake_2.11" % "2.7.1-spark_2.4",
      "com.datarobot" % "scoring-code-spark-api_2.4.3" % "0.0.19",
      "com.datarobot" % "datarobot-prediction" % "2.1.4",
      "com.amazonaws" % "aws-java-sdk-secretsmanager" % "1.11.789",
      "software.amazon.awssdk" % "regions" % "2.13.23"
    ) 
  )

