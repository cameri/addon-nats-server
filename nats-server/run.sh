#!/usr/bin/env bashio

#set -euxo pipefail
set -euo pipefail
# source: https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425

CONFIG="/etc/nats/nats-server.conf"

# Root
{
    echo "port: 4222"
    echo "monitor_port: 8222"

    SERVER_NAME=$(bashio::config 'server_name' '143ce9cf-nats-server')
    echo "server_name: \"${SERVER_NAME}\""

    # JetStream
    # source: https://docs.nats.io/running-a-nats-service/configuration/resource_management
    if bashio::config.true 'jetstream.enabled'; then
        echo "jetstream {"
        echo "    store_dir: /data/storage"
        if bashio::config.exists 'jetstream.max_mem'; then
            echo "    max_mem: $(bashio::config 'jetstream.max_mem')"
        fi
        if bashio::config.exists 'jetstream.max_file'; then
            echo "    max_file: $(bashio::config 'jetstream.max_file')"
        fi
        if bashio::config.exists 'jetstream.chiper'; then
            echo "    chiper: $(bashio::config 'jetstream.chiper')"
        fi
        if bashio::config.exists 'jetstream.key'; then
            echo "    key: $(bashio::config 'jetstream.key')"
        fi
        echo "}" # jetstream
    fi

    # MQTT
    # source: https://docs.nats.io/running-a-nats-service/configuration/mqtt/mqtt_config
    if bashio::config.true 'mqtt.enabled'; then
        echo "mqtt {"
        echo "    port: 1883"
        if bashio::config.exists 'mqtt.username' || bashio::config.exists 'mqtt.password'; then
            echo "    authorization {"
            echo "        username: \"$(bashio::config 'mqtt.username' '')\""
            echo "        password: \"$(bashio::config 'mqtt.password' '')\""
            if bashio::config.exists 'mqtt.timeout'; then
                echo "        timeout: $(bashio::config 'mqtt.timeout')"
            fi
            echo "    }"
        fi

        if bashio::config.true 'cluster.tls'; then
            echo "    tls {"
            if bashio::config.exists 'cluster.tls_cert_file'; then
                echo "        cert_file: \"$(bashio::config 'cluster.tls_cert_file')\""
            fi
            if bashio::config.exists 'cluster.tls_key_file'; then
                echo "        key_file: \"$(bashio::config 'cluster.tls_key_file')\""
            fi
            if bashio::config.exists 'cluster.tls_ca_file'; then
                echo "        ca_file: \"$(bashio::config 'cluster.tls_ca_file')\""
            fi
            if bashio::config.exists 'cluster.tls_verify'; then
                echo "        verify: $(bashio::config 'cluster.tls_verify')"
            fi
            if bashio::config.exists 'cluster.tls_timeout'; then
                echo "        timeout: \"$(bashio::config 'cluster.tls_timeout')\""
            fi
            if bashio::config.exists 'cluster.tls_verify_and_map'; then
                echo "        verify_and_map: $(bashio::config 'cluster.tls_verify_and_map')"
            fi
            echo "    }" # tls
        fi
        echo "}" # mqtt
    fi

    # Clustering
    # source: https://docs.nats.io/running-a-nats-service/configuration/clustering/cluster_config
    if bashio::config.true 'cluster.enabled'; then
        echo "cluster {"
        echo "    port: 6222"

        if bashio::config.exists 'cluster.name'; then
            echo "    name: \"$(bashio::config 'cluster.name')\""
        fi
        if bashio::config.exists 'cluster.host'; then
            echo "    host: \"$(bashio::config 'cluster.host')\""
        fi

        if bashio::config.exists 'cluster.username' || bashio::config.exists 'cluster.password'; then
            echo "    authorization {"
            echo "    username: \"$(bashio::config 'cluster.username')\""
            echo "    password: \"$(bashio::config 'cluster.password')\""
            if bashio::config.exists 'cluster.timeout'; then
                echo "    timeout: $(bashio::config 'cluster.timeout')"
            fi
            echo "    }"
        fi

        # Routes
        echo "    routes = ["
        for route in $(bashio::config 'cluster.routes')
        do
            echo "        $route"
        done
        echo "    ]"


        if bashio::config.true 'mqtt.tls'; then
            echo "    tls {"
            if bashio::config.exists 'mqtt.tls_cert_file'; then
                echo "        cert_file: \"$(bashio::config 'mqtt.tls_cert_file')\""
            fi
            if bashio::config.exists 'mqtt.tls_key_file'; then
                echo "        key_file: \"$(bashio::config 'mqtt.tls_key_file')\""
            fi
            if bashio::config.exists 'mqtt.tls_ca_file'; then
                echo "        ca_file: \"$(bashio::config 'mqtt.tls_ca_file')\""
            fi
            if bashio::config.exists 'mqtt.tls_verify'; then
                echo "        verify: $(bashio::config 'mqtt.tls_verify')"
            fi
            if bashio::config.exists 'mqtt.tls_timeout'; then
                echo "        timeout: \"$(bashio::config 'mqtt.tls_timeout')\""
            fi
            if bashio::config.exists 'mqtt.tls_verify_and_map'; then
                echo "        verify_and_map: $(bashio::config 'mqtt.tls_verify_and_map')"
            fi
            echo "    }" # tls
            if bashio::config.exists 'mqtt.no_auth_user'; then
                echo "        no_auth_user: \"$(bashio::config 'mqtt.no_auth_user')\""
            fi
            if bashio::config.exists 'mqtt.ack_wait'; then
                echo "        ack_wait: \"$(bashio::config 'mqtt.ack_wait')\""
            fi
            if bashio::config.exists 'mqtt.max_ack_pending'; then
                echo "        max_ack_pending: $(bashio::config 'mqtt.max_ack_pending')"
            fi
        fi
    fi

    echo "}" # clustering

    # LeafNodes
    # source: https://docs.nats.io/running-a-nats-service/configuration/leafnodes
    echo "leafnodes {"
    if bashio::config.exists 'leafnodes.allow_incoming_connections'; then
        echo "    port = 7422"
    fi
    if bashio::config.exists 'leafnodes.remotes'; then
        echo "    remotes = ["
            for remote in $(bashio::config 'leafnodes.remotes')
            do
                REMOTE_URL=$(bashio::jq "$remote" '.url')
                REMOTE_CREDENTIALS=$(bashio::jq "$remote" '.credentials')
                echo "        {"
                echo "            url: \"$REMOTE_URL\""
                if [[ -n "$REMOTE_CREDENTIALS" ]]; then
                    echo "            credentials: \"$REMOTE_CREDENTIALS\""
                fi
                echo "        },"
            done
        echo "    ]"
    fi
    echo "}" # leafnodes

    # Logging
    # source: https://docs.nats.io/running-a-nats-service/configuration/logging
    if bashio::config.exists 'debug'; then
        echo "debug: $(bashio::config 'debug')"
    fi
    if bashio::config.exists 'trace'; then
        echo "trace: $(bashio::config 'trace')"
    fi
    if bashio::config.exists 'logtime'; then
        echo "logtime: $(bashio::config 'logtime')"
    fi
    if bashio::config.exists 'logfile_size_limit'; then
        echo "logfile_size_limit: $(bashio::config 'logfile_size_limit')"
    fi
    if bashio::config.exists 'log_file'; then
        echo "log_file: $(bashio::config 'log_file')"
    fi
} > "$CONFIG"

cat "$CONFIG"

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
    set -- nats-server "$@"
fi
# else default to run whatever the user wanted like "bash" or "sh"
exec "$@"
