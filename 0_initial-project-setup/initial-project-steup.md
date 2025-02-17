# GCP Initial Organization and Project Setup

<br>
Before you begin your GCP journey, yiu first will need to create a project.  This will be the container that will house your cloud resources.  (If you are familiar with Azure think of this as a resource group and if you are familiar with AWS think of this as your account.)

_Note:  It is possible to create a project without creating an organization first, however you will lose some features and IMO it is best practice (and time well spent) going through the motions of setting up and organization and attaching your projects to that organization as this is how you will likely see projects configured in the real world._

<br>

### Install `google-cloud-sdk` on Mac OSX

Before we jump into the resource deployment we will need a mechanism to deploy these resources.  GCP supports multiple ways of doing this ranging from using the GUI (cloud console) to leveraging IaC tooling like [Terrafrom](https://www.terraform.io/).  For the purposes of this project, I am going to focus on deploying resources via the [gcloud CLI](https://cloud.google.com/sdk/docs/install). This provides repeatability through code but reduces some complexity that you will introduce with tools like Terraform.

So, let's install the `gcloud` CLI.  I am on Mac, so naturally these commands will be bias'ed towards OSX specifics, but similar processes exist for the other major OS distributions. 

I use [Homebrew](https://brew.sh/) for a simple, one line install.

`brew install --cask google-cloud-sdk`

<br>

### Confirm Install

Once we get the install done, you can confirm the install and the path registrations are correct by running. 

`gcloud version`

You should get back specifics on your version of the CLI. 

```
Google Cloud SDK 504.0.0 
bq 2.1.11 
core 2024.12.13 
gcloud-crc32c 1.0.0 
gsutil 5.33 
```

Once you confirm the install, I like to do an update just to make sure I am running the latest and greatest. 

`gcloud components update`

Now on to configuring your project. 

<br>

### Create a GCP Organization

_Note: Although the [documentation](https://cloud.google.com/sdk/gcloud/reference/organizations) for gcloud organizations
command states that it is used to "create and manage Google Cloud Platform Organizations"
there is no command for create. You must create the organization from the console._

I setup a google workspace account with a domain I own [BeardedData.com](https://beardeddata.com) and (upon initial login to the [GCP console](https://console.cloud.google.com) an Organization is automatically created for that domain.

There are other ways to create an organization but this was the path that made sense for me. 

<br>

### Authenticate the CLI

Once the organization is created it's time to link the cli to your account. This will allow the cli to make changes to your organization (and later projects and resources) under the context of your user. 

1. Run the below command. It will open a web browser requesting you to login with the respective google account.

`gcloud auth login`

2. Login with email and password.
3. Upon successful login, return to the shell and you will see that your account is now logged in for use by the SDK for the remainder of the session.

<br>

### Create a project

1. List your organizations (you will need your organization's ID for the next command)

`gcloud organizations list`

2. Create a project in the appropriate organization by specifying the organization ID obtained from the above command.

`gcloud projects create bd-mustache --organization=1037451526863`

3. It will take a few seconds for the project to create, but you will eventually get a line signaling the project was successfully created similar to this one: 

`Operation "operations/acat.p2-527041803134-8baee9c9-fc54-4c55-ab13-ae71422c4e53" finished successfully.`

<br>

### Set default project_id in config

For convenience sake, you can now set your project id within the context of the `gcloud` CLI. 

`gcloud config set project bd-mustache`

<br>
<br>

__YOU ARE READY TO START EXPERIMENTING WITH THE GOOGLE CLOUD PLATFORM!__

<br>
<br>

<div align="center">
    <img src="../assets/bearded-data-logo.png" alt="Bearded Data Logo" width="300" height="300">
</div>

<h4 align="center">
  <a href="https://www.beardeddata.com/"> BeardedData.com </a>
