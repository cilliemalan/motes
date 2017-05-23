[![Code Climate](https://codeclimate.com/github/cilliemalan/motes.png)](https://codeclimate.com/github/cilliemalan/motes)
[![Build Status](https://travis-ci.org/cilliemalan/motes.png)](https://travis-ci.org/cilliemalan/motes)

# Motes
It's like, a thing.

# Getting started
**Important:** This process will create a significant amount of GCP resources, it
is recommended that you have a $300 trial voucher, or at least terminate production
resources and disable production pipelines.

# Running the project locally

## Prerequisites
To run the project you will need to:
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
     download a number of containers to get k8s started so it may take a few minutes
     for k8s to come online.

*Note: you can see the k8s dashboard by running `minikube dashboard`*

## Creating the environment
The steps for getting the application running on any environment are:
1. Create the k8s cluster
2. Provision supporting services inside k8s (zookeeper, mongo, etc)
3. Provision the application

In a development environment, step 3 is omitted and instead a dev pod is created 
directly and the application is run and debugged in that.


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
