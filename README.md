[![Code Climate](https://codeclimate.com/github/cilliemalan/motes.png)](https://codeclimate.com/github/cilliemalan/motes)
[![Build Status](https://travis-ci.org/cilliemalan/motes.png)](https://travis-ci.org/cilliemalan/motes)

# Motes
A collection of ideas for continuous integration and delivery using Kubernetes.

# Getting started
**Important:** This process will create a significant amount of GCP resources, it
is recommended that you have a $300 trial voucher, or at least terminate production
resources and disable production pipelines.


## Prerequisites
To run the project you will need:
1. [Download VirtualBox](https://www.virtualbox.org/wiki/Downloads) and install. This will
   be the minikube vm driver. (There are others but I'm going to use this one).
2. [Download Docker CE](https://docs.docker.com/engine/installation/) and install. On Windows this is going to be a schlep. You really
   only need a docker client, but go ahead and install the whole thing for
   what it's worth. Make sure that you **don't** configure docker to run with HyperV. You
   will need VirtualBox to work for minikube to work.
   (Note: Yes, I know Minikube supports HyperV. If you're feeling
   lucky you can try to get started with that but I haven't gotten it to work reliably).
3. [Download Minikube](https://github.com/kubernetes/minikube/releases) and put it
   somewhere in your PATH.
   - Run `minikube start` in some console window. This will host our local k8s cluster.
   - Run `minikube docker-env` and follow the instructions for said console. This
     is to make docker use the docker engine inside minikube, which means that any
     containers you build we be available inside k8s. Make sure docker works by
     running `docker ps` (it will show no running images but should not fail).
4. [Download kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and
   install it or get it in you PATH as well.
   - make sure it works by running `kubectl get all`. Note that minikube needs to
     download a number of images to get k8s started so it may take a few minutes
     for k8s to come online.
5. [Download GCloud SDK](https://cloud.google.com/sdk/downloads) and install.
6. [Download Terraform](https://www.terraform.io/) and 
   install it or get it in you PATH. *Terraform* will create our GoCD server for us and
   make sure DNS is pointing to the right place and everything. **Before you begin** make
   sure to tweak the settings inside `terraform.tfvars`. This file contains the settings
   for our project (DNS name, GCP project, etc.).
   - make sure Terraform works by running `terraform --version`
7. [Download NodeJS](https://nodejs.org/en/). Get the latest version, not LTS.
   - make sure it works by running `node --version` and `npm --version`

### A note about bash in windows
You will see this project exclusively makes use of bash scripts. In order to use these
scripts in windows you can use **git bash** which comes installed with *Git for Windows*.
The Linux Subsystem for Windows may also work, but will probably require a large number
of hacks to get kubectl, minikube, and virtualbox to work with it.

## GCP Project and variables
You will need to create a project on GCP and change the variables in `terraform.tfvars`
The variables in this file are used througout the scripts for the project. Even if you
don't intend to deploy your project into the cloud, it will still be a good idea to
create a GCP project regardless as many scripts do sanity checks in this regard.

Once the project is created you will have to run `gcloud init` and authorize that project.
You will also need to [create credentials and save them](https://cloud.google.com/docs/authentication#setting_up_a_service_account)
as `gcp-credentials.json`. **Do not commit credentials** The file `gcp-credentials.json` is
ignored by `.gitignore` by default.

# Getting started locally
Before we put this project in the cloud, let's get it running locally first.

The steps for running the application (including all supporting services) are:
  1. Create the k8s cluster
  2. Provision supporting services inside k8s (zookeeper, mongo, etc)
  3. Provision the application (for a remote deployment only)

In your development environment, step 3 is omitted and instead a dev pod is created 
directly and the application is run and debugged in that.

## 1. Prerequisites revisited
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

As you may have guessed, these pods correspond to the output of docker ps. The pods you
see running here are for kubernetes internal functions. You don't see them unless you
specify the kube-system namespace.

**Note:** You may want to check out the the k8s dashboard. This can be seen by running
`minikube dashboard` from the console. It's okay if it says "Nothing to display here". We
haven't created anything yet.

Next, we have a script that will quickly check that local prerequisite applications
are installed and available. To run it, run this from the project root:
```
$ ./build-scripts/check-prerequisites.sh
Checking prerequisites...
GCP Project: dust-motes
GCP Project: europe-west1
GCP Project: dust-motes.com
Could not sudo - good!
Docker good!
Docker perms good!
Kubectl good!
Terraform good!
Node good!
gcloud good!
gcloud project dust-motes good!
All good!
```

If it says "All good!" then all prereqs are accounted for and we can move on to the next step!

## 2. Local preparations
Next let's see if our local build prereqs are in order. This basically does npm install
and does a few linting checks

First, run the prereqs script:
```
$ ./build-scripts/local-prepare.sh
```

It will install node packages for the `web` project. This is not particularly important
as the project will only ever be run from inside a k8s pod, but for the prechecks it
uses mocha, so `npm install` it is...

Next, run some local tests:
```
$ ./build-scripts/run-tests.sh
up to date in 2.247s

> motes-web@1.0.0-alpha test C:\Projects\motes\web
> mocha -c"



  Testing system
    internals
      √ should function


  1 passing (16ms)

```

Everything passes, so let's move on.

### Note: Folder structure
Before moving on, let's take a quick look at the folder structure.

| Folder | What it's for |
|--------|---------------|
| `build-scripts` | Contains all scripts for the build process |
| `build-scripts/utilities` | Contains some helper scripts |
| `deployments` | Contains the k8s deployment spec files. Note: these files cannot be loaded as they are as they require some preprocessing. |
| `deployments/app` | Deployment files for the core application. |
| `deployments/ecosystem` | Deployment files for supporting infrastructure (e.g. redis, zookeeper) |
| `infrastructure-scripts` | Scripts for the goCD server. |
| `grafana`, `grafana-proxy`, `graphite`, `redis`, `zookeeper`, `web-proxy`, `web` | Each of these folders will be built into a docker image. The `docker-build-all.sh` script loops through all the directories and builds each one with a `Dockerfile` in it. |
| `web` | This is the main web application. |


## 3. Deploying supporting infrastructure
Now we are ready to starting making infrastructure. First thing is to build the docker images.

This will take a good while and a fast internet connection will help. Subsequent builds will be quick.

To build all docker images for our environment run:
```
$ ./build-scripts/build-docker-images.sh
```

### Secrets
We use kubernetes secrets to secure services within the kuberenetes cluster. We need to
generate secrets for each of our services to use before we create them.

To generate secrets inside k8s, run this:
```
$ ./build-scripts/generate-secrets.sh
Context "minikube" set.
secret "redis" created
secret "grafana" created
secret "zookeeper" created
secret "influxdb" created
```


### Deploy the services
Now that the secrets have been created and images have been built we can go ahead and
create all the supporting services. Doing so will start the following:
- **Grafana** - for displaying various graphs and monitorin for our application.
- **Grafana Proxy** - a HAProxy sitting in front of grafana.
- **InfluxDB** - for capturing time series data, used for monitoring our application.
- **MongDB** - a document store we can use as a database.
- **Redis** - an in-memory cache for our application (note: ours is not configured with persistence).
- **Zookeeper** - Allows for coordination of services (e.g. distributed locking, barriers, etc.).

To deploy these services run:
```
$ ./build-scripts/deploy-ecosystem.sh
```

Next, open up the minikube dashboard. You will notice under **Workloads** that a number of
deployments, stateful sets, replica sets, services, and pods have been created for these
services.

### 4. Local Dev Pod
Now that the ecosystem is deployed to our local cluster, let's get the application up and
running. In a remote environment we would have a number of pods running the application
as well as a number of proxy pods doing load balancing. For our local dev environment
we only have one pod that is tweaked very specifically for our development needs.

In order to have a smooth development experience, files are synced from our project folder
directly to the pod, and services are made so we can debug and browse application. Furthermore
the application is outfitted with nodemon, which will restart the application if any js files
were to change.

#### Creating the mount in virtualBox
*Unfortunately* to get this working, one manual step needs to be done. This can be automated
but at time of writing minikube has some problems and the mount needs to be created manually.
In order to sync the files a mount needs to be created on the minikube VM (note: not a container,
that does happen automatically, but the VM itself - the k8s host). In order to create the
mount, do the following:
1. Open VirtualBox manager. You will notice the minikube VM is running there.

   ![](http://i.imgur.com/hkjQ18j.png)
2. Select it and click **Settings** on the toolbar above

   ![](http://i.imgur.com/jywBKrh.png)
3. Next, go to **Shared Folders** on the left.

   ![](http://i.imgur.com/t2OUArv.png)
4. As you can see, there is an item in the list called "motes". You won't have this item
   and will need to create it. In order to create it, click the **+** button to the right.

   ![](http://i.imgur.com/4T8WPdQ.png)
5. A small dialog will pop up. In the first field enter the local path (on your computer)
   to the folder where you cloned this repo. As you may have guessed for me that is
   `C:\Projects\motes`.

   In the second field, enter the text **motes**. This is the name of the path where it
   will mount your local folder.

   Next check **Auto-mount** and **Make Permanent** and then click **Ok**.
6. To make sure that this worked, open a shell and type `minikube ssh`. This will SSH into
   the minikube VM. Once you are in, check that the path `/motes` contains the files. For
   example:

   ![](http://i.imgur.com/XVEKwdt.png)

No you're ready to move on to the next step!

#### Creating the local dev pod
The local dev pod builds an image based on *web* and creates a pod based on it directly
(e.g. no deployment or controller). It also creates two services, one for web and one
for debugging. The web service is a nodeport service listening on port 31000 and the
debugger on port 31858. To create the pod simply run:
```
$ ./build-scripts/utilities/prepare-local-dev-pod.sh
```

The script will exit once the pod is created. Check that everything is fine:
```
$ kubectl get pods -l app=local-dev
NAME        READY     STATUS    RESTARTS   AGE
local-dev   1/1       Running   0          13h
```

You can check the pod's logs by running
```
$ kubectl logs local-dev
```

You can also tail the log by running
```
$ kubectl logs local-dev -f
```

While you are developing, any problems will show up in the logs, so it's helpful to have
them tail in a window somewhere.

#### Check the application
To check the running application in your browser, run
```
$ minikube service local-dev
```
This will open a browser at the URL of running application. 

**Note:** If it opens up and says "Connection Refused" it likely means the
application crashed. Check the logs for why this may have happened. To restart
the application simply touch a js file (e.g. `touch web/index.js`) and nodemon
will restart the application.

If you just want the url of the application, simply run
```
$ minikube service local-dev --url
http://192.168.99.100:31000
```

#### Debug the application
The debugger is always listening in inspect mode, on the same ip address on
port 31858. To debug using Chrome, do this:
1. Open Chrome and browse to `chrome://inspect`

   ![](http://i.imgur.com/3CHuipf.png)

2. Click *Configure...* and enter the IP Address as above, but use the port 31858

   ![](http://i.imgur.com/1Dl5TuZ.png)

3. Click *Inspect* to start debugging:

   ![](http://i.imgur.com/rKpftbU.png)

   As you can see, it already shows the application logs in the console window.

4. As an exercise, let's create a breakpoint. Open up the file `api.js` by going to
   _Sources_ and navigating to `file:///` -> `usr/src/app` -> `app` -> `api.js`

   ![](http://i.imgur.com/Bsn757Q.png)

5. Add a breakpoint inside the `zookeeper` route handler:

   ![](http://i.imgur.com/Ri520rm.png)

6. Next, open the browser to the app and click on the zookeeper test:

   ![](http://i.imgur.com/UUlXRyM.png)

7. The breakpoint is hit!

   ![](http://i.imgur.com/EyLtXcY.png)

**This is an example of how to run and debug a nodejs application inside a Kubernetes
environment.**

#### Visual Studio Code
There also is included a launch config for attaching VSCode to the running k8s cluster
running the local dev pod. You may need to change the IP Address to match your local
minikube VM.

### 5. Unit Tests & Code Coverage
Now that the dev pod is up and running, we can run unit tests. Run:
```
$ ./build-scripts/run-unit-tests.sh
```

After this you should see that all tests pass. If some fail there is likely something
wrong with the ecosystem, so check which tests failed and check that those services
were created successfully.

#### Code Coverage
You can now check out code coverage in the `coverage` folder.


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
