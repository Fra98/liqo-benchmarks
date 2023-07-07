# Liqo Benchmarks (v0.8.3)

## 1) Clone repo
```
cd <PATH_REPO>
git clone https://github.com/fra98/liqo-benchmarks
cd liqo-benchmarks
```

## 2) Modify clusters values

In `./offloading/liqo-k3s-hollow/values.yaml` tune:
- consumer cluster (nodeAffinity, memory, cpu, etc..)
- provider cluster (nodeAffinity, memory, cpu, etc..)
- hollow nodes (nodeAffinity, memory, cpu, etc..)

Usually consumer and provider are scheduled on separate worker nodes. Hollow nodes can be scheduled on a third worker node (or more if necessary). Tune the affinity hostname depending on your nodes names.


## 3) Deploy the clusters + install Liqo

Run:

`helm install liqo-k3s-hollow ./offloading/liqo-k3s-hollow --namespace liqo-benchmarks --create-namespace`

The command:
- deploys consumer cluster (1 control plane)
- deploys provider cluster (1 control plane + N hollow nodes)
- installs Liqo on both clusters

## 4) Setup aliases useful for debug

```
CONSUMER=$(kubectl -n liqo-benchmarks get pod -l app.kubernetes.io/component=consumer --output custom-columns=':.metadata.name' --no-headers) 
PROVIDER=$(kubectl -n liqo-benchmarks get pod -l app.kubernetes.io/component=provider --output custom-columns=':.metadata.name' --no-headers)

CONSUMER_KUBECTL="kubectl -n liqo-benchmarks exec $CONSUMER -c k3s-server -- kubectl"
PROVIDER_KUBECTL="kubectl -n liqo-benchmarks exec $PROVIDER -c k3s-server -- kubectl"

CONSUMER_EXEC="kubectl -n liqo-benchmarks exec $CONSUMER -c k3s-server -- /bin/sh"
PROVIDER_EXEC="kubectl -n liqo-benchmarks exec $PROVIDER -c k3s-server -- /bin/sh"

CONSUMER_ENTER="kubectl -n liqo-benchmarks exec -it $CONSUMER -c k3s-server -- /bin/sh"
PROVIDER_ENTER="kubectl -n liqo-benchmarks exec -it $PROVIDER -c k3s-server -- /bin/sh"

CONSUMER_LIQOCTL="kubectl -n liqo-benchmarks exec $CONSUMER -c k3s-server -- liqoctl --kubeconfig /etc/rancher/k3s/k3s.yaml"
PROVIDER_LIQOCTL="kubectl -n liqo-benchmarks exec $PROVIDER -c k3s-server -- liqoctl --kubeconfig /etc/rancher/k3s/k3s.yaml"

alias ck=$CONSUMER_KUBECTL
alias pk=$PROVIDER_KUBECTL
alias ce=$CONSUMER_EXEC
alias pe=$PROVIDER_EXEC
alias cc=$CONSUMER_ENTER
alias pp=$PROVIDER_ENTER
alias cliqo=$CONSUMER_LIQOCTL
alias pliqo=$PROVIDER_LIQOCTL
```

## 5) Setup Liqo for the benchmark
- Download `liqoctl` (version v0.8.3) and run `mv liqoctl ~/.local/bin/liqoctl-v0.8.3`
- Run `./offloading/scripts/setup-liqo-v0.8.3.sh`

This step
- Copies the liqoctl binary into both clusters
- Peers the 2 clusters
- Cordons the provider node to prevent scheduling pods on it (so that they are all scheduled on the hollow nodes)


## 6) Run offloading benchmark

- In `./offloading/scripts/bench-offloading.sh` modify:
    - *RUNS*: number of times to repeat the tests 
    - *PODS_ARRAY*: number of pods to deploy
- Run:
```
./offloading/scripts/bench-offloading.sh \
	liqo \
	./offloading/scripts/manifests/offloading-measurer-liqo.yaml \
	./results/off-liqo
```


## 6) Export data in CSV

- Modify `./offloading/scripts/extract-offloading.py` to match the RUNS and PODS_ARRAY set at the previous step
- Run:
```
python3 ./offloading/scripts/extract-offloading.py \
    ./results/off-liqo \
    ./results/off-liqo/off-liqo.csv
```
