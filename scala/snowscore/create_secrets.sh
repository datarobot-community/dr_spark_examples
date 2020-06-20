###
# 
# CLI command to create or update secrets
# Mike Taveirne (doyouevendata) 5/30/2020
#
###

. env_config.sh

SECRET_NAME="snow/titanic"
SECRET_NAME_SEARCH="\"$SECRET_NAME\""

CMD="aws $PROFILE secretsmanager list-secrets | grep '$SECRET_NAME_SEARCH' | wc -l"
CNT=`eval ${CMD}`

if [ $CNT = 1 ]
then
	echo "Updating Secrets..."
	aws $PROFILE secretsmanager update-secret --secret-id $SECRET_NAME --secret-string file://secrets.properties
else
	echo "Creating Secrets..."
	aws $PROFILE secretsmanager create-secret --name $SECRET_NAME \
		--description "database and datarobot credentials for emr spark job" \
		$SECRETS_TAGS \
		--secret-string file://secrets.properties
fi
