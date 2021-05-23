import jenkins.model.*

def jenkins = JenkinsLocationConfiguration.get()
jenkins.setUrl("http://pipeline.jenkins:8080/") 
jenkins.save() 