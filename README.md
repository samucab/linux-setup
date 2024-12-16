# Linux Setup

This script will set your Pop-OS 22.04 LTS up and running after a fresh reinstall. Feel free to tailor it to your own needs, just as I did from the https://github.com/lewagon/dotfiles! 😉

## Step 1: Oh-my-zsh

This setup requires the Zsh (Z-Shell). To make terminal life more productive, we'll also install [Oh My Zsh](https://ohmyz.sh/). To kick it off, run the following commands on the default bash terminal. Accept changes to turn Oh My Zsh into default.

```bash
sudo apt-get install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Step 2: Shell script

Clone this repository and run the script from the project root directory. Review and accept changes when asked to.

```bash
zsh install.sh
```

It installs essential packages, command line tools, a few GNOME productivity tools, and the following software:

- [Firefox](https://www.mozilla.org/en-US/firefox/)
- [Simplenote](https://simplenote.com/)
- [Visual Studio Code](https://code.visualstudio.com/download#) and a pack of extensions
- [QGIS](https://qgis.org/)
- [Google Earth](https://www.google.com/earth/about/versions/#download-pro)
- [pyenv](https://github.com/pyenv/pyenv)
- [Python 3.12.6](https://www.python.org/)
- [GitHub CLI](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)
- [Google Cloud CLI](https://cloud.google.com/sdk)
- [Docker](https://www.docker.com/)

It additionally:
- upgrades installed apt packages, removes unused dependencies and cleans cache
- seeds dotfiles from the project folder
- configures Oh My Zsh with custom plugins
- configures VS Code with custom user settings
- loads custom GNOME settings

## Step 3: Docker

To avoid using sudo to run docker in the future, add your user to a new group and start a new shell session:

```bash
sudo groupadd docker || true
sudo gpasswd -a "$USER" docker
newgrp docker
```

## Step 4: GitHub CLI

This is a quick step-by-step guide to authenticate GitHub CLI.

**Login** to your GitHub account copy-pasting the following command in your terminal:

:warning: **DO NOT edit the `email`**

```bash
gh auth login -s 'user:email' -w
```

gh will ask you few questions:

`What is your preferred protocol for Git operations?` With the arrows, choose `SSH` and press `Enter`. SSH is a protocol to log in using SSH keys instead of the well known username/password pair.

`Generate a new SSH key to add to your GitHub account?` Press `Enter` to ask gh to generate the SSH keys for you.

If you already have SSH keys, you will see instead `Upload your SSH public key to your GitHub account?` With the arrows, select your public key file path and press `Enter`.

`Enter a passphrase for your new SSH key (Optional)`. Type something you want and that you'll remember. It's a password to protect your private key stored on your hard drive. Then press `Enter`.

`Title for your SSH key`. You can leave it at the proposed "GitHub CLI", press `Enter`.

You will then get the following output:

```bash
! First copy your one-time code: 0EF9-D015
- Press Enter to open github.com in your browser...
```

Select and copy the code (`0EF9-D015` in the example), then press `Enter`.

Your browser will open and ask you to authorize GitHub CLI to use your GitHub account. Accept and wait a bit.

Come back to the terminal, press `Enter` again, and that's it.

To check that you are properly connected, type:

```bash
gh auth status
```

:heavy_check_mark: If you get `Logged in to github.com as <YOUR USERNAME> `, then all good :+1:

## Step 5: GCloud CLI

This is a quick step-by-step guide to authenticate GCloud CLI.

```bash
gcloud auth login
```

- Login to your Google account on the new tab opened in your web browser

- List your active account and check your email address you used for GCP is present

```bash
gcloud auth list
```

- Set your current project (replace `PROJECT_ID` with the `ID` of your project)

```bash
gcloud config set project PROJECT_ID
```

- List your active account and current project and check your project is present

```bash
gcloud config list
```

### Create a service account key 🔑

#### Go to the Service Accounts page

Navigate to the GCP service accounts page at [this link](https://console.cloud.google.com/apis/credentials/serviceaccountkey).

- Select your project in the list of recent projects if asked to.
- If not asked, make sure the right project is selected in the Project selecter list at the top of the page.

#### Create a service account

- Click on **CREATE SERVICE ACCOUNT**.
- Give your service account a name, an id and a description, and click on **CREATE AND CONTINUE**.
- Click on **Select a role** and choose `Basic` then **`Owner`**, which gives the service account full access to all resources of your GCP project.
- Click on the blue **DONE** button at the bottom of this window. We don't need to worry about the section *Grant your users access to this service account*.

#### Create a json key 🔑 for this service account

- On the service accounts page, click on the email address of the newly created service account.
- Click on the **KEYS** tab at the top of the page.
- Click on **ADD KEY** then **Create new key**.
- Select **JSON** and click on **CREATE**.
- The browser has now saved the service account json file 🔑 in your downloads directory (it is named according to your service account name, something like `le-wagon-data-123456789abc.json`).

- Store the service account json file somewhere you'll remember, for example:

``` bash
/home/LINUX_USERNAME/code/GITHUB_NICKNAME/gcp/SERVICE_ACCOUNT_JSON_FILE_CONTAINING_YOUR_SECRET_KEY.json
```

- Store the **absolute path** to the `JSON` file as an environment variable:

``` bash
echo 'export GOOGLE_APPLICATION_CREDENTIALS=/path/to/the/SERVICE_ACCOUNT_JSON_FILE_CONTAINING_YOUR_SECRET_KEY.json' >> ~/.zshrc
```
You can double check it by running:

```bash
code ~/.zshrc
```

Or restarting your terminal and running:

``` bash
echo $GOOGLE_APPLICATION_CREDENTIALS
```

The ouptut should be the following:

```bash
/some/absolute/path/to/your/gcp/SERVICE_ACCOUNT_JSON_FILE_CONTAINING_YOUR_SECRET_KEY.json
```

Now let's verify that the path to your service account json file is correct:

``` bash
cat $(echo $GOOGLE_APPLICATION_CREDENTIALS)
```

This command should display the content of your service account json file.

Now configure the service account role

- List the service accounts associated to your active account and current project

```bash
gcloud iam service-accounts list
```

- Retrieve the service account email address, e.g. `SERVICE_ACCOUNT_NAME@PROJECT_ID.iam.gserviceaccount.com`

- List the roles of the service account from the cli (replace PROJECT_ID and SERVICE_ACCOUNT_EMAIL)

```bash
gcloud projects get-iam-policy PROJECT_ID \
--flatten="bindings[].members" \
--format='table(bindings.role)' \
--filter="bindings.members:SERVICE_ACCOUNT_EMAIL"
```

- You should see that your service account has a role of `roles/owner`. If so, you're good to go! 🏁
