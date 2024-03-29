# &#x1F6A9; Localstack service SQS (Amazon Simple Queue Service) build with docker compose.

&nbsp;

**Reference :**<br />
<pre>
    https://docs.aws.amazon.com/cli/latest/reference/sqs/set-queue-attributes.html

    https://docs.localstack.cloud/user-guide/aws/sqs/

    https://github.com/polovyivan/localstack-sqs-with-dlq-setup/tree/main/docker-compose
</pre>

&nbsp;


Prepare several json files that will be used later in the implementation of the test sample.
<pre>
    ❯ touch localstack/localstack_home/create-queue.json

    ❯ vim localstack/localstack_home/create-queue.json
        {
                "RedrivePolicy": "{\"deadLetterTargetArn\":\"arn:aws:sqs:ap-southeast-3:000000000000:my-dead-letter-queue\",\"maxReceiveCount\":\"1000\"}",
                "MessageRetentionPeriod": "259200"
        }
</pre>
<pre>
    ❯ touch localstack/localstack_home/set-queue-attributes.json

    ❯ vim localstack/localstack_home/set-queue-attributes.json
        {
            "ReceiveMessageWaitTimeSeconds": "1",
            "VisibilityTimeout": "20"
        }    
</pre>

&nbsp;

### &#x1F530; Docker Compose.
<pre>
    ❯ ccat docker-compose.yml

            version: "3.7"
            
            services:
              localstack:
                container_name: "${LOCALSTACK_DOCKER_NAME-localstack_main}"
                image: localstack/localstack:3.2
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
        ⠿ Container localstack_sqs  Created                                                                                                                                                               0.0s
        Attaching to localstack_sqs
        localstack_sqs  | 
        localstack_sqs  | LocalStack version: 3.2.0
        localstack_sqs  | LocalStack build date: 2024-02-28
        localstack_sqs  | LocalStack build git hash: 4a4692dd5
        localstack_sqs  | 
        localstack_sqs  | 2024-03-28T14:05:00.548  INFO --- [-functhread4] hypercorn.error            : Running on https://0.0.0.0:4566 (CTRL + C to quit)
        localstack_sqs  | 2024-03-28T14:05:00.548  INFO --- [-functhread4] hypercorn.error            : Running on https://0.0.0.0:4566 (CTRL + C to quit)
        localstack_sqs  | 2024-03-28T14:05:00.779  INFO --- [  MainThread] localstack.utils.bootstrap : Execution of "start_runtime_components" took 606.90ms
        localstack_sqs  | Ready.

</pre>

&nbsp;

&nbsp;

Open with other terminals.
<pre>
    ❯ docker images --format "{{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}" | grep "localstack"
        localstack/localstack   3.2     0c24dfc7a774    2024-02-28 11:36:19 +0700 WIB   1.12GB

    ❯ docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}\t{{.Ports}}" | grep "localstack"
        CONTAINER ID   IMAGE                           STATUS          NAMES            PORTS
        2c702cd1c903   localstack/localstack:3.2   Up 9 minutes (healthy)   localstack_sqs   127.0.0.1:4566->4566/tcp, 4510-4559/tcp, 5678/tcp, 127.0.0.1:4571->4571/tcp
</pre>

&nbsp;

Check health:
<pre>
    ❯ docker inspect --format 'Status: {{json .State.Health.Status}}, FailingStreak: {{json .State.Health.FailingStreak}}' localstack_sqs
        Status: "healthy", FailingStreak: 0
</pre>

&nbsp;

Command into the container.<br />
<pre>
    ❯ docker exec -it localstack_sqs /bin/bash
</pre>
<pre>
        #########################################################################
        ❯ aws configure list

                Name                    Value             Type    Location
                ----                    -----             ----    --------
            profile                <not set>             None    None
            access_key                <not set>             None    None
            secret_key                <not set>             None    None
                region                <not set>             None    None

        ❯ aws configure set aws_access_key_id xyz
        ❯ aws configure set aws_secret_access_key aaa
        ❯ aws configure set default.region ap-southeast-3

        ❯ aws configure list

                Name                    Value             Type    Location
                ----                    -----             ----    --------
            profile                <not set>             None    None
            access_key      ****************xyz shared-credentials-file    
            secret_key      ****************aaa shared-credentials-file    
                region           ap-southeast-3      config-file    ~/.aws/config

        ❯ cat ~/.aws/credentials
            [default]
            aws_access_key_id = xyz
            aws_secret_access_key = aaa
        #########################################################################
</pre>

