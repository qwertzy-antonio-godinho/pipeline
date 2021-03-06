# pipeline
Sets up a local pipeline using Docker, DinD, sysbox, Jenkins, Gitea, python, DevPi, pyenv, pipenv, tox, pdoc3, fint. 

The pipeline creates a new Docker container which serves as an environment where tests are executed in parallel using Docker In Docker, generates source documentation with pdoc3, and creates source and wheel packages which are saved in a local hosted DevPi instance. 

The last stage downloads the built package from DevPi and tests the package installation in a newly built clean environment. 

Gitea is used as a git web front-end. Each time code changes are pushed, a new build is triggered in Jenkins using webhooks.

- Tested using Ubuntu 20.04 Operating System. 

- Intended for a local installation. If using in a Cloud environment or Internet facing server you should setup certificates, configure domain names and deal with any extra necessary configurations required for network, e-mail and application settings.

- The pipeline it setup to test Python applications, obviously it can be expanded to support other languages, but it's outside the scope for this example.

## Screenshots

Successful run:

![Image](./screenshots/jenkins_blue_ocean_pass_tests.png?raw=true)

Failed test:

![Image](./screenshots/jenkins_blue_ocean_pipeline.png?raw=true)

Artifacts collected:

![Image](./screenshots/jenkins_blue_ocean_artifacts.png?raw=true)

Artifacts and documentation:

![Image](./screenshots/jenkins_build_outputs.png?raw=true)

Test result trend using Junit and test report:

![Image](./screenshots/jenkins_test_trend.png?raw=true)

DevPi with built packages:

![Image](./screenshots/devpi_artifacts.png?raw=true)

Gitea example repository:

![Image](./screenshots/gitea_repo.png?raw=true)

Documentation generated from code:

![Image](./screenshots/documentation.png?raw=true)

## Steps:

1. Execute ```pipeline-setup.sh``` to install necessary OS dependencies. This script will update the system, download and install the following main packages with their dependencies:
    - Python 3
    - Docker (from Docker.com repository)
    - pip (performs user level installation):
      - pipx 
      - pipenv 
      - tox 
      - docker-compose
2. Log out of the OS session and log in again as the user was added to the "docker" group, this makes possible for docker to run without using sudo.
3. Execute ```docker-compose up``` in "docker" directory where the docker-compose.yml file is located. This command will pull all necessary images from the Internet and deal with the necessary setup for network, containers and volumes.
4. Applications can then be accessed from the host machine using the following URLs in a web browser:
    - Gitea: ```localhost:3000```
    - Jenkins: ```localhost:8080```
    - DevPi: ```localhost:3242```
5. Setup Gitea:
    - The first time you connect to Gitea, a setup screen is presented, here you only need to scroll down to the bottom of the page and click on the ```Install Gitea``` button to continue. 
    - You'll see a "Hmm. We???re having trouble finding that site." message, this is due to gitea redirecting the URL according to the hostname setup. Enter ```localhost:3000``` as the URL to continue to the login page:
        - User #1 (Admin):
            - Click ```Register``` to register the admin user (I'll use "gitea" username as an example).
            - Add an ```Organization -> New Organization```, (I'm using "pipeline" as the organization name) and click  ```Create Organization``` when done.
            - Create a ```New Repository```, change the Owner field to the organization name "pipeline", change Default branch from "master" to "main", name your repository (I'm using "python-pipeline" as an example name) and click  ```Create Repository``` when done.
            - In ```Settings -> Webhooks -> Add Webhook -> Gitea``` add as target URL: http://pipeline.jenkins:8080/gitea-webhook/post and leave the other fields as per default values.
            - Create 2 teams ("CI" and "QA") ```Organization -> Organization Name -> New Team -> Team Name``` and add the team name. Set the team ```Permission``` to ```Write Access``` and click ```Create Team``` for both teams.
            - Add the previously created repository to both of the teams.
            - Sign Out.
        - User #2 (CI): 
            - Click ```Register``` to register the Jenkins user (I'll use "jenkins" username as an example).
            - Click ```Settings -> Applications``` and add a Token name. Click ```Generate Token``` when done and note the token value for later use.
            - Sign Out.
        - User #3 (QA): 
            - Click ```Register``` to register a user to commit code to the repository (I'll use "tester" as an example).
            - In ```Settings -> SSH / GPG Keys``` click ```Add Key``` in Manage SSH Keys section, this will allow your user to commit changes to repositories the user is set as a contributor. You'll need to generate the key first if you haven't yet:
                - In a nutshell, execute ```ssh-keygen -t ed25519 -C "your_email_address@example_domain.com"``` (leave all options as per defaults) and copy & paste the output of ```cat ~/.ssh/id_ed25519.pub```.
                - Then, due to the forwarding port 22 to 3022 in docker create a config file in .ssh directory (change User name according to your details) like so: ```printf "Host localhost\n  HostName localhost\n  Port 3022\n  User tester\n  Preferredauthentications publickey\n  IdentityFile ~/.ssh/id_ed25519.pub\n  IdentitiesOnly yes" > ~/.ssh/config```
            - Sign Out.
    - Login with the admin user (gitea): 
        - Add the "jenkins" user to the "CI" team.
        - Add the "tester" user to the "QA" team.
6. Setup Jenkins:
    - Login using admin:admin (these details can be changed in docker/jenkins/Dockerfile).
    - Select ```Manage Jenkins -> Configure System -> Gitea Servers -> Add -> Gitea Server -> Server URL``` add http://pipeline.gitea:3000 and click ```Save```.
    - Select ```New Item``` and add a value in the "Enter an item name" field ("pipeline") and select ```Gitea Organization -> OK``` 
    - In the ```Credentials -> Add -> Name of the item name -> Kind -> Gitea Personal Access Token``` and paste the personal token value generated for user "jenkins" in Gitea and enter a value for ID. Click ```Add``` to save. In ```Credentials -> Change the ID value``` and make sure to use the correct organization name from Gitea in the "Owner" field ("pipeline" in my case) to finish. Click ```Save``` to finish.
    - As you haven't pushed any code to the repository the pipeline will not do anything just yet.
    - Select ```Manage Jenkins -> Manage Credentials -> Jenkins -> Global credentials -> Add Credentials -> Kind -> Secret text``` type the DevPi password as defined in the .env file variable PIPELINE_DEVPI_USER_PASSWORD and set the ID to "devpi-pipeline" (this is necessary to match the ID defined in the Jenkinsfile post -> success -> step credentialsId value). Click ```OK``` to continue.
7. Commit code to the pipeline:
    - On a terminal window, in the project directory execute:
        - ```git init```
        - ```git add .```
        - ```git remote set-url origin git@localhost:pipeline/python-pipeline.git``` (details available in Gitea, note the use of localhost instead of pipeline.gitea because the code is being pushed from local machine to docker, "set-url" is used instead of "add" because the code was cloned from my github)
        - ```git push origin HEAD:main``` to push your code into Gitea
8. Click ```Open Blue Ocean``` to see the job running.

**Running from CLI:**
- Execute linting checks ```pipenv run tox -e lint```
- Execute tests ```pipenv run tox -e test```
- Generate src and test documentation ```pipenv run tox -e docs```
- Generate installable package ```pipenv run tox -e build```
- Run everything ```pipenv run tox```

## Notes

**Hostnames:**
1. Gitea application has hostname: ```pipeline.gitea```
2. Jenkins application has hostname: ```pipeline.jenkins```
3. DevPi has hostname: ```pipeline.devpi```
4. Postgres Database has hostname: ```pipeline.gitea.postgres```

**Configuration**
- Central variables configuration can be found in file ```docker/.env```

