<p align="center">
<img src="">
</p>
<h1 align="center">Retail Banking App Deployment 4<h1>

# Purpose

This deployment is set up to build out a web server instance to deploy a web application via a CI/CD pipeline. Monitoring and stress testing will be performed on the infrastructure to observe performance.

The server will run using nginx as the webserver, Jenkins for the CI/CD pipeline, and Datadog for performance monitoring.

## Deployment Files:

The following files are needed to run this deployment:

- `application.py` The main python application file
- `test_app.py` Tests used to test application functionality; used in Jenkins Test phase
- `requirements.txt` Required packages for python application
- `urls.json` Test URLS for application testing
- `Jenkinsfile` Configuration file used by Jenkins to run a pipeline
- `README.md` README documentation
- `static/` Folder housing CSS files
- `templates/` Folder housing HTML templates
- `images/` Folder housing deployment artifacts

# Steps

1.  TBD

# System Diagram

CI/CD Pipeline Architecture [Link](https://github.com/kaedmond24/python_url_shortener_deployment_4/blob/main/c4_deployment_4.png)

# Issues

No Issues Found

# Optimization

- TBD
