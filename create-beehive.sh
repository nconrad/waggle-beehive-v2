#!/bin/bash

setup_rabbitmq_user() {
    user="$1"
    password="$2"
    kubectl exec svc/rabbitmq -- bash -c "
rabbitmqctl add_user \"$user\" \"$password\" || rabbitmqctl change_password \"$user\" \"$password\"
rabbitmqctl set_permissions \"$user\" \".*\" \".*\" \".*\"
"
}

kubectl create -f rabbitmq.yaml

echo "waiting for rabbitmq"

while ! kubectl exec svc/rabbitmq -- rabbitmqctl await_startup --timeout 300; do
    sleep 1
done

setup_rabbitmq_user admin admin
setup_rabbitmq_user service service

# TODO extract config management as we get there
# kubectl create secret generic rabbitmq-service-secret \
#     --from-literal=RABBITMQ_SERVICE_USER=service \
#     --from-literal=RABBITMQ_SERVICE_PASSWORD=secret
