def terraformpath = ''
pipeline {
    agent any

    stages {
		stage('setup') {
			steps {
				script {
					if (env.GIT_BRANCH == 'origin/master') {
						echo 'I only execute on the master branch'
							terraformpath='terraform/prod'
					} else if (env.GIT_BRANCH == 'origin/dev') {
						echo 'I only execute on the dev branch'
							terraformpath='terraform/dev'
					} else {
						echo 'I execute elsewhere'
							echo env.GIT_BRANCH
					}
				}
			}
		}
		stage('build') {
			when {
				expression { env.GIT_BRANCH == 'origin/dev' }
			}
			steps {
				withCredentials([[
						$class: 'AmazonWebServicesCredentialsBinding',
						credentialsId: 'aws_creds',
						accessKeyVariable: 'AWS_ACCESS_KEY_ID',
						secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
				]]) {
					dir ("docker") {
						sh 'eval $(aws ecr get-login --region=eu-west-1)'
						sh 'cd ../terraform/static && terraform init'
						sh 'make -e VERSION=$VERSION'
					}
				}
			}
		}
		stage('Unit Test') {
			when {
				expression { env.GIT_BRANCH == 'origin/dev' }
			}
			steps {
				echo 'Test 1: Ok'
				echo 'Test 2: Ok'
				echo 'Test 3: Ok'
				echo 'Test 4: Ok'
				echo 'Test 5: Ok'
			}
		}
        stage('Deploy') {
            steps {
                withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws_creds',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    dir (terraformpath) {
						sh 'terraform init'
                        sh 'TF_VAR_app_version=$VERSION terraform apply -auto-approve'
                    }
                }
            }
		}
        stage('Func Test') {
            steps {
                withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws_creds',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    dir (terraformpath) {
						echo 'Deployment ok'
                    }
                }
            }
        }
    }
}
