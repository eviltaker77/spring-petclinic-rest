pipeline {
    agent any
    tools {
        maven 'maven3.8.8'
    }
    stages {
        /*
        stage('Checkout SCM') {
            steps {
                git branch: 'main', url: 'https://github.com/eviltaker77/spring-petclinic-rest.git'
            }
        }
        */
        stage('Test') {
            steps {
                sh 'mvn clean test -B -ntp'
            }
        }
        stage('Package') {
            steps {
                sh 'mvn clean package -DskipTests -B -ntp'
            }
        }
    }
    post {
        success {
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            cleanWs()
        }
    }
}