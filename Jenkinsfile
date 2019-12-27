pipeline {
  agent any
  
  stages {
    stage('Checkout') {
      steps {
        sh 'git checkout master'
      }
    }
    stage('yaml2tfvar') {
      steps {
        sh 'echo Build Count: $BUILD_NUMBER'
		sh 'Conductor/bin/conductor.sh'
      }
    }
    stage('Git-add') {
      steps {
        sh 'Conductor/bin/git-add.sh'
      }
    }
    stage('Git-Commit') {
      steps {
        sh 'Conductor/bin/git-commit.sh'
      }
    }
    stage('Git-Tagging') {
      steps {
        sh 'Conductor/bin/git-tag.sh'
      }
    }
    stage('Staging') {
      steps {
        sh 'Conductor/bin/push2stage.sh'
      }
    }
  }
  post {
    always {
      echo 'One way or another, I have finished'
      deleteDir() /* clean up our workspace */
    }
    success {
      echo 'I succeeeded!'
	  sh 'curl -X POST http://192.168.1.178:8080/jenkins/job/Hello_Terraform/build --user "jenkins:Chenna!44"'
    }
    unstable {
      echo 'I am unstable :/'
    }
    failure {
      echo 'I failed :('
    }
    changed {
      echo 'Things were different before...'
    }
  }	
}