&nbsp;

**&#x2705; Example 1**: create-queue, list-queue, send-message, receive-message, delete-queue.
<pre>
        #########################################################################

        # Example 1 :

        ❯ awslocal sqs create-queue --queue-name submit_order
            {
                "QueueUrl": "http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/submit_order"
            }     

        ❯ awslocal sqs list-queues --queue-name-prefix submit
            {
                "QueueUrls": [
                    "http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/submit_order"
                ]
            }
</pre>
<pre>
        ❯ awslocal sqs send-message --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/submit_order --message-body "Welcome to SQS queue by Dhony Abu Muhammad"
            {
                "MD5OfMessageBody": "7505439829c760b42b22a2c6a81a3746",
                "MessageId": "fba92c66-1442-422b-8d82-649acd0e9fad"
            }       
</pre>
<pre>
        ❯ awslocal sqs receive-message --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/submit_order
            {
                "Messages": [
                    {
                        "MessageId": "fba92c66-1442-422b-8d82-649acd0e9fad",
                        "ReceiptHandle": "OGM1YTc4MTYtODRkOS00MDQ3LTkyMWUtNDYxMDM4YjEyOWZhIGFybjphd3M6c3FzOmFwLXNvdXRoZWFzdC0zOjAwMDAwMDAwMDAwMDpzdWJtaXRfb3JkZXIgZmJhOTJjNjYtMTQ0Mi00MjJiLThkODItNjQ5YWNkMGU5ZmFkIDE3MTE2MzcwMTcuODI0NTUwOQ==",
                        "MD5OfBody": "7505439829c760b42b22a2c6a81a3746",
                        "Body": "Welcome to SQS queue by Dhony Abu Muhammad"
                    }
                ]
            }
</pre>
<pre>
        ❯ awslocal sqs delete-queue --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/submit_order
</pre>

&nbsp;

Install jq (a lightweight and flexible command-line JSON processor).<br />
<pre>
        # Install jq
        ❯ apt update && apt install jq
        ❯ jq --version
            jq-1.6
</pre>

&nbsp;

**&#x2705; Example 2**: create-queue, set-queue-attributes, receive-message max-number-of-messages, delete-message, purge-queue
<pre>
        # Example 2 :

        ❯ awslocal sqs create-queue --queue-name test-queue --attributes "ReceiveMessageWaitTimeSeconds=1,VisibilityTimeout=20"
                        
            {
                "QueueUrl": "http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/test-queue"
            }
        
        ❯ awslocal sqs delete-queue --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/test-queue
</pre>
<pre>        
        ❯ ls -lah /home/localstack/ | grep set-queue-attributes.json
            -rw-r--r-- 1 root root  166 Mar 28 02:04 set-queue-attributes.json

        # or set-attributes with a file .json
        ❯ awslocal sqs create-queue --queue-name test-queue
            {
                "QueueUrl": "http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/test-queue"
            }

        ❯ awslocal sqs set-queue-attributes \
            --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/test-queue \
            --attributes file:///home/localstack/set-queue-attributes.json
</pre>
<pre>
        # continue command
        ❯ awslocal sqs list-queues --queue-name-prefix test
            {
                "QueueUrls": [
                    "http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/test-queue"
                ]
            }


        ❯ awslocal sqs get-queue-attributes --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/test-queue --attribute-names All | jq -r .
            {
            "Attributes": {
                "ApproximateNumberOfMessages": "0",
                "ApproximateNumberOfMessagesNotVisible": "0",
                "ApproximateNumberOfMessagesDelayed": "0",
                "CreatedTimestamp": "1711637978",
                "DelaySeconds": "0",
                "LastModifiedTimestamp": "1711637978",
                "MaximumMessageSize": "262144",
                "MessageRetentionPeriod": "345600",
                "QueueArn": "arn:aws:sqs:ap-southeast-3:000000000000:test-queue",
                "ReceiveMessageWaitTimeSeconds": "1",
                "VisibilityTimeout": "20",
                "SqsManagedSseEnabled": "true"
            }
            }

        ❯ awslocal sqs list-queues
            {
                "QueueUrls": [
                    "http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/test-queue",
                ]
            }
