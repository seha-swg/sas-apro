![Global Enablement & Learning](https://gelgitlab.race.sas.com/GEL/utilities/writing-content-in-markdown/-/raw/master/img/gel_banner_logo_tech-partners.jpg)

# Access Environments

- [Access Environments](#access-environments)
  - [Register yourself to be part of the STICExnetUsers group](#register-yourself-to-be-part-of-the-sticexnetusers-group)
  - [Book a RACE Collection](#book-a-race-collection)
  - [Connect to your Collection](#connect-to-your-collection)
  - [Next steps](#next-steps)
  - [Hands-on Navigation Index](#hands-on-navigation-index)

## Register yourself to be part of the STICExnetUsers group

* If you are not yet a member of the **STICExnetUsers** group, you need to join it.
  * [Click here](mailto:dlistadmin@wnt.sas.com?subject=Subscribe%20STICEXNETUsers) to prepare an email request to join **STICExnetUsers** group
  * This should open up a new e-mail
    * to the address: `dlistadmin@wnt.sas.com`
    * with the subject: `Subscribe STICEXNETUsers`
  * Send the email as-is, without any changes
* Once the email is sent, you will be notified via email of the creation of the account.
* Your account membership should be updated and ready for use within 1 hour
* Sometimes, it takes much longer than 1 hour for this group membership to propagate through the network.
* To expedite the group membership, simply log out of the SAS network and log back in).
* Until the group membership change occurs, you won't be able reserve the environment.

## Book a RACE Collection

* We will use a RACE machine as your Docker server. *Note, this collection is used across a number of workshops so comes pre-loaded is a variety of software, including Docker*.

* [Book the "Docker Server"](http://race.exnet.sas.com/Reservations?action=new&imageId=483719&imageKind=C&comment=PSGEL317%20APro%20Deploy%20GE%20VMWare&purpose=PST&sso=PSGEL317&schedtype=SchedTrainEDU&startDate=now&endDateLength=0&discardonterminate=y) collection, which comes with one Windows client and one Linux machine.

   **Use the steps below to book an Azure based collection - ONLY IF YOU ARE UNABLE TO BOOK THE VMWARE COLLECTION ABOVE**

    * This collection uses Azure based machines which are part of the wider RACE network.
    * It should only be used when the VMWare based RACE machines are not available.
    * You should only book the collection for 4 hours at a time, as there is a cost to SAS when these machines are used.
    * Book the [Azure Collection](http://race.exnet.sas.com/Reservations?action=new&imageId=483720&imageKind=C&comment=PSGEL317%20APro%20Deploy%20GE%20Azure&purpose=PST&sso=PSGEL317&schedtype=SchedTrainEDU&startDate=now&endDateLength=0&discardonterminate=y) which comes with one Windows client and one Linux machine.

* Once the collection has been started, you should receive an email like the one below.

    ![CollectionBooking](/img/CollectionBooking.png)

## Connect to your Collection

* Connect to the Windows Machine of your RACE collection (as username: `Student`, the password is: `Metadata0`).
* In the Hands-on instructions, **we will run the commands run from the sasnode1 session from within MobaXterm** on the RACE client machine.

---

## Next steps

Now you can proceed to environment set-up.

  * [Environment set-up](./../02_Deploy_AnalyticsPro/02_011_Environment_setup.md)

## Hands-on Navigation Index

<!-- startnav -->
* [01 Workshop Introduction / 01 011 Access Environments](/01_Workshop_Introduction/01_011_Access_Environments.md)**<-- you are here**
* [02 Deploy AnalyticsPro / 02 011 Environment setup](/02_Deploy_AnalyticsPro/02_011_Environment_setup.md)
* [02 Deploy AnalyticsPro / 02 021 Quick start deployment of AnalyticsPro](/02_Deploy_AnalyticsPro/02_021_Quick-start_deployment_of_AnalyticsPro.md)
* [03 Productionize the deployment / 03 015 Configure authentication and TLS security](/03_Productionize_the_deployment/03_015_Configure_authentication_and_TLS_security.md)
* [03 Productionize the deployment / 03 025 Advanced AnalyticsPro configuration](/03_Productionize_the_deployment/03_025_Advanced_AnalyticsPro_configuration.md)
* [03 Productionize the deployment / 03 031 Running multiple instances](/03_Productionize_the_deployment/03_031_Running_multiple_instances.md)
* [04 Using a CAS server / 04 011 Using a CAS server](/04_Using_a_CAS_server/04_011_Using_a_CAS_server.md)
* [05 Using Python with APro / 05 015 Using Python with AnalyticsPro](/05_Using_Python_with_APro/05_015_Using_Python_with_AnalyticsPro.md)
* [README](/README.md)
<!-- endnav -->
