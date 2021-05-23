# pipeline
Sets up a local pipeline using Docker, DinD, sysbox, Jenkins, Gitea, python, pyenv, pipenv, tox, pdoc3, fint. 

- Uses Ubuntu 20.04 as base the base Operating System. 

 - Intended for a local installation. If using in a Cloud environment or Internet facing server you should setup certifcates, configure domain names and deal with any extra necessary configurations required for network, e-mail and application settings.

- The pipeline it setup to test Python applications, obviously it can be expanded to support other languages, but it's outside the scope for this example.

## Steps:

1. Execute ```pipeline-setup.sh``` to install necessary OS dependencies. This script will update the system, download and install the following main packages with their dependencies:
    - Python 3
    - Docker (from Docker.com repository)
    - pip (performs user level installation):
      - pipx 
      - pipenv 
      - tox 
      - docker-compose
2. Log out of the OS session and log in again as the user was added to the docker group, this makes possible for docker to run without calling sudo.
3. Execute ```docker-compose up``` in the directory where the docker-compose.yml file is located. This command will pull all necessary images from the Internet and deal with the necessary setup for network, containers and volumes. Inside of docker/jenkins directory, you'll find a Dockerfile which is used to build a customized Jenkins container with setup permissions, admin user setup out of the box and two executors available to run jobs.
4. Applications can be accessed through the following URLs:
    - Gitea: ```localhost:3000```
    - Jenkins: ```localhost:8080```
5. Setup Gitea:
    - The first time you connect a setup screen is presented where all configuration is already setup, you only need to scroll down to the bottom of the page and click the ```Install Gitea``` button to continue. 
    - You'll see a "Hmm. We’re having trouble finding that site." message, this is due to gitea redirecting the URL according to the hostname setup. Enter ```localhost:3000``` as the URL to continue to the login page:
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
7. Commit code to the pipeline:
    - On a terminal window, in the project directory execute:
        - ```git init```
        - ```git add .```
        - ```git remote set-url origin git@localhost:pipeline/python-pipeline.git``` (details available in Gitea, note the use of localhost instead of pipeline.gitea because the code is being pushed from local machine to docker, "set-url" is used instead of "add" because the code was cloned from my github)
        - ```git push origin HEAD:main``` to push your code into Gitea
8. Click ```Open Blue Ocean``` to see the job running.
## Screenshots
Success:
![Image](./screenshots/jenkins_blue_ocean_pass_tests.png?raw=true)

Example failure while executing Tests:
![Image](./screenshots/jenkins_blue_ocean_failed_tests.png?raw=true)

Failed test:
![Image](./screenshots/jenkins_blue_ocean_pipeline.png?raw=true)

Artifacts collected:
![Image](./screenshots/jenkins_blue_ocean_artifacts.png?raw=true)

Artifacts and documentation:
![Image](./screenshots/jenkins_build_outputs.png?raw=true)

Test result trend using Junit and test report:
![Image](./screenshots/jenkins_test_trend.png?raw=true)

## Notes

**Notes on hostnames:**
1. Postgres Database has hostname: ```pipeline.gitea.postgres```
2. Gitea application has hostname: ```pipeline.gitea```
3. Jenkins application has hostname: ```pipeline.jenkins```

**Notes on tox:**
1. Execute tests ```[pipenv run] tox -e test```
2. Execute linting checks ```[pipenv run] tox -e lint```
3. Generate src and test documentation ```[pipenv run] tox -e docs```
4. Generate installable build ```[pipenv run] tox -e build```
5. Run everything ```[pipenv run] tox```