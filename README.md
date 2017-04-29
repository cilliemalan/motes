# Continuous Delivery Example
An example of getting a GoCD server up and running on GCP.

# Getting Started
The process will involve these steps:
1. Register domain on GCP
2. Register domain with registrar, wait for NS records to propogate
3. Provision GoCD server

Easy-peasy!

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

## Part 2: Register your domain/update NS records
Next you will need to log into your registrar and either buy the domain you specified
(if you havent already) and update the NS (nameserver) for it.

For example, here is the setup for cd-example.com on [Namecheap](https://www.namecheap.com)

1. On GCP head to [Cloud DNS](https://console.cloud.google.com/networking/dns/zones)
   ![The console](https://i.imgur.com/NTSKLEA.png "uptop")

2. Registrar setup:
   ![Registrar setup](https://i.imgur.com/N5P6AhT.png "Registrar setup")

3. Then on Namecheap console:
   ![Change nameservers](https://i.imgur.com/63MimGW.png "Change them NS recs")

4. Verify that it has propogated:
   ![On Windows](https://i.imgur.com/dhz8jx3.png "On windows")

   Or Linux:
   ![On Linux](https://i.imgur.com/yx60NeY.png "On linux")

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

   This will create your server. This will take about 6-7 minutes. Note the server will
   start and be responsive (have the green check) before the init script is done. You
   will be able to hit it in your browser once setup is done. If you want to check
   progress you can SSH in and `tail -f /var/log/syslog`.

   Once this is done you will be able to log in:
   ![woohoo](http://i.imgur.com/fueBaml.png "woohoo")

   The init script creates an `admin` user with password `cdpasswd`, which you should
   probably change.


# Changing GoCD password
Due to some...complexities...with GoCD, changing the password must be done while ssh'd into
the server.

```
> gcloud compute ssh gocd

~$ ADMIN_PASSWORD=<password here>
~$ echo "admin:$(echo -n "$ADMIN_PASSWORD"| openssl sha1 -binary | base64)" | sudo tee /etc/go/passwd
```

## Adding an account
You can also add an account:

```
~$ NEW_USERNAME=<username here>
~$ NEW_PASSWORD=<password here>
~$ echo "$NEW_USERNAME:$(echo -n "$NEW_PASSWORD"| openssl sha1 -binary | base64)" | sudo tee -a /etc/go/passwd
```

I think you get the idea...