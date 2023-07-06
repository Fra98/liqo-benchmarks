#!/bin/bash

# Aliases
CONSUMER=$(kubectl -n liqo-benchmarks get pod -l app.kubernetes.io/component=consumer --output custom-columns=':.metadata.name' --no-headers) 
PROVIDER=$(kubectl -n liqo-benchmarks get pod -l app.kubernetes.io/component=provider --output custom-columns=':.metadata.name' --no-headers)

CONSUMER_KUBECTL="kubectl -n liqo-benchmarks exec $CONSUMER -c k3s-server -- kubectl"
PROVIDER_KUBECTL="kubectl -n liqo-benchmarks exec $PROVIDER -c k3s-server -- kubectl"

CONSUMER_EXEC="kubectl -n liqo-benchmarks exec $CONSUMER -c k3s-server -- /bin/sh"
PROVIDER_EXEC="kubectl -n liqo-benchmarks exec $PROVIDER -c k3s-server -- /bin/sh"

CONSUMER_CMD="kubectl -n liqo-benchmarks exec $CONSUMER -c k3s-server --"
PROVIDER_CMD="kubectl -n liqo-benchmarks exec $PROVIDER -c k3s-server --"

CONSUMER_ENTER="kubectl -n liqo-benchmarks exec -it $CONSUMER -c k3s-server -- /bin/sh"
PROVIDER_ENTER="kubectl -n liqo-benchmarks exec -it $PROVIDER -c k3s-server -- /bin/sh"

CONSUMER_LIQOCTL="kubectl -n liqo-benchmarks exec $CONSUMER -c k3s-server -- liqoctl --kubeconfig /etc/rancher/k3s/k3s.yaml"
PROVIDER_LIQOCTL="kubectl -n liqo-benchmarks exec $PROVIDER -c k3s-server -- liqoctl --kubeconfig /etc/rancher/k3s/k3s.yaml"


# Installing liqo binary
cat $HOME/.local/bin/liqoctl-v0.8.3 | kubectl exec -i -n liqo-benchmarks $CONSUMER -c k3s-server "--" sh -c "cat > /bin/liqoctl && chmod +x /bin/liqoctl"
cat $HOME/.local/bin/liqoctl-v0.8.3 | kubectl exec -i -n liqo-benchmarks $PROVIDER -c k3s-server "--" sh -c "cat > /bin/liqoctl && chmod +x /bin/liqoctl"

# Peering
PEER_COMMAND=$($PROVIDER_LIQOCTL generate peer-command --only-command)
PEER_COMMAND=$(echo $PEER_COMMAND | cut -d' ' -f 2-) # Remove the first word (liqoctl)
$CONSUMER_LIQOCTL $PEER_COMMAND
