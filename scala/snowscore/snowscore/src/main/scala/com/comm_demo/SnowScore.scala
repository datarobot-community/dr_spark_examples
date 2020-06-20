package com.comm_demo.snow_example

import org.apache.spark.sql.functions.{col}
import org.apache.spark.sql.{DataFrame, Dataset, SparkSession}
import org.apache.spark.sql.SaveMode
import java.time.LocalDateTime
import com.amazonaws.regions.Regions
import com.amazonaws.services.secretsmanager.AWSSecretsManagerClientBuilder
import com.amazonaws.services.secretsmanager.model.GetSecretValueRequest
import org.json4s.{DefaultFormats, MappingException}
import org.json4s.jackson.JsonMethods._
import com.datarobot.prediction.spark.Predictors.{getPredictorFromServer, getPredictor}


object SnowScore {

	def printMsg(msg: String): (Unit) = {
		println(LocalDateTime.now() + " - " + msg)
	}

	/** get secret from secrets manager */
	def getSecret(secretName: String): (String) = {

		val region = Regions.US_EAST_1

		val client = AWSSecretsManagerClientBuilder.standard()
			.withRegion(region)
			.build()

		val getSecretValueRequest = new GetSecretValueRequest()
			.withSecretId(secretName)

		val res = client.getSecretValue(getSecretValueRequest)
		val secret = res.getSecretString

		return secret
	}

	def getSecretKeyValue(jsonString: String, keyString: String): (String) = {
		implicit val formats = DefaultFormats
        val parsedJson = parse(jsonString)  
		val keyValue = (parsedJson \ keyString).extract[String]
		return keyValue
	}

	def snowflakedf(defaultOptions: Map[String, String], sql: String) = {
		// https://stackoverflow.com/questions/60122372/passing-sparksession-as-function-parameters-spark-scala
		val spark = SparkSession.builder.getOrCreate()

		spark.read
		.format("net.snowflake.spark.snowflake")
		.options(defaultOptions)
		.option("query", sql)
		.load()
	}

	def main(args: Array[String]) {

		val SECRET_NAME = "snow/titanic"

		printMsg("db_log: " + "START")
		printMsg("db_log: " + "Creating SparkSession...")
		val spark = SparkSession.builder.appName("Score2main").getOrCreate();

		printMsg("db_log: " + "Obtaining secrets...")
		val secret = getSecret(SECRET_NAME)

		printMsg("db_log: " + "Parsing secrets...")
		val dr_host = getSecretKeyValue(secret, "dr_host")
		val dr_project = getSecretKeyValue(secret, "dr_project")
		val dr_model = getSecretKeyValue(secret, "dr_model")
		val dr_token = getSecretKeyValue(secret, "dr_token")
		val db_host = getSecretKeyValue(secret, "db_host")
		val db_db = getSecretKeyValue(secret, "db_db")
		val db_schema = getSecretKeyValue(secret, "db_schema")
		val db_user = getSecretKeyValue(secret, "db_user")
		val db_pass = getSecretKeyValue(secret, "db_pass")
		val db_query_file = getSecretKeyValue(secret, "db_query_file")
		val output_type = getSecretKeyValue(secret, "output_type")

		printMsg("db_log: " + "Retrieving db query...")
		val df_query = spark.read.text(db_query_file)
		val query = df_query.select(col("value")).first.getString(0)

		printMsg("db_log: " + "Extracting data from database...")
		val defaultOptions = Map(
			"sfURL" -> db_host,
			"sfAccount" -> db_host.split('.')(0),
			"sfUser" -> db_user,
			"sfPassword" -> db_pass,  
			"sfDatabase" -> db_db,
			"sfSchema" -> db_schema
		)

		val df = snowflakedf(defaultOptions, query)

		printMsg("db_log: " + "Loading Model...")
		val spark_compatible_model = getPredictorFromServer(host=dr_host, projectId=dr_project, modelId=dr_model, token=dr_token)

		printMsg("db_log: " + "Scoring Model...")
		val result_df = spark_compatible_model.transform(df)

		val subset_df = result_df.select("PASSENGERID", "target_1_PREDICTION")
		subset_df.cache()

		if(output_type == "s3") {
			val s3_output_loc = getSecretKeyValue(secret, "s3_output_loc")
			printMsg("db_log: " + "Writing to S3...")
			subset_df.write.format("csv").option("header","true").mode("Overwrite").save(s3_output_loc)
		}
		else if(output_type == "table") {
			val db_output_table = getSecretKeyValue(secret, "db_output_table")
			subset_df.write
                .format("net.snowflake.spark.snowflake")
                .options(defaultOptions)
                .option("dbtable", db_output_table)
                .mode(SaveMode.Overwrite)
                .save()
		}
		else {
			printMsg("db_log: " + "Results not written to S3 or database; output_type value must be either 's3' or 'table'.")
		}

		printMsg("db_log: " + "Written record count - " + subset_df.count())
		printMsg("db_log: " + "FINISH")
	}
}