</pre>
<pre>
        ❯ awslocal sqs send-message --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/test-queue \
            --message-body "Welcome to SQS queue by Dhony Abu Muhammad"
            {
                "MD5OfMessageBody": "7505439829c760b42b22a2c6a81a3746",
                "MessageId": "06f1bc5f-0932-4a2b-946a-544dec4bb736"
            }    

        ❯ awslocal sqs send-message --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/test-queue \
            --message-body "BMKG | Mag:3.7, 28-Mar-2024 04:03:03WIB, Lok:5.83LS, 112.35BT (123 km TimurLaut TUBAN-JATIM), Kedlmn:10 Km"
            {
                "MD5OfMessageBody": "bb433e30faecdbee39f3ba4a2789a928",
                "MessageId": "0a87b845-dcc6-4490-9ffa-3388c9f69076"
            }
</pre>
<pre>
        ❯ awslocal sqs receive-message --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/test-queue --max-number-of-messages 2
            {
                "Messages": [
                    {
                        "MessageId": "06f1bc5f-0932-4a2b-946a-544dec4bb736",
                        "ReceiptHandle": "OGY3YjRmYTEtMDk4ZC00MmJmLThiYjQtOGNmOWE1YWVkOTA1IGFybjphd3M6c3FzOmFwLXNvdXRoZWFzdC0zOjAwMDAwMDAwMDAwMDp0ZXN0LXF1ZXVlIDA2ZjFiYzVmLTA5MzItNGEyYi05NDZhLTU0NGRlYzRiYjczNiAxNzExNjM4ODgxLjEyMjMyNjQ=",
                        "MD5OfBody": "7505439829c760b42b22a2c6a81a3746",
                        "Body": "Welcome to SQS queue by Dhony Abu Muhammad"
                    },
                    {
                        "MessageId": "0a87b845-dcc6-4490-9ffa-3388c9f69076",
                        "ReceiptHandle": "ZDFmYTJjZWYtOWM1Zi00OTgzLWIzM2UtYWFjN2VkZTEyMDYwIGFybjphd3M6c3FzOmFwLXNvdXRoZWFzdC0zOjAwMDAwMDAwMDAwMDp0ZXN0LXF1ZXVlIDBhODdiODQ1LWRjYzYtNDQ5MC05ZmZhLTMzODhjOWY2OTA3NiAxNzExNjM4ODgxLjEyMjM0MDQ=",
                        "MD5OfBody": "bb433e30faecdbee39f3ba4a2789a928",
                        "Body": "BMKG | Mag:3.7, 28-Mar-2024 04:03:03WIB, Lok:5.83LS, 112.35BT (123 km TimurLaut TUBAN-JATIM), Kedlmn:10 Km"
                    }
                ]
            }
</pre>
Delete a message from the queue.<br />
<pre>
        # awslocal sqs delete-message --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/test-queue --receipt-handle &lt;receipt-handle&gt;
        ❯ awslocal sqs delete-message --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/test-queue --receipt-handle "OGY3YjRmYTEtMDk4ZC00MmJmLThiYjQtOGNmOWE1YWVkOTA1IGFybjphd3M6c3FzOmFwLXNvdXRoZWFzdC0zOjAwMDAwMDAwMDAwMDp0ZXN0LXF1ZXVlIDA2ZjFiYzVmLTA5MzItNGEyYi05NDZhLTU0NGRlYzRiYjczNiAxNzExNjM4ODgxLjEyMjMyNjQ="
</pre>
<pre>
        ❯ awslocal sqs receive-message --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/test-queue --max-number-of-messages 2
            {
                "Messages": [
                    {
                        "MessageId": "0a87b845-dcc6-4490-9ffa-3388c9f69076",
                        "ReceiptHandle": "YmQ3MTZhYjAtZTkxNy00MjkzLWE3N2EtNWE4OGJmNDQxZTk5IGFybjphd3M6c3FzOmFwLXNvdXRoZWFzdC0zOjAwMDAwMDAwMDAwMDp0ZXN0LXF1ZXVlIDBhODdiODQ1LWRjYzYtNDQ5MC05ZmZhLTMzODhjOWY2OTA3NiAxNzExNjM5MDMxLjI2MzY3MjQ=",
                        "MD5OfBody": "bb433e30faecdbee39f3ba4a2789a928",
                        "Body": "BMKG | Mag:3.7, 28-Mar-2024 04:03:03WIB, Lok:5.83LS, 112.35BT (123 km TimurLaut TUBAN-JATIM), Kedlmn:10 Km"
                    }
                ]
            }
</pre>
Command to purge the queue.<br />
<pre>
        ❯ awslocal sqs purge-queue --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/test-queue

        ❯ awslocal sqs receive-message --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/test-queue --max-number-of-messages 2
</pre>
<pre>
        ❯ awslocal sqs delete-queue --queue-url  http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/test-queue
        #########################################################################

        ❯ exit
