pipeline {
    agent any
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
	environment {
		SCANNER_HOME= tool 'sonar-scanner'
	}
    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/AhmedWaleedAhmed/DevOpsPipelineMastery.git'
            }
        }
        
        stage('Setup the working directory') {
            steps {
                script {
                    // Get the current working directory (workspace)
                    env.WORKSPACE_DIR = "${pwd()}/boardgame"
                }
            }
        }
        
        stage('Compile') {
            steps {
                dir("${env.WORKSPACE_DIR}") {
                    sh "mvn compile"
                }
            }
        }
        
        stage('Test') {
            steps {
                dir("${env.WORKSPACE_DIR}") {
                    sh "mvn test"
                }
            }
        }
        
        stage('File System Scan by Trivy') {
            // Scan the file system to find the vulnerabilities that may exist in the dependencies we are using.
            // We can find all of the dependencies in the pom.xml file.
            // We also want to know if there are any sensitive data stored in our source code directory.
            steps {
                dir("${env.WORKSPACE_DIR}") {
					// This will scan the file system and the output will be in a tabular format and will be stored in a file called trivy-fs-report.html
					// . refers to just the scan the current directory only
                    sh "trivy fs --format table -o trivy-fs-report.html ."
                }
            }
        }

		stage('SonarQube Analysis') {
			// Here we need to configure the sonarqube server like we configured the sonarqube client on the Jenkins tools.
			// Go to the sonarqube server itself
			// Administration -> Security -> Users -> update tokens -> create a token (sonar-token) -> generate -> save it with you.
			// squ_20dc28d8049db9d81b8e5599052beacfff290447
			// Manage Jenkins -> Credentials -> System -> Global credentials (unrestricted)
			// Kind: Secret text, Scope: Global (Jenkins, nodes, items, all child items, etc), Secret: squ_20dc28d8049db9d81b8e5599052beacfff290447, ID: sonar-token, Description: sonar-token
			// Manage Jenkins -> System -> SonarQube servers
			// Name: sonar, Server URL: http://18.197.188.131:9000, SonarQube authentication token: sonar-token.
            steps {
                dir("${env.WORKSPACE_DIR}") {
                    withSonarQubeEnv('sonar') {
						sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=BoardGame -Dsonar.projectKey=BoardGame \
								-Dsonar.java.binaries=. '''
					}
                }
            }
        }

		stage('Quality Gate') {
			// Go to the sonarqube server itself
			// Administration -> Configuration -> Webhooks
			// Name: jenkins, URL: http://54.93.103.63:8080/sonarqube-webhook/
			steps {
				dir("${env.WORKSPACE_DIR}") {
					script {
						waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
					}
				}
			}
		}

		stage('Build') {
			steps {
				dir("${env.WORKSPACE_DIR}") {
					sh "mvn package"
				}
			}
		}

		stage('Publish To Nexus') {
			// here we update the last part of the pom.xml related to maven-releases and maven-snapshots with the urls related to nexus we copy them from the relaeses and snapshot 
			// we need to add a configuration file in managed files and this will be `Global Maven settings`
			// id = global-settings   
			steps {
				dir("${env.WORKSPACE_DIR}") {
					withMaven(globalMavenSettingsConfig: 'global-settings', jdk: 'jdk17', maven: 'maven3', mavenSettingsConfig: '', traceability: true) {
						sh "mvn deploy"
					}
				}
			}
		}

        stage('Build & Tag Docker Image') {
			steps {
				dir("${env.WORKSPACE_DIR}") {
					script {
						// This step should not normally be used in your script. Consult the inline help for details.
						withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
							sh "docker build -t ahmedwaleed/boardgame:${env.BUILD_NUMBER} ."
						}
					}
				}
			}
		}

		stage('Docker Image Scan') {
			steps {
				dir("${env.WORKSPACE_DIR}") {
					sh "trivy image --format table -o trivy-image-report.html ahmedwaleed/boardgame:${env.BUILD_NUMBER}"
				}
			}
		}

		stage('Push Docker Image') {
			steps {
				dir("${env.WORKSPACE_DIR}") {
					script {
						withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
							sh "docker push ahmedwaleed/boardgame:${env.BUILD_NUMBER}"
						}
					}
				}
			}
		}

		stage('Deploy To Kubernetes') {
			steps {
				dir("${env.WORKSPACE_DIR}") {
					// we need to get this url from k8s_master server
					// cd ~/.kube
					// cat config | grep server
					//  here we just need to get the private ip and update this with it only.
					withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '',
					credentialsId: 'k8-cred', namespace: 'webapps', restrictKubeConfigAccess: false,
					serverUrl: 'https://10.10.10.91:6443') {
						sh "export IMAGE_TAG=${env.BUILD_NUMBER}"
						sh "envsubst < deployment-service.yaml | kubectl apply -f -"
					}
				}
			}
		}

		stage('Verify the Deployment') {
			steps {
				withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '',
				credentialsId: 'k8-cred', namespace: 'webapps', restrictKubeConfigAccess: false,
				serverUrl: 'https://10.10.10.91:6443') {
					sh "kubectl get pods -n webapps"
					sh "kubectl get svc -n webapps"
				}
			}
		}
    }

	// post {
	// 	always {
	// 		script {
	// 			def jobName = env.JOB_NAME
	// 			def buildNumber = env.BUILD_NUMBER
	// 			def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
	// 			def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'
	// 			def body = """
	// 			<html>
	// 			<body>
	// 			<div style="border: 4px solid ${bannerColor}; padding:
	// 			10px;">
	// 			<h2>${jobName} - Build
	// 			${buildNumber}</h2>
	// 			<div style="background-color:
	// 			${bannerColor}; padding:
	// 			10px;">
	// 			<h3 style="color: white;">Pipeline
	// 			Status:
	// 			${pipelineStatus.toUpperCase()}</h3>
	// 			</div>
	// 			<p>Check the <a href="${BUILD_URL}">consoleoutput</a>.</p> </div>
	// 			</body>
	// 			</html>
	// 			"""
	// 			emailext (
	// 			subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
	// 			body: body,
	// 			to: 'ahmdwlydahmd09@gmail.com',
	// 			from: 'jenkins@example.com',
	// 			replyTo: 'jenkins@example.com',
	// 			mimeType: 'text/html',
	// 			attachmentsPattern: 'trivy-image-report.html'
	// 			)
	// 		}
	// 	}
	// }
}