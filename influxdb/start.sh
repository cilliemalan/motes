#!/bin/sh

createusers() (
    local adminusername=${INFLUXDB_ADMINUSERNAME:-admin}
    local adminpassword=${INFLUXDB_ADMINPASSWORD:-admin}
    local username=${INFLUXDB_USERNAME:-influx}
    local password=${INFLUXDB_PASSWORD:-influx}
    local database=${INFLUXDB_DEFAULT_DATABASE:-influx}

    local port=$(echo "$INFLUXDB_HTTP_BIND_ADDRESS" | grep -Eo '[0-9]+')

    sleep 1

    echo "Setting influxdb admin user"
    influx --port "$port" -execute "CREATE USER $adminusername WITH PASSWORD '$adminpassword' WITH ALL PRIVILEGES"

    echo "Creating default influxdb database"
    influx --port "$port" -username "$adminusername" -password "$adminpassword" -execute "CREATE DATABASE $database"

    echo "Creating default influxdb user"
    influx --port "$port" -username "$adminusername" -password "$adminpassword" -execute "CREATE USER $username WITH PASSWORD '$password'"
    influx --port "$port" -username "$adminusername" -password "$adminpassword" -execute "GRANT ALL on $database to $username"


)


# create users in background
echo "Kicking off user creation"
createusers &

# to connect:
# influx -username "$INFLUXDB_ADMINUSERNAME" -password "$INFLUXDB_ADMINPASSWORD"

echo "Starting influxdb"
influxd