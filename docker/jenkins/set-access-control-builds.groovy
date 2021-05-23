import jenkins.*
import jenkins.model.*
import hudson.model.*
import jenkins.model.Jenkins
import org.jenkinsci.plugins.authorizeproject.*
import org.jenkinsci.plugins.authorizeproject.strategy.*
import jenkins.security.QueueItemAuthenticatorConfiguration

def instance = Jenkins.getInstance()

def strategyMap = [
  (instance.getDescriptor(AnonymousAuthorizationStrategy.class).getId()): false, 
  (instance.getDescriptor(TriggeringUsersAuthorizationStrategy.class).getId()): true,
  (instance.getDescriptor(SpecificUsersAuthorizationStrategy.class).getId()): false,
  (instance.getDescriptor(SystemAuthorizationStrategy.class).getId()): false
]

def authenticators = QueueItemAuthenticatorConfiguration.get().getAuthenticators()
def configureProjectAuthenticator = true
for(authenticator in authenticators) {
  if(authenticator instanceof ProjectQueueItemAuthenticator) {
    configureProjectAuthenticator = false
  }
}

if(configureProjectAuthenticator) {
  authenticators.add(new ProjectQueueItemAuthenticator(strategyMap))
}

instance.save()