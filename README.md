[![Code Climate](https://codeclimate.com/github/cilliemalan/motes.png)](https://codeclimate.com/github/cilliemalan/motes)
[![Build Status](https://travis-ci.org/cilliemalan/motes.png)](https://travis-ci.org/cilliemalan/motes)

# Motes
It's like, a thing.

# Getting started
**Important:** This process will create a significant amount of GCP resources, it
is recommended that you have a $300 trial voucher, or at least terminate production
resources and disable production pipelines.

First things first, you'll need a gocd server. This repos is fused with
[continuous-delivery-example](https://github.com/cilliemalan/continuous-delivery-example)
so the readme there will get you started. Create the GoCD server by tweaking
`terraform.tfvars` and the following the steps in
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

The