</pre>

&nbsp;

**&#x2705; Example 3**: Dead-letter queue testing

&nbsp;

Note : To delete all existing queues in the default profile.
<pre>
        ❯ /bin/sh /home/localstack/delete_all_queues_awslocal.sh 
</pre>

&nbsp;

Configure dead-letter-queue to be a DLQ for input-queue:
<pre>
        # Example 3 :

        ❯ aws configure set default.region ap-southeast-3
        ❯ aws configure list
                Name                    Value             Type    Location
                ----                    -----             ----    --------
            profile                   <not set>             None    None
            access_key                <not set>             None    None
            secret_key                <not set>             None    None
                region           ap-southeast-3      config-file    ~/.aws/config
</pre>
<pre>
        ❯ awslocal sqs create-queue --queue-name dead-letter-queue
            {
                "QueueUrl": "http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/dead-letter-queue"
            }                    
</pre>
Get the ARN format for dead-letter-queue.
<pre>
        ❯ DLQ_SQS_ARN=$(awslocal sqs get-queue-attributes --attribute-name QueueArn --queue-url=http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/dead-letter-queue\
                |  sed 's/"QueueArn"/\n"QueueArn"/g' | grep '"QueueArn"' | awk -F '"QueueArn":' '{print $2}' | tr -d '"' | xargs)

        ❯ echo $DLQ_SQS_ARN
                arn:aws:sqs:ap-southeast-3:000000000000:dead-letter-queue
</pre>
<pre>
        ❯ awslocal sqs create-queue --queue-name input-queue \
            --attributes '{ "RedrivePolicy": "{\"deadLetterTargetArn\":\"'"$DLQ_SQS_ARN"'\",\"maxReceiveCount\":\"2\"}", "MessageRetentionPeriod": "259200"}'
                {
                    "QueueUrl": "http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/input-queue"
                }
</pre>
Or if you already know the ARN format, you can directly add it to the attribute.
<pre>
        ❯ awslocal sqs delete-queue --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/input-queue

        ❯ awslocal sqs create-queue --queue-name input-queue --attributes \
        '{ "RedrivePolicy": "{\"deadLetterTargetArn\":\"arn:aws:sqs:ap-southeast-3:000000000000:dead-letter-queue\",\"maxReceiveCount\":\"2\"}",
        "MessageRetentionPeriod": "259200"}'
                {
                    "QueueUrl": "http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/input-queue"
                }        
</pre>

Set-attributes with a file .json
<pre>
        # or set-attributes with a file .json
        ❯ awslocal sqs delete-queue --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/input-queue

        ❯ awslocal sqs create-queue --queue-name input-queue --attributes file:///home/localstack/create-queue.json
                {
                    "QueueUrl": "http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/input-queue"
                }        
</pre>
<pre>
        ❯ awslocal sqs get-queue-attributes --attribute-name All --queue-url=http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/input-queue
                {
                    "Attributes": {
                        "ApproximateNumberOfMessages": "0",
                        "ApproximateNumberOfMessagesNotVisible": "0",
                        "ApproximateNumberOfMessagesDelayed": "0",
                        "CreatedTimestamp": "1711657377",
                        "DelaySeconds": "0",
                        "LastModifiedTimestamp": "1711657377",
                        "MaximumMessageSize": "262144",
                        "MessageRetentionPeriod": "259200",
                        "QueueArn": "arn:aws:sqs:ap-southeast-3:000000000000:input-queue",
                        "ReceiveMessageWaitTimeSeconds": "0",
                        "VisibilityTimeout": "30",
                        "SqsManagedSseEnabled": "true",
                        "RedrivePolicy": "{\"deadLetterTargetArn\":\"arn:aws:sqs:ap-southeast-3:000000000000:dead-letter-queue\",\"maxReceiveCount\":\"2\"}"
                    }
                }

</pre>
<pre>
        ❯ awslocal sqs send-message --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/input-queue --message-body '{"hello": "world"}'
                {
                    "MD5OfMessageBody": "49dfdd54b01cbcd2d2ab5e9e5ee6b9b9",
                    "MessageId": "12e1b214-c36c-4983-8450-acc2e0f6023e"
                }               
