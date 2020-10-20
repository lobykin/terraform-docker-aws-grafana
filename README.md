# Inventory Repository for monitoring Nginx Instance(s)

Deploying Grafana and InfluxDB on EC2 host

Run this CI/CD before spawning [AWS EC2 Nginx Instances](https://github.com/lobykin/tf-aws-ansible-nginx)

```yaml
    AWS_ACCESS_KEY_ID: standard environment variable for AWS auth
    AWS_SECRET_ACCESS_KEY: standard environment variable for AWS auth
    EC2_KEY_PEM_64: encrypted base64 pem key for EC2 instance access
    EC2_KEY_PUB_64: encrypted base64 pub key for EC2 instance access
    INFLUXDB_USER_PASSWORD: Telegraf user password
    INFLUXDB_ADMIN_PASSWORD: InfluxDB admin password
    INFLUXDB_ADMIN_USER: InfluxDB admin user name
    INFLUXDB_DB: InfluxDB Database Monitoring time series data from telegraf
    INFLUXDB_USER: Telegraf user name
```

For key encription use command:

```bash
cat ~/.ssh/ec2_key_pair.pem | openssl base64 | tr -d '\n'
```

Grafana Monitoring Plugins Recommended:

 1. NGINX METRICS `Import ID - 8531`
 2. Telegraf system overview `Import ID - 914`
 3. Docker - `Import ID -3056`
 4. Amazon Standard Dashboards
