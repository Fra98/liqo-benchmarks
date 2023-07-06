#!/bin/bash

set -e
set -o pipefail

NAMESPACE="liqo-benchmarks"

echo "Retrieving the configuration parameters..."
echo "Namespace: $NAMESPACE"

KUBECTL="kubectl --namespace $NAMESPACE"
CONSUMER=$($KUBECTL get pod -l app.kubernetes.io/component=consumer --output custom-columns=':.metadata.name' --no-headers)
PROVIDER=$($KUBECTL get pod -l app.kubernetes.io/component=provider --output custom-columns=':.metadata.name' --no-headers)

CONSUMER_KUBECTL="$KUBECTL exec $CONSUMER -c k3s-server -- kubectl"
PROVIDER_KUBECTL="$KUBECTL exec $PROVIDER -c k3s-server -- kubectl"

CONSUMER_EXEC="$KUBECTL exec $CONSUMER -c k3s-server -- /bin/sh"
PROVIDER_EXEC="$KUBECTL exec $PROVIDER -c k3s-server -- /bin/sh"

CONSUMER_ENTER="$KUBECTL exec -it $CONSUMER -c k3s-server -- /bin/sh"
PROVIDER_ENTER="$KUBECTL exec -it $PROVIDER -c k3s-server -- /bin/sh"

CONSUMER_CMD="$KUBECTL exec $CONSUMER -c k3s-server -- "
PROVIDER_CMD="$KUBECTL exec $PROVIDER -c k3s-server -- "

CONSUMER_LIQOCTL="$KUBECTL exec $CONSUMER -c k3s-server -- liqoctl --kubeconfig /etc/rancher/k3s/k3s.yaml"
PROVIDER_LIQOCTL="$KUBECTL exec $PROVIDER -c k3s-server -- liqoctl --kubeconfig /etc/rancher/k3s/k3s.yaml"


# Installing liqo binary
cat $HOME/.local/bin/liqoctl-v0.8.3 | kubectl exec -i -n liqo-benchmarks $CONSUMER -c k3s-server "--" sh -c "cat > /bin/liqoctl && chmod +x /bin/liqoctl"
cat $HOME/.local/bin/liqoctl-v0.8.3 | kubectl exec -i -n liqo-benchmarks $PROVIDER -c k3s-server "--" sh -c "cat > /bin/liqoctl && chmod +x /bin/liqoctl"

# Peering
PEER_COMMAND=$($PROVIDER_LIQOCTL generate peer-command --only-command)
PEER_COMMAND=$(echo $PEER_COMMAND | cut -d' ' -f 2-) # Remove the first word (liqoctl)
$CONSUMER_LIQOCTL $PEER_COMMAND

# Cordoning the provider node
echo "Cordoning the provider node to force pods to be scheduled on hollow nodes..."
$PROVIDER_KUBECTL cordon "$PROVIDER"