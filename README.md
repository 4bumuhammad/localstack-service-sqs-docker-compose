# &#x1F6A9; Localstack service SQS (Amazon Simple Queue Service) build with docker compose.

&nbsp;

### &#x1F530; Docker Compose.
<pre>
    ❯ docker-compose.yml

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
</pre>

<pre>
     ❯ docker restart localstack_sqs

     ❯ docker logs localstack_sqs

     ❯ docker exec -it localstack_sqs /bin/sh

     ❯ docker exec -it localstack_sqs /bin/sh
</pre>
<pre>
        #########################################################################
        ❯ aws configure list
                Name                    Value             Type    Location
                ----                    -----             ----    --------
            profile                  <not set>             None    None
            access_key      ****************xyz shared-credentials-file    
            secret_key      ****************aaa shared-credentials-file    
                region           ap-southeast-3      config-file    ~/.aws/config     
</pre>