[![Code Climate](https://codeclimate.com/github/cilliemalan/motes.png)](https://codeclimate.com/github/cilliemalan/motes)
[![Build Status](https://travis-ci.org/cilliemalan/motes.png)](https://travis-ci.org/cilliemalan/motes)

# Motes
It's like, a thing.

# Getting started
**Important:** This process will create a significant amount of GCP resources, it
is recommended that you have a $300 trial voucher, or at least terminate production
resources and disable production pipelines.


## Prerequisites
To run the project you will need:
1. [Download Minikube](https://github.com/kubernetes/minikube/releases) and put it
   somewhere in your PATH.
   - Run `minikube start` in some console window. This will host our local k8s cluster.
   - Run `minikube docker-env` and follow the instructions for said console. This
     is to make docker use the docker engine inside minikube, which means that any
     containers you build we be available inside k8s. Make sure docker works by
     running `docker ps` (it will show no running images but should not fail).
2. [Download kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and
   install it or get it in you PATH as well.
   - make sure it works by running `kubectl get all`. Note that minikube needs to
     download a number of images to get k8s started so it may take a few minutes
     for k8s to come online.

*Note: you can see the k8s dashboard by running `minikube dashboard`*

# Getting started locally
The steps for running the application (including all supporting services) are:
  1. Create the k8s cluster
  2. Provision supporting services inside k8s (zookeeper, mongo, etc)
  3. Provision the application (for a remote deployment only)

In your development environment, step 3 is omitted and instead a dev pod is created 
directly and the application is run and debugged in that.

Before we put this project in the cloud, let's get it running locally first.

## Prerequisites revisited
I assume you have installed the prereqs above, but let's go over them once again to make
extra super duper sure everything is in place.

First, check that minikube is started
```
$ minikube status
minikubeVM: Started
localkube: Started
```

Make sure that your docker uses the minikube docker environment (see prereqs above).
Here it shows the running containers for the k8s cluster:
```
$ docker ps --filter "name=k8s" --format "{{.ID}} {{.RunningFor}} {{.Names}}"
time="2017-06-11T12:33:19+02:00" level=info msg="Unable to use system certificate pool: crypto/x509: system root pool is not available on Windows"
601e232b497b 27 minutes k8s_kubernetes-dashboard_kubernetes-dashboard-4gr01_kube-system_56044a71-4080-11e7-a2cd-080027bd13b0_7
a54a11542640 27 minutes k8s_POD_kubernetes-dashboard-4gr01_kube-system_56044a71-4080-11e7-a2cd-080027bd13b0_6
3d3fcecf5a37 27 minutes k8s_kubernetes-dashboard_kubernetes-dashboard-grtrm_kube-system_4981acfa-3fab-11e7-a9ff-080027bd13b0_13
3c1f22d3d01f 27 minutes k8s_POD_kubernetes-dashboard-grtrm_kube-system_4981acfa-3fab-11e7-a9ff-080027bd13b0_8
ee89665d1eff 27 minutes k8s_sidecar_kube-dns-268032401-w3dtb_kube-system_499889e1-3fab-11e7-a9ff-080027bd13b0_8
060a2a2224c0 27 minutes k8s_dnsmasq_kube-dns-268032401-w3dtb_kube-system_499889e1-3fab-11e7-a9ff-080027bd13b0_18
e85eefe96f2e 27 minutes k8s_kubedns_kube-dns-268032401-w3dtb_kube-system_499889e1-3fab-11e7-a9ff-080027bd13b0_8
ed01da2751c6 27 minutes k8s_POD_kube-dns-268032401-w3dtb_kube-system_499889e1-3fab-11e7-a9ff-080027bd13b0_8
204de1f0c15c 27 minutes k8s_kube-addon-manager_kube-addon-manager-minikube_kube-system_8538d869917f857f9d157e66b059d05b_8
fbef04554e81 27 minutes k8s_POD_kube-addon-manager-minikube_kube-system_8538d869917f857f9d157e66b059d05b_8
```

Make sure that kubectl is working:
```
$ kubectl get all --namespace kube-system
NAME                             READY     STATUS    RESTARTS   AGE
po/kube-addon-manager-minikube   1/1       Running   8          19d
po/kube-dns-268032401-w3dtb      3/3       Running   34         18d
po/kubernetes-dashboard-4gr01    1/1       Running   7          17d
po/kubernetes-dashboard-grtrm    1/1       Running   13         18d

NAME                      DESIRED   CURRENT   READY     AGE
rc/kubernetes-dashboard   1         1         1         18d

NAME                       CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
svc/kube-dns               10.0.0.10    <none>        53/UDP,53/TCP   18d
svc/kubernetes-dashboard   10.0.0.161   <nodes>       80:30000/TCP    18d

NAME              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/kube-dns   1         1         1            1           18d

NAME                    DESIRED   CURRENT   READY     AGE
rs/kube-dns-268032401   1         1         1         18d
```

As you may have guessed, these pods correspond to the output of docker ps.

# Deploying the project to GCP

First things first, you'll need a gocd server. This repos is fused with
[continuous-delivery-example](https://github.com/cilliemalan/continuous-delivery-example)
(i.e. all the files there are also in this project) so the readme there will get you
started.

Create the GoCD server by tweaking `terraform.tfvars` and the following the steps in
[the readme there](https://github.com/cilliemalan/continuous-delivery-example#continuous-delivery-example)

# Building this thing
Once your GoCD server has been set up, log in and head to config XML page 
(go to *Admin* -> *Config XML*). Edit this XML and add this XML node between
`<server>` and `<agents>`. Replace `YOUR REPO URL HERE` with your git URL (ending
with the .git) (**Important**: for some reason the thing freaks out if you put
it after `<agents>`).
```
<config-repos>
  <config-repo plugin="yaml.config.plugin">
    <git url="YOUR REPO URL HERE" />
  </config-repo>
</config-repos>
```
Save this config and head to the home page of your GoCD server. Give it a couple
of seconds and it should load it's pipeline config from the repo.

![Where to config XML](https://i.imgur.com/CdOECi6.png)

![Editing the repo](https://i.imgur.com/a9SdHMd.png)

![Et voilà](https://i.imgur.com/GSPCyEH.png)

*(Note: Screenshot may be old)*