</pre>
<pre>
        ❯ awslocal sqs receive-message --visibility-timeout 0 --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/input-queue
                {
                    "Messages": [
                        {
                            "MessageId": "12e1b214-c36c-4983-8450-acc2e0f6023e",
                            "ReceiptHandle": "MDNjNTQxZDMtMzE4OC00YzMyLTg4ZTgtOGJiZWEwMDUxMjE4IGFybjphd3M6c3FzOmFwLXNvdXRoZWFzdC0zOjAwMDAwMDAwMDAwMDppbnB1dC1xdWV1ZSAzOThhOTI2My1mMWJiLTQ5NTMtYmIzOC1iMTc2ZTlkYTczNjAgMTcxMTYyMTg1My4xOTk2Njk4",
                            "MD5OfBody": "49dfdd54b01cbcd2d2ab5e9e5ee6b9b9",
                            "Body": "{\"hello\": \"world\"}"
                        }
                    ]
                }

        ❯ awslocal sqs receive-message --visibility-timeout 0 --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/input-queue
                {
                    "Messages": [
                        {
                            "MessageId": "12e1b214-c36c-4983-8450-acc2e0f6023e",
                            "ReceiptHandle": "MDM0NDZjM2YtMjQ1Zi00MGQ1LWJmODQtOWE1YzU2YWI4NThhIGFybjphd3M6c3FzOmFwLXNvdXRoZWFzdC0zOjAwMDAwMDAwMDAwMDppbnB1dC1xdWV1ZSAzOThhOTI2My1mMWJiLTQ5NTMtYmIzOC1iMTc2ZTlkYTczNjAgMTcxMTYyMTkzOC45Nzk2MzY=",
                            "MD5OfBody": "49dfdd54b01cbcd2d2ab5e9e5ee6b9b9",
                            "Body": "{\"hello\": \"world\"}"
                        }
                    ]
                }

        ❯ awslocal sqs receive-message --visibility-timeout 0 --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/input-queue
            &lt;nothing&gt;
</pre>

&nbsp;

Check DLQ receive-message
<pre>
        ❯ awslocal sqs receive-message --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/dead-letter-queue --max-number-of-messages 10
                {
                    "Messages": [
                        {
                            "MessageId": "12e1b214-c36c-4983-8450-acc2e0f6023e",
                            "ReceiptHandle": "MTQ1ZDgwZjAtZTM1OC00MzIxLTk3ZTktYjZiYTY1MjNmNDI0IGFybjphd3M6c3FzOmFwLXNvdXRoZWFzdC0zOjAwMDAwMDAwMDAwMDpkZWFkLWxldHRlci1xdWV1ZSAxMmUxYjIxNC1jMzZjLTQ5ODMtODQ1MC1hY2MyZTBmNjAyM2UgMTcxMTY1ODUyMi44NjY2ODM3",
                            "MD5OfBody": "49dfdd54b01cbcd2d2ab5e9e5ee6b9b9",
                            "Body": "{\"hello\": \"world\"}"
                        }
                    ]
                }       
</pre>

&nbsp;

Create queue recovery.
<pre>
        ❯ awslocal sqs list-queues
                {
                    "QueueUrls": [
                        "http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/dead-letter-queue",
                        "http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/input-queue"
                    ]
                }

        ❯ awslocal sqs create-queue --queue-name recovery-queue
                {
                    "QueueUrl": "http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/recovery-queue"
                }
</pre>
<pre>
        ❯ awslocal sqs start-message-move-task \
                --source-arn arn:aws:sqs:ap-southeast-3:000000000000:dead-letter-queue \
                --destination-arn arn:aws:sqs:ap-southeast-3:000000000000:recovery-queue
                {
                    "TaskHandle": "eyJ0YXNrSWQiOiIwMTIwMWFjYy1kNGY3LTQ0ZDEtOGE4MC1mM2Q2Mjc5MWVlNjkiLCJzb3VyY2VBcm4iOiJhcm46YXdzOnNxczphcC1zb3V0aGVhc3QtMzowMDAwMDAwMDAwMDA6ZGVhZC1sZXR0ZXItcXVldWUifQ=="
                }

        ❯ awslocal sqs receive-message --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/dead-letter-queue --max-number-of-messages 10
                &lt;nothing&gt;

</pre>

Listing the message move tasks should yield something like
<pre>
        ❯ awslocal sqs list-message-move-tasks --source-arn arn:aws:sqs:ap-southeast-3:000000000000:dead-letter-queue
                {
                    "Results": [
                        {
                            "Status": "COMPLETED",
                            "SourceArn": "arn:aws:sqs:ap-southeast-3:000000000000:dead-letter-queue",
                            "DestinationArn": "arn:aws:sqs:ap-southeast-3:000000000000:recovery-queue",
                            "ApproximateNumberOfMessagesMoved": 1,
                            "ApproximateNumberOfMessagesToMove": 1,
                            "StartedTimestamp": 1711658656017
                        }
                    ]
                }
