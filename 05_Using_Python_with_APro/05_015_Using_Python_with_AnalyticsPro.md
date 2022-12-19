![Global Enablement & Learning](https://gelgitlab.race.sas.com/GEL/utilities/writing-content-in-markdown/-/raw/master/img/gel_banner_logo_tech-partners.jpg)

# Using Python with SAS Analytics Pro

- [Using Python with SAS Analytics Pro](#using-python-with-sas-analytics-pro)
  - [Introduction](#introduction)
  - [Submit work to SAS Analytics Pro from Python](#submit-work-to-sas-analytics-pro-from-python)
    - [What is SASPy?](#what-is-saspy)
  - [Start an instance of Analytics Pro](#start-an-instance-of-analytics-pro)
  - [Using the Linux Server for the Python environment](#using-the-linux-server-for-the-python-environment)
    - [Install SASPy and dependent packages](#install-saspy-and-dependent-packages)
    - [Create SASPy Configuration and SSH Keys](#create-saspy-configuration-and-ssh-keys)
      - [Create the SSH keys](#create-the-ssh-keys)
      - [Create the 'sascfg_personal.py' configuration](#create-the-sascfg_personalpy-configuration)
    - [Create and Run some Python code](#create-and-run-some-python-code)
  - [Using a Windows client for the Python environment](#using-a-windows-client-for-the-python-environment)
    - [Using PowerShell ISE](#using-powershell-ise)
    - [Install OpenSSH on the Windows client](#install-openssh-on-the-windows-client)
    - [Create a new SSH key](#create-a-new-ssh-key)
    - [Install SASPy and dependent packages](#install-saspy-and-dependent-packages-1)
    - [Create the 'sascfg_personal.py' configuration on the Windows client](#create-the-sascfg_personalpy-configuration-on-the-windows-client)
    - [Create and Run some Python code](#create-and-run-some-python-code-1)
  - [Using Jupyter Notebook](#using-jupyter-notebook)
  - [References](#references)
  - [Hands-on Navigation Index](#hands-on-navigation-index)

## Introduction

In this exercise we will look at working with Python and connecting to SAS Analytics Pro, submitting work to SAS. 

In this exercise you will use two programming environments:
1. You will first use a Python programming environment on the Linux Server to submit code to SAS Analytics Pro.
2. Then you will use the Windows Client to run the Python code that calls SAS (SAS Analytics Pro).

This is illustrated in the image below.

![saspy_overview](/img/SASPy_overview_withAD.png)

When working in Windows, you will use the Windows command-line to run the Python code and then Jupyter Notebook as the programming environment.

It is important to understand that the workshop environment is not representative of a typical customer configuration. In that, the Windows Client, Linux Server and Analytics Pro are not all integrated into the same authentication domain.

For access to Windows you will use the local user 'Student', on the Linux server you will use a local user called 'cloud-user' and the Analytics Pro container is integrated with the GEL RACE AD.

Typically, to access Analytics Pro you would use the same user that you used to sign-in to the Windows or Linux environment.

Note, this exercise builds on the previous configuration, you **must** have completed the following exercises:

* [03 015 Configure Authentication and TLS Security](/03_Productionize_the_deployment/03_015_Configure_authentication_and_TLS_security.md)
* [03 025 Advanced AnalyticsPro configuration](/03_Productionize_the_deployment/03_025_Advanced_AnalyticsPro_configuration.md)

## Submit work to SAS Analytics Pro from Python

SAS Viya provides several mechanisms for integrating the Python language with SAS Viya’s data and analytics capabilities.

One such tool is **SASPy**, a module that creates a bridge between Python and SAS, allowing Python developers, who may not necessarily be familiar with SAS code, to leverage the power of SAS directly from a Python client.

In this exercise, we will look at the setup required to configure SASPy to access SAS Analytics Pro from the Linux server.

### What is SASPy?

The open-source SASPy Python module converts Python code to SAS code and runs the code in SAS. It provides Python APIs to SAS so that you can start a SAS session and run analytics from Python. You can move data between SAS data sets and Pandas dataframes and exchange values between python variables and SAS macro variables.

You can use the module in both interactive line mode and batch Python, as well as in Jupyter Notebooks. The results include ODS output, and can be returned as Panda data frames. Not all Python methods are supported, but you can customize the module to add or modify methods.

See the [SASPy documentation](https://sassoftware.github.io/saspy/index.html), also see the [SASPy GitHub Project](https://github.com/sassoftware/saspy).

## Start an instance of Analytics Pro

To support the SASPy connections, SSH or 'Passwordless SSH' is required for the connection to the Analytics Pro container. To enable the SSH configuration you need to make the SSH port available, for this we will use port '**8022**', and the 'sshd' configuration must be enabled.

In addition to enabling the SSH connectivity, two Linux capabilities are required. This is done by using the '**--cap-add**' parameter on the docker run command (see below).

1. Start a session with 'sasnode01' using MobaXterm.

1. Create the 'sshd.conf' file.

    Create an sshd.conf file with no content and add it to the sasinside/sasosconfig directory

    ```bash
    cd ~/project
    bash -c "cat << 'EOF' > ~/project/sasinside/sasosconfig/sshd.conf

    EOF"
    ```

1. Start Analytics Pro.

    ***Note, this exercise uses the configuration that was created in the previous lab exercises***.

    * Remove any running instance of Analytics Pro.

        ```bash
        # Get the container ID
        CONTAINER_ID=$(docker container ls | grep sas-analytics-pro | awk '{ print $1 }')
        # Kill the running container
        docker container kill $CONTAINER_ID
        ```

    * Start a new instance of Analytics Pro.

        As discussed above, we need to add two Linux capabilities: 'AUDIT_WRITE' and 'SYS_ADMIN'. This is done by adding the following paramters to the 'docker run' command:
        `--cap-add AUDIT_WRITE` and `--cap-add SYS_ADMIN`.

        ```bash
        cd ~/project/
        # Get the Analytics Pro image name
        APRO_IMAGE=$(docker image ls | grep -m 1 sas-analytics-pro | awk '{ print $1 ":" $2 }')

        docker run -u root \
          --name=sas-analytics-pro \
          --rm \
          --detach \
          --hostname sas-analytics-pro \
          --env SASLICENSEFILE=SASViyaV4_APro_license.jwt \
          --env SSL_CERT_NAME=casigned.crt \
          --env SSL_KEY_NAME=servertls.key \
          --cap-add AUDIT_WRITE \
          --cap-add SYS_ADMIN \
          --publish 8443:443 \
          --publish 8022:22 \
          --volume ${PWD}/sasinside:/sasinside \
          --volume /userHome:/home \
          --volume /userData:/data \
          --volume /sastmp:/sastmp \
        $APRO_IMAGE
        ```

## Using the Linux Server for the Python environment

In this exercise you will first use the Linux server as the Python programming environment. For the following steps you are signed-in to the Linux server as the 'cloud-user' user, but will access Analytics Pro using the GEL RACE AD user 'gelviyaadmin'.

### Install SASPy and dependent packages

First we will confirm that your server has Python installed. Your Docker server should have python3 installed.

* Confirm the python3 version.

    ```sh
    python3 --version
    ```

The following Python packages must be installed on the host where SASpy is running.

1. Install the dependent packages.

    ```bash
    sudo pip3 install wheel
    sudo pip3 install pandas
    ```

1. Install the SASPy package.

    ```bash
    cd ~/project
    sudo pip3 install saspy
    ```

### Create SASPy Configuration and SSH Keys

The '**sascfg_personal.py**' file contains the configuration and connection information. To connect to Analytics Pro you need to use a '**STDIO over SSH**' connection.

For the SSH connection we also need to create the SSH keys that you will use for the connection to Analytics Pro.

#### Create the SSH keys

As previously stated to connect to Analytics Pro running on Linux we need to use a '**STDIO over SSH**' connection. To configure passwordless SSH you first need to generate the SSH keys, then copy the key to the Analytics Pro container.

1. Create the SSH keys (Private and Public keys).

    ```bash
    cd ~/.ssh
    ssh-keygen -f apro_rsa -N ''
    ```

1. Confirm the creation of the public and private keys.

    ```bash
    cd ~/.ssh
    ls -al
    ```

    You should see the following output.

    ```log
    drwx------.  2 cloud-user docker  127 Oct 31 18:55 .
    drwx------. 15 cloud-user docker 4096 Oct 31 16:58 ..
    -rw-------   1 cloud-user docker 1675 Oct 31 18:55 apro_rsa
    -rw-r--r--   1 cloud-user docker  404 Oct 31 18:55 apro_rsa.pub
    -rw-------.  1 cloud-user docker  779 May 14  2019 authorized_keys
    -rw-r--r--   1 cloud-user docker  381 Oct 30 21:58 cloud-user_id_rsa.pub
    -rw-------.  1 cloud-user docker 1679 Sep 11  2018 id_rsa
    -rw-r--r--   1 cloud-user docker 2869 Oct 30 21:55 known_hosts
    ```

1. Copy the 'apro_rsa' key to the Analytics Pro container.

    We will do this for the '**gelviyaadmin**' user. 
    
    As Analytics Pro is running on the Linux server we could use 'localhost' on the connection strings. But a better approach would be to use the hostname or alias for the Linux server. In this exercise we will use the host alias: '**sasnode01**'.
    
    _Note, if you used the container IP address, you would have to use port 22 in the following commands and configuration. Using the Linux server host name, or localhost, you need to use port '8022'._

    ```sh
    cd ~/.ssh
    # To use the container IP address
    #apro_server=$(hostname -f)
    #apro_container_ip=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" sas-analytics-pro)
    # Copy the key
    #ssh-copy-id -i apro_rsa gelviyaadmin@${apro_container_ip} -p 22

    ssh-copy-id -i apro_rsa gelviyaadmin@sasnode01 -p 8022
    ```

1. At the prompt: '**Are you sure you want to continue connecting (yes/no)?**', answer '**yes**'.

1. When prompted, enter the password for the 'gelviyaadmin' user.

    Password: **P@ssw0rd** (with a zero)

1. Test the SSH connection.

    To test the connection let's get the Analytics Pro container hostname and some details for the 'gelviyaadmin' user.

    ```sh
    ssh -i ~/.ssh/apro_rsa -p 8022 gelviyaadmin@sasnode01 'echo -e "\nAPro hostname: "$(hostname);echo "Current user:  "$(whoami);echo "Current path:  "$(pwd);ls -al'
    ```

    You should see the following output.

    ```log
    APro hostname: sas-analytics-pro
    Current user:  gelviyaadmin
    Current path:  /home/gelviyaadmin
    total 12
    drwx------ 4 gelviyaadmin sas   90 Nov  7 23:50 .
    drwxrwxr-x 6 root         root  83 Nov  7 23:48 ..
    -rw-r--r-- 1 gelviyaadmin sas   18 Aug  8  2019 .bash_logout
    -rw-r--r-- 1 gelviyaadmin sas  193 Aug  8  2019 .bash_profile
    -rw-r--r-- 1 gelviyaadmin sas  231 Aug  8  2019 .bashrc
    drwxr-xr-x 4 gelviyaadmin sas   39 Oct 22  2018 .mozilla
    drwx------ 2 gelviyaadmin sas   29 Nov  7 23:50 .ssh
    ```

#### Create the 'sascfg_personal.py' configuration

To use SASPy we first need to generate the connection configuration file.

1. Create the '**sascfg_personal.py**' configuration file.

    The 'sascfg_personal.py' configuration is needed for SASPy to connect to your Analytics Pro environment. This is specific to the user and SSH key that you setup in the previous steps.

    Within the profile, when you specifiy the user and host information you can either provide the user information on the 'host' parameter, such as: *username@hostname*. Or you can use the 'luser' parameter to specify the login username. For this step you will just use the 'host' parameter.

    ```bash
    mkdir -p ~/project/saspy/
    cd ~/project/saspy/
    #apro_server=$(hostname -f)
    #apro_container_ip=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" sas-analytics-pro)

    bash -c "cat << 'EOF' > ~/project/saspy/sascfg_personal.py
    SAS_config_names   = ['ssh']

    SAS_config_options = {'lock_down': False,
                          'verbose'  : True,
                          'prompt'   : True
                         }

    #SAS_output_options = {'output' : 'html5'}       # not required unless changing any of the default

    ssh                = {'saspath'  : '/opt/sas/viya/home/SASFoundation/sas',
                          'ssh'      : '/usr/bin/ssh',
                          'host'     : 'gelviyaadmin@sasnode01',
                          'identity' : '/home/cloud-user/.ssh/apro_rsa',
                          'port'     : '8022',
                          'options'  : [\"-fullstimer\"]
                         }

    EOF"
    ```

### Create and Run some Python code

1. Run the following to create a test program. This will query the SASHELP 'class' table.

    ```bash
    # Create the python script
    tee  ~/project/saspy/query_class_data.py > /dev/null <<EOF
    #!/usr/bin/env python3
    # coding: utf-8

    # Created for the GEL workshop PSGEL317

    import saspy
    import pandas as pd

    sas = saspy.SASsession(cfgname='ssh', results='text')

    mydata = sas.sasdata("CLASS","SASHELP")
    mydata.head()
    mydata.describe()

    # Close the session
    sas.endsas()

    EOF
    ```

1. Run the code.

    ```sh
    cd ~/project/saspy/
    python3 query_class_data.py
    ```

    You should see output similar to the following.

    ![query_class_data](/img/query_class_data.png)

1. OPTIONAL: Try the following.

    This time using the SASHELP cars table.

    ```bash
    tee  ~/project/saspy/query_cars_data.py > /dev/null <<EOF
    #!/usr/bin/env python3
    # coding: utf-8

    # Created for the GEL workshop PSGEL317

    import saspy
    import pandas as pd

    sas = saspy.SASsession(cfgname='ssh', results='text')

    mydata = sas.sasdata("CARS","SASHELP")
    mydata.head()
    mydata.describe()

    # Close the session
    sas.endsas()

    EOF
    ```

1. Run the 'query_cars_data.py' code.

    ```sh
    cd ~/project/saspy/
    python3 query_cars_data.py
    ```

That completes the testing from a Linux environment.

<!-- As an alternative
* As an alternative query of the cars table

    ```sh
    # Create the config file
    tee  ~/project/saspy/demo2_code.py > /dev/null <<EOF
    #!/usr/bin/env python3
    # coding: utf-8

    # Created for the GEL workshop PSGEL317

    import saspy
    import pandas as pd

    sas = saspy.SASsession(cfgname='ssh', results='text')
    sas.submitLST('data a;x=1;run; proc print data=a;run;')
    cars = sas.sasdata('cars', libref='sashelp')
    sas.submitLST('proc print data=sashelp.cars;run;')

    EOF
    ```
-->

## Using a Windows client for the Python environment

In this part of the exercise you will now use Windows as the Python programming environment.

The configuration and set-up for the Windows client is similar to using Linux, you will have to create new SSH keys (or you could download and use the keys that you previously created) and create the SASPy connection configuration file.

For the following steps you are signed-in to the Windows client as the 'Student' user, but will access Analytics Pro using the GEL RACE AD user 'gatedemo001'.

### Using PowerShell ISE

In this part of the exercise you will use PowerShell ISE as the primary tool to create the configuration and run commands. 

Windows PowerShell Integrated Scripting Environment (ISE) is a graphical host application that enables you to read, write, run, debug, and test scripts and modules in a graphic-assisted environment.

To launch PowerShell ISE, at the Windows **Start** menu type: `PowerShell_Ise.exe`

![powershell_ise](/img/powershell_ise_withnotes.png)

Note, when working in the 'Script Pane' there are two controls to run code, '**Run Script (F5)**' and '**Run Selection (F8)**'. If you use 'Run Script' it will run **ALL** the code in the script pane.

### Install OpenSSH on the Windows client

As Windows doesn't natively have the OpenSSH environment, we first need to set this up.

1. Start the 'PowerShell ISE' application.

    Start Menu --> PowerShell ISE or '`PowerShell_Ise.exe`'

1. Download and install the OpenSSH client.

    Copy and paste the following code block into the PowerShell ISE **script pane** and run the commands.

    ```cmd
    cd c:\users\student
    # Fetch OpenSSH
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri `
    https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.9.1.0p1-Beta/OpenSSH-Win64-v8.9.1.0.msi `
    -OutFile "C:\Users\student\downloads\OpenSSH-Win64-v8.9.1.0.msi"

    # Install OpenSSH
    Start-Process "C:\Users\student\downloads\OpenSSH-Win64-v8.9.1.0.msi" -ArgumentList "/passive"

    # Add SSH to path
    $ENV:PATH="$ENV:PATH;C:\Program Files\OpenSSH"
    ```

### Create a new SSH key

1. Generate the SSH key.

    Copy and paste the following code block into the PowerShell ISE script pane and run the commands.

    ```cmd
    # Create User SSH Key Pair
    cd C:\Users\student\.ssh
    if (Test-Path -Path "C:\Users\student\.ssh\gatedemo001_key*") {
    Remove-Item "C:\Users\student\.ssh\gatedemo001_key*"
    }
    ssh-keygen -f gatedemo001_key -N '""'
    ```

1. Copy the Key to the Analytics Pro container.

    While you have now installed OpenSSH on the Windows machine, it does not include the 'ssh-copy-id' command. Therefore, you will have to manually perform the steps to copy the key. To assist with this we will use the 'ASKPASS' utility for SSH.

    Copy and paste the following code block into the PowerShell ISE script pane and run the commands.

    ```cmd
    # Fetch askpass util for SSH
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri `
    "http://github.com/PowerShell/openssh-portable/raw/latestw_all/regress/pesterTests/utilities/askpass_util/askpass_util.exe" `
    -OutFile "C:\Program Files\OpenSSH\askpass_util.exe"

    # Create the users .ssh directory
    $env:ASKPASS_PASSWORD = 'P@ssw0rd'
    $env:SSH_ASKPASS_REQUIRE = "force"
    $env:SSH_ASKPASS = "C:\Program Files\OpenSSH\askpass_util.exe"
    ssh -o StrictHostKeyChecking=accept-new -p 8022 sasnode01 -l gatedemo001 "mkdir .ssh"

    # Use askpass to copy SSH Public Key to remote host
    $env:ASKPASS_PASSWORD = 'P@ssw0rd'
    $env:SSH_ASKPASS_REQUIRE = "force"
    $env:SSH_ASKPASS = "C:\Program Files\OpenSSH\askpass_util.exe"
    type $env:USERPROFILE\.ssh\gatedemo001_key.pub | ssh -p 8022 sasnode01 -l gatedemo001 "cat > .ssh/authorized_keys"

    # Validated that SSH Key authentication works
    $env:ASKPASS_PASSWORD = ''
    $env:SSH_ASKPASS_REQUIRE = ''
    $env:SSH_ASKPASS = ''
    ssh -p 8022  sasnode01 -l gatedemo001 -i $env:USERPROFILE\.ssh\gatedemo001_key "hostname;echo AUTHORIZED KEYS...;cat .ssh/authorized_keys"
    ```

    You should see output similar to the following.

    ![windows_create_keys](/img/windows_create_keys.png)

    *Note, it is normal to see the warning (red text), this is due to the `-o StrictHostKeyChecking=accept-new` parameter being used.*

1. Test the SSH connection to Analytics Pro.

    Copy and paste the following command into the PowerShell ISE script pane and run the command.

    ```cmd
    ssh -i c:\Users\student\.ssh\gatedemo001_key -p 8022 gatedemo001@sasnode01 'echo -e "\APro hostname: "$(hostname);echo "Current user : "$(whoami);echo "Current path : "$(pwd);ls -al'
    ```

    You should see output similar to the following.

    ```log
    PS C:\Users\student> ssh -i c:\Users\student\.ssh\gatedemo001_key -p 8022 gatedemo001@sasnode01 'echo -e "\APro hostname: "$(hostname);echo "Current user : "$(whoami);echo "Current path : "$(pwd);ls -al'

    APro hostname: sas-analytics-pro
    Current user : gatedemo001
    Current path : /home/gatedemo001
    total 12
    drwx------ 4 gatedemo001 sas   90 Nov  7 04:49 .
    drwxrwxr-x 6 root        root  83 Nov  7 04:45 ..
    -rw-r--r-- 1 gatedemo001 sas   18 Aug  8  2019 .bash_logout
    -rw-r--r-- 1 gatedemo001 sas  193 Aug  8  2019 .bash_profile
    -rw-r--r-- 1 gatedemo001 sas  231 Aug  8  2019 .bashrc
    drwxr-xr-x 4 gatedemo001 sas   39 Oct 22  2018 .mozilla
    drwxr-xr-x 2 gatedemo001 sas   29 Nov  7 04:49 .ssh
    ```

    From the command output you can see that the hostname for the Analytics Pro container is '`sas-analytics-pro`'.

That completes the SSH set-up.

### Install SASPy and dependent packages

Python is already installed on the Windows client machine, but the SASPy package and dependencies need to be installed.

1. Again using PowerShell ISE.

1. Run the following command to confirm the version of Python installed.

    ```sh
    python --version
    ```

1. Install SASPy and dependent packages.

    Copy and paste the following code block into the PowerShell ISE script pane and run the commands.

    ```sh
    # Check for updates
    python -m pip install --upgrade pip
    # Install dependent packages
    pip install wheel
    pip install pandas
    # Install saspy
    pip install saspy
    ```

    *Note, this can take 1 to 2 minutes to complete.*

### Create the 'sascfg_personal.py' configuration on the Windows client

The saspy configuration file and python scripts all need to be UTF-8 encoded. To configure this we can use the '**-encoding utf8**' parameter on the 'write-output' command.

1. Create the 'saspy' directory.

    Copy and paste the following code block into the PowerShell ISE script pane and run the commands.

    ```sh
    cd C:\Users\student
    mkdir saspy
    ```

1. Create the 'sascfg_personal.py' configuration file.

    This time when you create the configuration file we will use the '**luser**' parameter in the profile, which means we just need the hostname of 'sasnode01'.

    Copy and paste the following code block into the PowerShell ISE script pane and run the commands.

    ```cmd
    cd C:\Users\student\saspy
    write-output "SAS_config_names   = ['ssh']
    
    SAS_config_options = {'lock_down': False,
                          'verbose'  : True,
                          'prompt'   : True
                         }
    
    #SAS_output_options = {'output' : 'html5'}       # not required unless changing any of the default
    
    ssh                = {'saspath'  : '/opt/sas/viya/home/SASFoundation/sas',
                          'ssh'      : 'C:\Program Files\OpenSSH\ssh',
                          'identity' : 'C:\\Users\\student\\.ssh\\gatedemo001_key',
                          'host'     : 'sasnode01',
                          'luser'    : 'gatedemo001',
                          'port'     : '8022',
                          'options'  : [""-fullstimer""]
                         }" |  out-file -FilePath .\sascfg_personal.py -encoding utf8
    ```

### Create and Run some Python code

We will now create a couple of Python programs to call SAS (Analytics Pro).

1. Create a Python script to query the SASHELP Class table.

    Copy and paste the following code block into the PowerShell ISE script pane and run the commands.

    ```cmd
    cd C:\Users\student\saspy
    write-output "#!/usr/bin/env python
    # coding: utf-8

    # Created for the GEL workshop PSGEL317

    import saspy
    import pandas as pd

    sas = saspy.SASsession(cfgfile='c:\\Users\\student\\saspy\\sascfg_personal.py', cfgname='ssh', results='text')

    mydata = sas.sasdata(""CLASS"",""SASHELP"")
    mydata.head()
    mydata.describe()

    # Close the session
    sas.endsas()" |  out-file -FilePath .\query_class_data.py -encoding utf8
    ```

1. Create a Python script to query the SASHELP Cars table.

    Copy and paste the following code block into the PowerShell ISE script pane and run the commands.

    ```cmd
    cd C:\Users\student\saspy
    write-output "#!/usr/bin/env python
    # coding: utf-8

    # Created for the GEL workshop PSGEL317

    import saspy
    import pandas as pd

    sas = saspy.SASsession(cfgfile='c:\\Users\\student\\saspy\\sascfg_personal.py', cfgname='ssh', results='text')

    mydata = sas.sasdata(""CARS"",""SASHELP"")
    mydata.head()
    mydata.describe()

    # Close the session
    sas.endsas()" |  out-file -FilePath .\query_cars_data.py -encoding utf8
    ```

1. Click on the '**Start PowerShell**' button on the ISE toolbar.

    This will start a 'PowerShell' session which we will use the run the Python code that you just created.

    _Note, it is possible to run the command using PowerShell ISE, but to avoid seeing some warning messages (see the note below) we will use a PowerShell session._

1. Run the Python program to query the Class table.

    '**Ctl-v**' paste the following command into the PowerShell session.

    ```cmd
    python c:\users\student\saspy\query_class_data.py
    ```

    You shoud see output similar to the following.

    ![windows_query_class_data](/img/windows_query_class_data.png)

    *Note, in the workshop environment it is normal to see the '`*** dns1axxRec48nc0.net.sas.com can't find sasclient: Non-existent domain`' message. This is due to the Windows client, Linux server and the Analytics Pro container not all being in the same authentication domain.*

1. Run the Python program to query the Cars table.

    '**Ctl-v**' paste the following command into the PowerShell session.

    ```cmd
    python c:\users\student\saspy\query_cars_data.py
    ```

    You shoud see output similar to the following.

    ![query_cars_data](/img/query_cars_data.png)

    That completes the testing using the command-line.

## Using Jupyter Notebook

As most Data Scientists will most likely be working in an IDE like Jupyter Notebook, let’s test running the code from there. As Jupyter Notebook isn't installed on the Windows machine the first step is to install it.

For this we will use the standard Windows command-line session.

1. Start the Windows command-line.

1. Install Jupyter Notebook.

    ```cmd
    pip install notebook
    ```

1. Run (Start) Jupyter Notebook.

    ```cmd
    jupyter notebook
    ```

    This will launch the window select the application, **select Google Chrome** from the list.

    ![launch_jupyter_notebook](/img/launch_jupyter_notebook.png)

1. From the Jupyter Home Page select **New**, then 'Python 3' Notebook.

    ![new_notebook](/img/new_notebook.png)

1. Start a session with SAS Analytics Pro.

    Paste the following command into the Notebook input ('In') field, and select '**Run**'.

    ```cmd
    import pandas as pd
    import saspy
    sas = saspy.SASsession(cfgfile='c:\\Users\\student\\saspy\\sascfg_personal.py', cfgname='ssh', results='html')
    ```

    You should see that the session has been established.

    ![notebook_start_session](/img/notebook_start_session.png)

1. Query the SASHELP Class table.

    Paste the following code block into the Notebook input ('In') field, and select '**Run**'.

    ```cmd
    mydata = sas.sasdata("CLASS","SASHELP")
    mydata.head()
    mydata.describe()
    ```

    You should see the following output.

    ![notebook_query_class](/img/notebook_query_class.png)

1. Query the SASHELP Cars table.

    Paste the following code block into the Notebook input ('In') field, and select '**Run**'.

    ```cmd
    mydata = sas.sasdata("CARS","SASHELP")
    mydata.head()
    mydata.describe()
    ```

    You should see the following output.

    ![notebook_query_cars](/img/notebook_query_cars.png)

1. Now let's run a SAS PROC (PROC SETINIT).

    Paste the following code block into the Notebook input ('In') field, and select '**Run**'.

    ```cmd
    sas_code = 'proc setinit;run;'
    sas_submit = sas.submit(sas_code)
    print(sas_submit['LOG'])
    ```

    You should see the following output.

    ![run_proc_setinit](/img/run_proc_setinit.png)

1. End the SAS session.

    Paste the following code block into the Notebook input ('In') field, and select '**Run**'.

    ```cmd
    sas.endsas()
    ```

    You should see output similar to the following.

    ![notebook_end_session](/img/notebook_end_session.png)

That completes the testing using Jupyter Notebook, and the using Python lab exercise.

When you are finished with Jupyter Notebook switch back to the Windows command-line and enter '**Ctl-C**' to terminate the Jupyter process.

---

## References

* SAS Manual: [Enable Use of SASPy](https://go.documentation.sas.com/doc/en/anprocdc/v_017/dplyviya0ctr/p02tns1ea7ek9on1ibx8rneca1t0.htm)
* [SASPy documentation](https://sassoftware.github.io/saspy/index.html)
* [SASPy GitHub Project](https://github.com/sassoftware/saspy)

---

## Hands-on Navigation Index

<!-- startnav -->
* [01 Workshop Introduction / 01 011 Access Environments](/01_Workshop_Introduction/01_011_Access_Environments.md)
* [02 Deploy AnalyticsPro / 02 011 Environment setup](/02_Deploy_AnalyticsPro/02_011_Environment_setup.md)
* [02 Deploy AnalyticsPro / 02 021 Quick start deployment of AnalyticsPro](/02_Deploy_AnalyticsPro/02_021_Quick-start_deployment_of_AnalyticsPro.md)
* [03 Productionize the deployment / 03 015 Configure authentication and TLS security](/03_Productionize_the_deployment/03_015_Configure_authentication_and_TLS_security.md)
* [03 Productionize the deployment / 03 025 Advanced AnalyticsPro configuration](/03_Productionize_the_deployment/03_025_Advanced_AnalyticsPro_configuration.md)
* [03 Productionize the deployment / 03 031 Running multiple instances](/03_Productionize_the_deployment/03_031_Running_multiple_instances.md)
* [04 Using a CAS server / 04 011 Using a CAS server](/04_Using_a_CAS_server/04_011_Using_a_CAS_server.md)
* [05 Using Python with APro / 05 015 Using Python with AnalyticsPro](/05_Using_Python_with_APro/05_015_Using_Python_with_AnalyticsPro.md)**<-- you are here**
* [README](/README.md)
<!-- endnav -->
