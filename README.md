# Continuous Delivery Example
An example of CI and CD for a small Node.js project

# Getting Started
The first thing you will need is to get all the prereqs:

## Prerequisites
The folling things are needed:
- A GCP account with billing enabled. *Note: a number of steps will cost money*
- A blank GCP project where the infrastructure will be created.
- A domain for your project. This cannot be a subdomain like `whatever.somethingelse.com`
  but only something like `somethingelse.com`. You can purchase the
  domain after step 1 but you will have to pick the name of the domain before you
  start.
- Some software:
  - [Terraform](https://www.terraform.io/)
  - [Google Cloud SDK](https://cloud.google.com/sdk/). You will also need to create
    credentials and put them in the folder of this README as a file called `gcp-credentials.json`.
    alternatively you can update `terraform.tfvars` with the path.

## Part 1: Editing vars, registering domain
The first thing we have to do is to prepare the configuration for the infrastructure.
We are using [Terraform](https://www.terraform.io/) to provision the infrastructure within
GCP. The variables for Terraform can be found in `terraform.tfvars`. This file is automatically
loaded whenever Terraform is run.

1. As the first step you have to update `terraform.tfvars` with all your info. Also be prepared
   to register the domain you specify in the `domain` variable.
2. Once you have updated `terraform.tfvars`, we need to create one specific resource:
   the **DNS Zone Resource**. we need to do this first because domain registration
   is quite the manual process, and we need the nameservers GCP will assign.

   Note: I recommend using a .com or .net TLD because they check NS updates more quickly
   than the cheaper ones.

   First, plan to create the resource by running:

   ```
   terraform plan "-target=google_dns_managed_zone.dns"
   ```

   If the output looks good, you can go ahead and run

   ```
   terraform apply "-target=google_dns_managed_zone.dns"
   ```

3. Once the DNS recource has been created we need to check which nameservers it wants
   you to set for your domain. This can be found on your GCP control panel under
   *Networking* -> *Cloud DNS*, or by just opening `terraform.tfstate` and looking for
   the cached nameserver records.

   You will need to log into your registrar dashboard and update the NS (nameserver)
   records for your domain.

   If this is a .com domain the records will take a few minutes to update. If it's a random
   other domain (like .info or something) **this can take a few days**.

## Part 2: Create our GoCD server
The next step is to create our GoCD server

*Note: The default GOCD password is set to `cdpasswd`. If you want to change this, edit
`infrastructure-scripts/gocd-init.sh`. *Note that if you edit this file at all after
the infrastructure has been created,* **Terraform will recreate the gocd server**.

1. To create the server we simply run

   ```
   terraform plan
   ```

   You will notice this plans to create a server, a firewall rule, and a dns record.
   If this is all in order, go ahead and run

   ```
   terraform apply
   ```

   This will create your server. This will take about 10 minutes.

2. Next we need to register certificates for the server. For this step to work, you will
   need to wait for the NS records to propogate. You can check whether or not this has
   happened by running `nslookup gocd.<your domain>` on windows
   or `host gocd.<your domain>` on linux. for example:

   ```
    >nslookup gocd.cd-example.com

    Server:  UnKnown
    Address:  192.168.42.129

    Non-authoritative answer:
    Name:    gocd.cd-example.com
    Address:  35.187.162.56
   ```

   Once the DNS is working, we need to provision the certs on the server. It is important
   to not do this before it's done running the init script. You can confirm that the init
   script is done by running:

   ```
   curl --head http://gocd.cd-example.com
   ```

   If it shows a https redirect, the init script has completed. For example:

   ```
    > curl --head http://gocd.cd-example.com
    
    HTTP/1.1 301 Moved Permanently
    Server: nginx/1.12.0
    Date: Thu, 27 Apr 2017 11:04:42 GMT
    Content-Type: text/html
    Content-Length: 185
    Connection: keep-alive
    Location: https://gocd.cd-example.com/
   ```

   To register the certificates, make sure gcloud is configured (run `gcloud init`),
   and run:

   ```
   gcloud compute ssh gocd -- -c 'bash -s' < infrastructure-scripts/gocd-letsencrypt.sh
   ```

   *Note: if this gives you grief (i.e. on windows), just run `gcloud compute ssh gocd`
   and paste the contents of the script into the console window. If this still griefs
   you, ssh from the GCP console and do the same.*

   This will run for a few moments. If the output ends with:

   ```
   [ ok ] Restarting nginx (via systemctl): nginx.service.
   ```

   It means everything went well and you can hit the gocd server in your browser!

   ![woohoo](http://i.imgur.com/fueBaml.png "woohoo")

   The init script creates an `admin` user with password `cdpasswd`, which you should
   probably change.








# Changing GoCD password
Due to some...complexities...with GoCD, changing the password must be done while ssh'd into
the server.

```
> gcloud compute ssh gocd

~$ ADMIN_PASSWORD=<password here>
~$ echo "admin:$(python -c "import sha;from base64 import b64encode;print b64encode(sha.new('$ADMIN_PASSWORD').digest())")" > /etc/go/passwd
~$ exit
```