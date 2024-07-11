# Update parameter group
aws rds modify-db-parameter-group \
    --db-parameter-group-name $PARAMETER_GROUP_NAME \
    --parameters "ParameterName=binlog_format,ParameterValue=ROW,ApplyMethod=immediate"

# Modify the DB instance
aws rds modify-db-instance \
    --db-instance-identifier $RDS_IDENTIFIER \
    --db-parameter-group-name $PARAMETER_GROUP_NAME \
    --apply-immediately \
    --output text

# Reboot instance
aws rds reboot-db-instance --db-instance-identifier $RDS_IDENTIFIER \
    --output text
