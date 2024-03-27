# &#x1F6A9; Localstack service SQS (Amazon Simple Queue Service) build with docker compose.

&nbsp;

### &#x1F530; Docker Compose.
<pre>
    ❯ ccat docker-compose.yml

            version: "3.7"
            
            services:
              localstack:
                container_name: "${LOCALSTACK_DOCKER_NAME-localstack_main}"
                image: localstack/localstack:0.12.14
                container_name: localstack_sqs
                network_mode: bridge
                environment:
                  - SERVICES=sqs
                ports:
                  - "127.0.0.1:4566:4566"
                  - "127.0.0.1:4571:4571"
                volumes:
                  - ./localstack:/docker-entrypoint-initaws.d
</pre>

&nbsp;

### &#x1F530; Run Commands in a Docker Container
<pre>
    ❯ docker-compose up

        [+] Running 0/2
        ⠏ localstack Pulling                                                                                                                                                                                  [+] Running 2/2   75.9s
        ⠿ localstack Pulled                                                                                                                                                                            114.6s 
        ⠿ 7a506c49ef4b Pull complete                                                                                                                                                                 110.8s
        [+] Running 1/1
        ⠿ Container localstack_sqs  Created                                                                                                                                                              0.3s
        Attaching to localstack_sqs
        localstack_sqs  | Waiting for all LocalStack services to be ready
        localstack_sqs  | 2024-03-27 10:20:49,241 CRIT Supervisor is running as root.  Privileges were not dropped because no user is specified in the config file.  If you intend to run as root, you can set user=root in the config file to avoid this message.
        localstack_sqs  | 2024-03-27 10:20:49,250 INFO supervisord started with pid 28
        localstack_sqs  | 2024-03-27 10:20:50,275 INFO spawned: 'dashboard' with pid 46
        localstack_sqs  | 2024-03-27 10:20:50,289 INFO spawned: 'infra' with pid 48
        localstack_sqs  | 2024-03-27 10:20:50,347 INFO success: dashboard entered RUNNING state, process has stayed up for > than 0 seconds (startsecs)
        localstack_sqs  | 2024-03-27 10:20:50,348 INFO exited: dashboard (exit status 0; expected)
        localstack_sqs  | (. .venv/bin/activate; exec bin/localstack start --host)
        localstack_sqs  | 2024-03-27 10:20:51,353 INFO success: infra entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
        localstack_sqs  | Starting local dev environment. CTRL-C to quit.
        localstack_sqs  | Waiting for all LocalStack services to be ready
        localstack_sqs  | Waiting for all LocalStack services to be ready
        localstack_sqs  | Waiting for all LocalStack services to be ready
        localstack_sqs  | 
        localstack_sqs  | LocalStack version: 0.12.14
        localstack_sqs  | LocalStack build date: 2021-07-02
        localstack_sqs  | LocalStack build git hash: 8c006f12
        localstack_sqs  | 
        localstack_sqs  | Starting edge router (https port 4566)...
        localstack_sqs  | 2024-03-27T10:21:10:INFO:localstack.utils.analytics.profiler: Execution of "load_plugin_from_path" took 721.87ms
        localstack_sqs  | 2024-03-27T10:21:10:INFO:localstack.utils.analytics.profiler: Execution of "load_plugins" took 723.21ms
        localstack_sqs  | Starting mock SQS service on http port 4566 ...
        localstack_sqs  | 2024-03-27T10:21:12:INFO:localstack.multiserver: Starting multi API server process on port 52073
        localstack_sqs  | [2024-03-27 10:21:12 +0000] [52] [INFO] Running on https://0.0.0.0:4566 (CTRL + C to quit)
        localstack_sqs  | 2024-03-27T10:21:12:INFO:hypercorn.error: Running on https://0.0.0.0:4566 (CTRL + C to quit)
        localstack_sqs  | [2024-03-27 10:21:12 +0000] [52] [INFO] Running on http://0.0.0.0:52073 (CTRL + C to quit)
        localstack_sqs  | 2024-03-27T10:21:12:INFO:hypercorn.error: Running on http://0.0.0.0:52073 (CTRL + C to quit)
        localstack_sqs  | Waiting for all LocalStack services to be ready
        localstack_sqs  | Waiting for all LocalStack services to be ready
        localstack_sqs  | Waiting for all LocalStack services to be ready
        localstack_sqs  | Ready.
        localstack_sqs  | 2024-03-27T10:21:37:INFO:localstack.utils.analytics.profiler: Execution of "start_api_services" took 26133.66ms
</pre>

open with other terminals.<br />

<pre>
    ❯ docker exec -it localstack_sqs /bin/sh
</pre>
<pre>
        #########################################################################
        ❯ aws configure list
                Name                    Value             Type    Location
                ----                    -----             ----    --------
            profile                   <not set>             None    None
            access_key                <not set>             None    None
            secret_key                <not set>             None    None
                region                <not set>             None    None

        ❯ cat ~/.aws/credentials
            cat: can't open '/root/.aws/credentials': No such file or directory                

        ❯ aws configure set aws_access_key_id xyz
        ❯ aws configure set aws_secret_access_key aaa
        ❯ aws configure set default.region ap-southeast-3

        ❯ aws configure list
                Name                    Value             Type    Location
                ----                    -----             ----    --------
            profile                    <not set>             None    None
            access_key       ****************xyz  shared-credentials-file    
            secret_key       ****************aaa  shared-credentials-file    
                region            ap-southeast-3      config-file    ~/.aws/config
                

        ❯ cat ~/.aws/credentials
            [default]
            aws_access_key_id = xyz
            aws_secret_access_key = aaa
        #########################################################################
</pre>
<pre>
        #########################################################################
        ❯ awslocal sqs create-queue --queue-name submit_order
            {
                "QueueUrl": "http://localhost:4566/000000000000/submit_order"
            }        

        ❯ awslocal sqs list-queues --queue-name-prefix submit
            {
                "QueueUrls": [
                    "http://localhost:4566/000000000000/submit_order"
                ]
            }
        #########################################################################

        ❯ exit
</pre>

&nbsp;

### &#x1F530; Bring back to the command interpreter

<pre>
     ❯ docker restart localstack_sqs

     ❯ docker logs localstack_sqs
 
     ❯ docker exec -it localstack_sqs /bin/sh
</pre>

### &#x1F530; Command once more in the container's interactive shell

<pre>
        #########################################################################
        ❯ aws configure list
                Name                    Value             Type    Location
                ----                    -----             ----    --------
            profile                  <not set>             None    None
            access_key      ****************xyz shared-credentials-file    
            secret_key      ****************aaa shared-credentials-file    
                region           ap-southeast-3      config-file    ~/.aws/config     

        #########################################################################
</pre>