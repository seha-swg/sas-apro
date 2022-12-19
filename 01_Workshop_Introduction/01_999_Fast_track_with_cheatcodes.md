![Global Enablement & Learning](https://gelgitlab.race.sas.com/GEL/utilities/writing-content-in-markdown/-/raw/master/img/gel_banner_logo_tech-partners.jpg)

# Fast track with the cheatcodes



## Introduction

The 'cheatcodes' have been developed for this workshop and are NOT part of the SAS Viya software, nor are they an official tool supported by SAS. They provide an automated path through the lab exercises.

## (Re)generate the cheatcodes

* Run the command below to generate the cheat codes

    ```sh
    cd ~/PSGEL317-sas-analytics-pro-deployment-and-configuration/
    git pull
    #git reset --hard origin/main
    # Optionnaly you can switch to a diffent version branch. For example,
    #git checkout "release/stable-2022.1.4"
    /opt/gellow_code/scripts/cheatcodes/create.cheatcodes.sh /home/cloud-user/PSGEL317-sas-analytics-pro-deployment-and-configuration/
    ```

    Now you can directly call the cheatcodes for each step.

## Run the cheatcodes (examples)

*Important: it is recommended to send the output into a log file, so, in case of failure, you can investigate more easily.*

### Run environment set-up and the first deployment

* Run the following commands.

    ```sh
    # Run environment set-up
    bash -x ~/PSGEL317-sas-analytics-pro-deployment-and-configuration/02*/02_011_Environment_setup.sh 2>&1 \
    | tee -a ~/02_011_Environment_setup.log

    # Deploy Analytics Pro using Quick-start
    bash -x ~/PSGEL317-sas-analytics-pro-deployment-and-configuration/02*/02_021_Quick-start_deployment_of_AnalyticsPro.sh 2>&1 \
    | tee -a ~/02_021_Quick-start_deployment_of_AnalyticsPro.log
    ```

### Run Productionization steps

* Run the following commands.

    ```sh
    # Configure authentication and TLS security
    bash -x ~/PSGEL317-sas-analytics-pro-deployment-and-configuration/03*/03_015_Configure_authentication_and_TLS_security.sh 2>&1 \
    | tee -a ~/03_015_Configure_authentication_and_TLS_security.log

    # Advanced configuration
    bash -x ~/PSGEL317-sas-analytics-pro-deployment-and-configuration/03*/03_025_Advanced_AnalyticsPro_configuration.sh 2>&1 \
    | tee -a ~/03_025_Advanced_AnalyticsPro_configuration.log

    # Running multiple instances
    bash -x ~/PSGEL317-sas-analytics-pro-deployment-and-configuration/03*/03_031_Running_multiple_instances.sh 2>&1 \
    | tee -a ~/03_031_Running_multiple_instances.log
    ```

### Run the Using a CAS Server steps

* Run the following commands.

    ```sh
    # Using a CAS Server with SAS Analytics Pro
    bash -x ~/PSGEL317-sas-analytics-pro-deployment-and-configuration/04*/04_011_Using_a_CAS_server.sh 2>&1 \
    | tee -a ~/04_011_Using_a_CAS_server.log
    ```
