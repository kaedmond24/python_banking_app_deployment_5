<p align="center">
<img src="">
</p>
<h1 align="center">Retail Banking App Deployment 5<h1>

# Purpose

This deployment was designed and implemented to demonstrate the use of infrastructure automation to streamline the deployment of a CI/CD pipeline facilitating the deployment of a banking application.

AWS cloud infrastructure is deployed using Terraform, setting up a Jenkins CI/CD server and a Web application server running Gunicorn and Python code.

## Deployment Files:

The following files are needed to run this deployment:

- `app.py` The main python application file
- `database.py` Python file to create application database
- `load_data.py` Python file to load data into into the database
- `test_app.py` Test functions used to test application functionality
- `requirements.txt` Required packages for python application
- `main.tf` Terraform file to deploy AWS infrastructure
- `jenkins_deploy.sh` Bash script to install and run Jenkins
- `pkill.sh` Bash script to terminate Gunicorn process
- `setup.sh` Bash script to setup and run Gunicorn and the Python application
- `setup2.sh` Bash script to setup and run Gunicorn and the Python application
- `Jenkinsfilev1` Configuration file version 1 used by Jenkins to run a pipeline
- `Jenkinsfilev2` Configuration file version 2 used by Jenkins to run a pipeline
- `README.md` README documentation
- `static/` Folder housing CSS files
- `templates/` Folder housing HTML templates
- `images/` Folder housing deployment artifacts

# Steps

1. Development of the infrastructure using Terraform. The main.tf file houses the code to deploy the AWS infrastructure. The infrastructure includes a VPC, route table, two subnets (public) in two availability zones, two route table/subnet associations, security group, and two EC2 instances (jenkins & application servers). Run this command the deploy the infrastructure:<br>

   > `Terraform init`

   > `Terraform plan`

   > `Terraform apply`<br><br>

2. The Jenkins server needs to be set up with some additional configuration. First, verify that the Jenkins application is accessible at the public IP address outputted after applying the terraform configuration.

   > `http://<jenkins-server-public-ip>`

   Retrieve initial Jenkins password

   > `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

   Now, connect to the Jenkins server and run the following commands:

   > `sudo add-apt-repository -y ppa:deadsnakes/ppa`

   > `sudo apt install -y software-properties-common python3.7 python3.7-venv`

   > `DD_API_KEY=*******************************************`

   > `DD_SITE="us5.datadoghq.com" > DD_APM_INSTRUMENTATION_ENABLED=host`

   > `bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script_agent7.sh)"`

   We need to set up an ssh connection to the application server to allow Jenkins Deploy phase of the pipeline to deploy the application code. The ssh connection needs to be configured under the jenkins user account. Start by configuring the jenkins account login:

   > `sudo passwd jenkins`

   > `sudo su - jenkins -s /bin/bash`

   Next, setup the ssh connection using the ssh-keygen utility:

   > `ssh-keygen` > `cat .ssh/id_rsa.pub`

   Copy the contents of the public key to the .ssh/authorized_keys file on the application server. Test ssh connection to verify configuration. Upon successful testing, exit the jenkins user account using the `exit` command.<br><br>

3. The application server needs to be configured with additional packages. Login into the application server and run the following commands:

   > `sudo add-apt-repository -y ppa:deadsnakes/ppa`

   > `sudo apt install -y software-properties-common python3.7 python3.7-venv`

   > `DD_API_KEY=*******************************************`

   > `DD_SITE="us5.datadoghq.com" > DD_APM_INSTRUMENTATION_ENABLED=host`

   > `bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script_agent7.sh)"`<br><br>

4. Setup Jenkins CI/CD pipeline in the Jenkins application.

   - Login: username | password
   - From Dashboard, select a `new item` > `Create Name` > `Mulit-branch Pipeline` option
   - Set Branch sources:
     Credentials: [How to setup Github Access Token](https://docs.github.com/en/enterprise-server@3.8/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
     Repository HTTPS URL: `<Github Repo URL>`
     Build Configuration > Mode > Script Path: Jenkinsfilev1
   - Apply and Save<br><br>

5. In Github, configure the Jenkinsfilev1 to have the Jenkins server connect to the application server. The deploy stage is configured with the following commands using git locally:

   > `git branch jenkins_v1_config`

   > `git checkout jenkins_v1_config`

   > `Add to Jenkinsfile: ssh ubuntu@10.0.2.217 "curl -O https://raw.githubusercontent.com/kaedmond24/python_banking_app_deployment_5/main/setup.sh && chmod 744 setup.sh && ./setup.sh"`

   > `git add Jenkinsfilev1`

   > `git commit -m “commit message”`

   > `git checkout main`

   > `git merge jenkins_v1_config`

   > `git push -u origin main`<br><br>

6. In Jenkins, run pipeline build to deploy the application. If pipeline run completes successfully, the python application will be available at `http://<application_server_public_ip>:8000`.<br><br>

7. In Github, configure the Jenkinsfilev2 to run the Jenkins pipeline with some additional commands. Configure the file with the following commands using git locally:

   > `git branch jenkins_v2_config`

   > `git checkout jenkins_v2_config`

   > `Add to Jenkinsfile: ssh ubuntu@10.0.2.217 "curl -O https://raw.githubusercontent.com/kaedmond24/python_banking_app_deployment_5/main/pkill.sh && chmod 744 pkill.sh && ./pkill.sh"`

   > `Add to Jenkinsfile: ssh ubuntu@10.0.2.217 "curl -O https://raw.githubusercontent.com/kaedmond24/python_banking_app_deployment_5/main/setup2.sh && chmod 744 setup2.sh && ./setup2.sh"`

   > `git add Jenkinsfilev2`

   > `git commit -m “commit message”`

   > `git checkout main`

   > `git merge jenkins_v2_config`<br><br>

8. In Jenkins, rerun the pipeline build to redeploy the application. If pipeline run completes successfully, the python application will be available at `http://<application_server_public_ip>:8000`.<br><br>

# System Diagram

CI/CD Pipeline Architecture [Link](https://github.com/kaedmond24/python_banking_app_deployment_5/blob/main/c4_deployment_5.png)

# Issues

During my first iterations of running the deployment I noticed that the jenkins_deploy.sh script file, configured in the Terraform main.tf file under aws_instance user data resource, was not being applied to the jenkins server launch configuration. After reading through the AWS documentation, I discovered that the commands executed in the user data field are run as the root user. As a result, the use of `sudo` is unnecessary in the script which I was using in the jenkins_deploy.sh file. Once removed, the commands within the script were able to be properly applied.

# Optimization

1. How did you decide to run Jenkinsfilev2?

   - In order to run Jenkinsfilev2 I reconfigured the pipeline build configuration’s script path to use the specified filename. A pipeline build was run once the change was made to apply the new instructions. <br>

2. Should you place both instances in the public subnet? Or should you place them in a private subnet? Explain why?

   - Ideally, the web application should be in the public subnet since it is running an internet facing service. If the web service and application were decoupled and running on different servers, then the application server could be moved to the private subnet. The Jenkins server could be placed in the private subnet. With Jenkins being the host that controls configuration and deployment placement in the private subnet would add an additional layer of security. This would also prompt for specific configuration to be put in place for access to the Jenkins server.<br>
