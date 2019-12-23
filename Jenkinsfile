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
    stage('Git add') {
      steps {
        sh 'Conductor/bin/git-add.sh'
      }
    }
    stage('Git Commit') {
      steps {
        sh 'Conductor/bin/git-commit.sh'
      }
    }
    stage('Git Tagging') {
      steps {
        sh 'Conductor/bin/git-tag.sh'
      }
    }
    stage('Staging') {
      steps {
        sh 'Conductor/bin/push2stage.sh'
      }
    }
/*
    stage('Terraform-Deploy') {
      steps {
        sh './Terraform/bin/terraform.sh deploy'
      }
    }

    stage('Terraform-Destroy') {
      steps {
        sh './Terraform/bin/terraform.sh destroy'
      }
    }

  }
*/
}
