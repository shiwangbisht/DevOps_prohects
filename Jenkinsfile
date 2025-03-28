pipeline{
    agent any
    
    tools{
        jdk "JDK11"
        maven "mave3"
    }

    environment{
        SCANNER_HOME= tool 'sonar-scanner'
    }

    stages{
        stage("git-checkout"){
            steps{
                echo "========executing git-checkout stage to be performed========"
                git 'https://github.com/jaiswaladi246/secretsanta-generator.git'
            }
        }

        stage("compile"){
            steps{
                echo "=================compiling the source code=============="
                sh "mvn clean compile"
            }
        }

        stage("sonar-analysis"){
            steps {
               withSonarQubeEnv('sonar'){
                   sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Santa \
                   -Dsonar.java.binaries=. \
                   -Dsonar.projectKey=Santa '''
               }
            }
        }

        stage("OWASP dependency-check"){
            steps{
                dependencyCheck additionalArguments: ' --scan ./ ', odcInstallation: 'DC'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage("code-build"){
            steps{
                sh 'mvn clean package'
            }
        }

        stage("docker-build"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'docker-cred') {
                    sh "docker build -t  santa123 . "
                    }
                }
            }
        }

        stage("docker push"){
            steps {
               script{
                   withDockerRegistry(credentialsId: 'docker-cred') {
                    sh "docker tag santa123 shiwang2726/santa123:latest"
                    sh "docker push shiwang2726/santa123:latest"
                 }
               }
            }
        }

        stage("docker run"){
            steps{
                sh 'docker run --name santa-app -p 8080:8081 -d shiwang2726/santa123:latest'

            }
            
        }
    }
}



    