</pre>
<pre>
        ❯ awslocal sqs receive-message --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/recovery-queue --max-number-of-messages 10
                {
                    "Messages": [
                        {
                            "MessageId": "12e1b214-c36c-4983-8450-acc2e0f6023e",
                            "ReceiptHandle": "MjE2MmIyZTctNGVmOC00OGQ5LWJhOWMtZmUyYTczNTgxZWUyIGFybjphd3M6c3FzOmFwLXNvdXRoZWFzdC0zOjAwMDAwMDAwMDAwMDpyZWNvdmVyeS1xdWV1ZSAxMmUxYjIxNC1jMzZjLTQ5ODMtODQ1MC1hY2MyZTBmNjAyM2UgMTcxMTY1ODcwNC45MjgwOTk5",
                            "MD5OfBody": "49dfdd54b01cbcd2d2ab5e9e5ee6b9b9",
                            "Body": "{\"hello\": \"world\"}"
                        }
                    ]
                }
</pre>

&nbsp;

### SQS Query API
The SQS Query API, provides SQS Queue URLs as endpoints, enabling direct HTTP requests to the queues. LocalStack extends support for the Query API.

<pre>
    ❯ curl "http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/input-queue?Action=SendMessage&MessageBody=hello%2Fworld"
</pre>
You will see the following output:
<pre>
        &lt;?xml version='1.0' encoding='utf-8'?&gt;
        &lt;SendMessageResponse
            xmlns="http://queue.amazonaws.com/doc/2012-11-05/"&gt;
            &lt;SendMessageResult&gt;
                &lt;MD5OfMessageBody&gt;c6be4e95a26409675447367b3e79f663&lt;/MD5OfMessageBody&gt;
                &lt;MessageId&gt;66990f5f-f5ce-48a8-8dba-a9d1ca2b4d7b&lt;/MessageId&gt;
            &lt;/SendMessageResult&gt;
            &lt;ResponseMetadata&gt;
                &lt;RequestId&gt;c24bcdb0-124f-477b-b142-67c0f9c49937&lt;/RequestId&gt;
            &lt;/ResponseMetadata&gt;
        &lt;/SendMessageResponse&gt;% 
</pre>

&nbsp;

&nbsp;

### &#x1F530; command used outside the container:

<pre>
    ❯ aws --endpoint-url=http://localhost:4566 --region=ap-southeast-3 sqs list-queues --queue-name-prefix submit
        {
            "QueueUrls": [
                "http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/submit_order"
            ]
        }
</pre>
<pre>
    ❯ aws --endpoint-url=http://localhost:4566 --region=ap-southeast-3 sqs send-message \
        --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/submit_order \
        --message-body "Welcome to SQS queue by Dhony Abu Muhammad"
            {
                "MD5OfMessageBody": "7505439829c760b42b22a2c6a81a3746",
                "MessageId": "0ae30d3f-a3cf-4490-95d3-841f458d2df2"
            }
</pre>
<pre>
    ❯ aws --endpoint-url=http://localhost:4566 --region=ap-southeast-3 sqs receive-message \
        --queue-url http://sqs.ap-southeast-3.localhost.localstack.cloud:4566/000000000000/submit_order
            {
                "Messages": [
                    {
                        "MessageId": "0ae30d3f-a3cf-4490-95d3-841f458d2df2",
                        "ReceiptHandle": "Njc3NjFkMGQtYWI0Yy00YjM0LWFiNWEtMDdkMWNmOWZmOTIzIGFybjphd3M6c3FzOmFwLXNvdXRoZWFzdC0zOjAwMDAwMDAwMDAwMDpzdWJtaXRfb3JkZXIgMGFlMzBkM2YtYTNjZi00NDkwLTk1ZDMtODQxZjQ1OGQyZGYyIDE3MTE2NjEzODEuOTY2ODQ5Mw==",
                        "MD5OfBody": "7505439829c760b42b22a2c6a81a3746",
                        "Body": "Welcome to SQS queue by Dhony Abu Muhammad"
                    }
                ]
            }
</pre>

&nbsp;

&nbsp;

### &#x1F530; Bring back to the command interpreter

<pre>
     ❯ docker restart localstack_sqs

     ❯ docker logs localstack_sqs
 
     ❯ docker exec -it localstack_sqs /bin/bash
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