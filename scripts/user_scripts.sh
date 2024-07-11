# Update parameter group
aws rds modify-db-parameter-group \
    --db-parameter-group-name my-custom-mysql-param-group \
    --parameters "ParameterName=binlog_format,ParameterValue=ROW,ApplyMethod=immediate"

# Modify the DB instance
aws rds modify-db-instance \
    --db-instance-identifier mydbinstance \
    --db-parameter-group-name my-custom-mysql-param-group \
    --apply-immediately

# Reboot instance
aws rds reboot-db-instance --db-instance-identifier mydbinstance