# &#x1F6A9; Localstack service SQS (Amazon Simple Queue Service) build with docker compose.

&nbsp;

<pre>
    ❯ touch localstack/localstack_home/create-queue.json

    ❯ vim localstack/localstack_home/create-queue.json
        {
        "RedrivePolicy": "{\"deadLetterTargetArn\":\"arn:aws:sqs:us-east-1:80398EXAMPLE:MyDeadLetterQueue\",\"maxReceiveCount\":\"1000\"}",
        "MessageRetentionPeriod": "259200"
        }
</pre>


https://docs.aws.amazon.com/cli/latest/reference/sqs/create-queue.html

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
                  - ./localstack/localstack_entrypoint:/docker-entrypoint-initaws.d
                  - ./localstack/localstack_home:/home/localstack
</pre>

&nbsp;

### &#x1F530; Run Commands in a Docker Container
<pre>
    ❯ docker-compose up

        [+] Running 1/0
        ⠿ Container localstack_sqs  Created                                                                                                                                         0.0s
        Attaching to localstack_sqs
        localstack_sqs  | Waiting for all LocalStack services to be ready
        localstack_sqs  | 2024-03-27 10:58:19,913 CRIT Supervisor is running as root.  Privileges were not dropped because no user is specified in the config file.  If you intend to run as root, you can set user=root in the config file to avoid this message.
        localstack_sqs  | 2024-03-27 10:58:19,923 INFO supervisord started with pid 31
        localstack_sqs  | 2024-03-27 10:58:20,943 INFO spawned: 'dashboard' with pid 49
        localstack_sqs  | 2024-03-27 10:58:20,954 INFO spawned: 'infra' with pid 51
        localstack_sqs  | 2024-03-27 10:58:21,022 INFO success: dashboard entered RUNNING state, process has stayed up for > than 0 seconds (startsecs)
        localstack_sqs  | 2024-03-27 10:58:21,023 INFO exited: dashboard (exit status 0; expected)
        localstack_sqs  | (. .venv/bin/activate; exec bin/localstack start --host)
        localstack_sqs  | 2024-03-27 10:58:22,028 INFO success: infra entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
        localstack_sqs  | Starting local dev environment. CTRL-C to quit.
        localstack_sqs  | Waiting for all LocalStack services to be ready
        localstack_sqs  | Waiting for all LocalStack services to be ready
        localstack_sqs  | Waiting for all LocalStack services to be ready
        localstack_sqs  | 
        localstack_sqs  | LocalStack version: 0.12.14
        localstack_sqs  | LocalStack build date: 2021-07-02
        localstack_sqs  | LocalStack build git hash: 8c006f12
        localstack_sqs  | 
        localstack_sqs  | 2024-03-27T10:58:41:INFO:localstack.utils.analytics.profiler: Execution of "load_plugin_from_path" took 741.58ms
        localstack_sqs  | 2024-03-27T10:58:41:INFO:localstack.utils.analytics.profiler: Execution of "load_plugins" took 743.15ms
        localstack_sqs  | Starting edge router (https port 4566)...
        localstack_sqs  | Starting mock SQS service on http port 4566 ...
        localstack_sqs  | 2024-03-27T10:58:42:INFO:localstack.multiserver: Starting multi API server process on port 55553
        localstack_sqs  | [2024-03-27 10:58:42 +0000] [55] [INFO] Running on https://0.0.0.0:4566 (CTRL + C to quit)
        localstack_sqs  | 2024-03-27T10:58:42:INFO:hypercorn.error: Running on https://0.0.0.0:4566 (CTRL + C to quit)
        localstack_sqs  | [2024-03-27 10:58:42 +0000] [55] [INFO] Running on http://0.0.0.0:55553 (CTRL + C to quit)
        localstack_sqs  | 2024-03-27T10:58:42:INFO:hypercorn.error: Running on http://0.0.0.0:55553 (CTRL + C to quit)
        localstack_sqs  | Waiting for all LocalStack services to be ready
        localstack_sqs  | Waiting for all LocalStack services to be ready
        localstack_sqs  | Waiting for all LocalStack services to be ready
        localstack_sqs  | Ready.
        localstack_sqs  | 2024-03-27T10:59:06:INFO:localstack.utils.analytics.profiler: Execution of "start_api_services" took 24444.08ms

</pre>

open with other terminals.<br />

<pre>
    ❯ docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}\t{{.Ports}}"
        CONTAINER ID   IMAGE                           STATUS          NAMES            PORTS
        46fa761e7514   localstack/localstack:0.12.14   Up 37 seconds   localstack_sqs   127.0.0.1:4566->4566/tcp, 5678/tcp, 127.0.0.1:4571->4571/tcp, 8080/tcp

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