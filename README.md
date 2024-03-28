# &#x1F6A9; Localstack service SQS (Amazon Simple Queue Service) build with docker compose.

&nbsp;

**Reference :**<br />
<pre>
    create-queue
    https://docs.aws.amazon.com/cli/latest/reference/sqs/create-queue.html

    https://docs.aws.amazon.com/cli/latest/reference/sqs/set-queue-attributes.html

    https://docs.localstack.cloud/user-guide/aws/sqs/

    https://github.com/polovyivan/localstack-sqs-with-dlq-setup/tree/main/docker-compose
</pre>

&nbsp;

<pre>
    ❯ touch localstack/localstack_home/create-queue.json

    ❯ vim localstack/localstack_home/create-queue.json
        {
        "RedrivePolicy": "{\"deadLetterTargetArn\":\"arn:aws:sqs:us-east-1:80398EXAMPLE:MyDeadLetterQueue\",\"maxReceiveCount\":\"1000\"}",
        "MessageRetentionPeriod": "259200"
        }
</pre>




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
        localstack_sqs  | 
        localstack_sqs  | LocalStack version: 3.2.0
        localstack_sqs  | LocalStack build date: 2024-02-28
        localstack_sqs  | LocalStack build git hash: 4a4692dd5
        localstack_sqs  | 
        localstack_sqs  | 2024-03-28T09:59:36.175  INFO --- [-functhread4] hypercorn.error            : Running on https://0.0.0.0:4566 (CTRL + C to quit)
        localstack_sqs  | 2024-03-28T09:59:36.175  INFO --- [-functhread4] hypercorn.error            : Running on https://0.0.0.0:4566 (CTRL + C to quit)
        localstack_sqs  | 2024-03-28T09:59:36.433  INFO --- [  MainThread] localstack.utils.bootstrap : Execution of "start_runtime_components" took 606.60ms
        localstack_sqs  | Ready.

</pre>

&nbsp;

Check health:
<div align="center">
    <img src="./gambar-petunjuk/ss_localstack_health.png" alt="ss_localstack_health" style="display: block; margin: 0 auto;">
</div> 

&nbsp;

Open with other terminals.<br />

<pre>
    ❯ docker images --format "{{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}" | grep "localstack"
        localstack/localstack   0.12.14 e28c959c30fd    2021-07-03 03:24:38 +0700 WIB   754MB

    ❯ docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}\t{{.Ports}}"
        CONTAINER ID   IMAGE                           STATUS          NAMES            PORTS
        46fa761e7514   localstack/localstack:0.12.14   Up 37 seconds   localstack_sqs   127.0.0.1:4566->4566/tcp, 5678/tcp, 127.0.0.1:4571->4571/tcp, 8080/tcp
</pre>

&nbsp;

Command into the container.<br />
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

&nbsp;

**&#x2705; Example 1**: create-queue, list-queue, send-message, receive-message, delete-queue.
<pre>
        #########################################################################

        # Example 1 :

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
</pre>
<pre>
        ❯ awslocal sqs send-message --queue-url http://localhost:4566/000000000000/submit_order --message-body "Welcome to SQS queue by Dhony Abu Muhammad"
            {
                "MD5OfMessageBody": "7505439829c760b42b22a2c6a81a3746",
                "MessageId": "9ee99b4a-7204-8a83-e3c5-ae4617b45dcd"
            }        
</pre>
<pre>
        ❯ awslocal sqs receive-message --queue-url http://localhost:4566/000000000000/submit_order
            {
                "Messages": [
                    {
                        "MessageId": "9ee99b4a-7204-8a83-e3c5-ae4617b45dcd",
                        "ReceiptHandle": "qqemtvkidrwumgkpczckyrazordjtcjlqhsgexqsrjzfzhdfeujbuqeaydzsriwlnxufeuedqudaxyhscvqwprpwrqrmjcoptvcdtkdyoexslgoofcurefprsypvjuyjsyymxxzoohvdeiwtkcfmqolzuxkymnzewvmirdjtrzixpkbnzqzzydnbx",
                        "MD5OfBody": "7505439829c760b42b22a2c6a81a3746",
                        "Body": "Welcome to SQS queue by Dhony Abu Muhammad"
                    }
                ]
            }
</pre>
<pre>
        ❯ awslocal sqs delete-queue --queue-url http://localhost:4566/000000000000/submit_order
</pre>

Install jq (a lightweight and flexible command-line JSON processor).<br />
<pre>
        # Install jq
        ❯ apk update && apk add --no-cache jq

            fetch http://dl-cdn.alpinelinux.org/alpine/v3.11/main/x86_64/APKINDEX.tar.gz
            fetch http://dl-cdn.alpinelinux.org/alpine/v3.11/community/x86_64/APKINDEX.tar.gz
            v3.11.13-12-g2cfa91a2b4 [http://dl-cdn.alpinelinux.org/alpine/v3.11/main]
            v3.11.11-124-gf2729ece5a [http://dl-cdn.alpinelinux.org/alpine/v3.11/community]
            OK: 11307 distinct packages available
            fetch http://dl-cdn.alpinelinux.org/alpine/v3.11/main/x86_64/APKINDEX.tar.gz
            fetch http://dl-cdn.alpinelinux.org/alpine/v3.11/community/x86_64/APKINDEX.tar.gz
            (1/2) Installing oniguruma (6.9.4-r1)
            (2/2) Installing jq (1.6-r0)
            Executing busybox-1.31.1-r10.trigger
            OK: 377 MiB in 94 packages        

        ❯ jq --version

            jq-master-v20191114-85-g260888d269
</pre>

&nbsp;

**&#x2705; Example 2**: create-queue, set-queue-attributes, receive-message max-number-of-messages, delete-message, purge-queue
<pre>
        # Example 2 :

        ❯ awslocal sqs create-queue --queue-name test-queue --attributes 
            "ReceiveMessageWaitTimeSeconds=1,
             VisibilityTimeout=20,
             RedrivePolicy.deadLetterTargetArn=$ARN,
             RedrivePolicy.maxReceiveCount=1"

                {
                    "QueueUrl": "http://localhost:4566/000000000000/test-queue"
                }
</pre>
<pre>        
        ❯ ls -lah /home/localstack/ | grep set-queue-attributes.json
            -rw-r--r--    1 root     root         166 Mar 28 02:04 set-queue-attributes.json

        # or set-attributes with a file .json
        ❯ awslocal sqs create-queue --queue-name test-queue
            {
                "QueueUrl": "http://localhost:4566/000000000000/test-queue"
            }        

        ❯ awslocal sqs set-queue-attributes --queue-url http://localhost:4566/000000000000/test-queue --attributes file:///home/localstack/set-queue-attributes.json
</pre>
<pre>
        # continue command
        ❯ awslocal sqs list-queues --queue-name-prefix test
            {
                "QueueUrls": [
                    "http://localhost:4566/000000000000/test-queue"
                ]
            }

        ❯ awslocal sqs get-queue-attributes --queue-url http://localhost:4566/000000000000/test-queue --attribute-names All | jq -r .
            {
                "Attributes": {
                    "ApproximateNumberOfMessages": "0",
                    "ApproximateNumberOfMessagesDelayed": "0",
                    "ApproximateNumberOfMessagesNotVisible": "0",
                    "CreatedTimestamp": "1711589035.023596",
                    "DelaySeconds": "0",
                    "LastModifiedTimestamp": "1711589035.023596",
                    "MaximumMessageSize": "262144",
                    "MessageRetentionPeriod": "345600",
                    "QueueArn": "arn:aws:sqs:us-east-1:000000000000:test-queue",
                    "ReceiveMessageWaitTimeSeconds": "1",
                    "VisibilityTimeout": "20"
                }
            }

        ❯ awslocal sqs list-queues
            {
                "QueueUrls": [
                    "http://localhost:4566/000000000000/test-queue"
                ]
            }
</pre>
<pre>
        ❯ awslocal sqs send-message --queue-url http://localhost:4566/000000000000/test-queue --message-body "Welcome to SQS queue by Dhony Abu Muhammad"
            {
                "MD5OfMessageBody": "7505439829c760b42b22a2c6a81a3746",
                "MessageId": "65f8de23-6a08-8270-99dd-f9edd79a79e6"
            }        

        ❯ awslocal sqs send-message --queue-url http://localhost:4566/000000000000/test-queue --message-body "BMKG | Mag:3.7, 28-Mar-2024 04:03:03WIB, Lok:5.83LS, 112.35BT (123 km TimurLaut TUBAN-JATIM), Kedlmn:10 Km"
            {
                "MD5OfMessageBody": "bb433e30faecdbee39f3ba4a2789a928",
                "MessageId": "d9b80a7b-f5d4-11b5-efad-90977eaf465d"
            }
</pre>
<pre>
        ❯ awslocal sqs receive-message --queue-url http://localhost:4566/000000000000/test-queue --max-number-of-messages 2
            {
                "Messages": [
                    {
                        "MessageId": "65f8de23-6a08-8270-99dd-f9edd79a79e6",
                        "ReceiptHandle": "dywtavvbecbzeoxmxbueqdjwqkzqmnpnommlzbemmzeijrllxawvuhwipgfznqchhmphfvfffyaotilodzumusuqthyhsylggieatqoradulyjtctxipsifwvmrinewebcmvdczwkgnnwikacelqgqumlzgvksdwsxabddijhrnsngdhqmgtxoveh",
                        "MD5OfBody": "7505439829c760b42b22a2c6a81a3746",
                        "Body": "Welcome to SQS queue by Dhony Abu Muhammad"
                    },
                    {
                        "MessageId": "d9b80a7b-f5d4-11b5-efad-90977eaf465d",
                        "ReceiptHandle": "thvdctvafgiddozmaywtsjcbzshejzxipnjoygtxvssasyaisbnywaeezbjguoezpvjkztvmfvtukaebihczuqdvgmtkponvelqrjbfjcsorihafegmazrnbcrprxzojhihujtstrktejshorftlvfrytoesvqeqoqlotxhbtngvwalnwmnrxfaff",
                        "MD5OfBody": "bb433e30faecdbee39f3ba4a2789a928",
                        "Body": "BMKG | Mag:3.7, 28-Mar-2024 04:03:03WIB, Lok:5.83LS, 112.35BT (123 km TimurLaut TUBAN-JATIM), Kedlmn:10 Km"
                    }
                ]
            }
</pre>
Delete a message from the queue.<br />
<pre>
        # awslocal sqs delete-message --queue-url http://localhost:4566/000000000000/test-queue --receipt-handle &lt;receipt-handle&gt;
        ❯ awslocal sqs delete-message --queue-url http://localhost:4566/000000000000/test-queue --receipt-handle "kaiqacmyglqkcccdtqjfygtbcxhhndpmqnvrgdnrrjtueaigbhkcjgarcvncynjljryskepvvhcumbhqxhyuehqowhthjpawsfmtrjabztzssxnecukxudffouqpfnyknsgzitgtgskcmsogcjwxirysbgpuuzkhbispupqpwwfsndrpvcilprzkf"
</pre>
<pre>
        ❯ awslocal sqs receive-message --queue-url http://localhost:4566/000000000000/test-queue --max-number-of-messages 2
        {
            "Messages": [
                {
                    "MessageId": "d9b80a7b-f5d4-11b5-efad-90977eaf465d",
                    "ReceiptHandle": "forhotuvzhddrutxywausgtycpqhazeckvcwgifjdkuywegpwktpyvxcpobtakuhkvmmuyekchkpkbkdnqscykrterkgqmhrfuwhzfjupgvffzjvihjhynbkrihxctbossceppbyuxrogdhengaqkcjpqoliflgzmgkdysqrfcurnrgnyzynfaibe",
                    "MD5OfBody": "bb433e30faecdbee39f3ba4a2789a928",
                    "Body": "BMKG | Mag:3.7, 28-Mar-2024 04:03:03WIB, Lok:5.83LS, 112.35BT (123 km TimurLaut TUBAN-JATIM), Kedlmn:10 Km"
                }
            ]
        }
</pre>
Command to purge the queue.<br />
<pre>
        ❯ awslocal sqs purge-queue --queue-url http://localhost:4566/000000000000/test-queue

        ❯ awslocal sqs receive-message --queue-url http://localhost:4566/000000000000/test-queue --max-number-of-messages 2
</pre>
<pre>
        ❯ awslocal sqs delete-queue --queue-url http://localhost:4566/000000000000/test-queue
        #########################################################################

        ❯ exit
</pre>

&nbsp;

**&#x2705; Example 3**: Dead-letter queue testing

---

<pre>
        ❯ echo "########### Setting up localstack profile ###########"
        ❯ aws configure set aws_access_key_id access_key --profile=localstack
        ❯ aws configure set aws_secret_access_key secret_key --profile=localstack
        ❯ aws configure set region sa-east-1 --profile=localstack
        ❯ aws configure set default.region sa-east-1

        ❯ export SOURCE_SQS=source-sqs
        ❯ export DLQ_SQS=dlq-sqs

        ❯ awslocal sqs create-queue --queue-name $DLQ_SQS
            {
                "QueueUrl": "http://localhost:4566/000000000000/dlq-sqs"
            }

        ❯ echo "########### ARN for DLQ ###########"
        ❯ DLQ_SQS_ARN=$(awslocal sqs get-queue-attributes\
                        --attribute-name QueueArn --queue-url=http://localhost:4566/000000000000/"$DLQ_SQS"\
                        |  sed 's/"QueueArn"/\n"QueueArn"/g' | grep '"QueueArn"' | awk -F '"QueueArn":' '{print $2}' | tr -d '"' | xargs)
        
        ❯ echo $DLQ_SQS_ARN
            arn:aws:sqs:us-east-1:000000000000:dlq-sqs


        ❯ awslocal --profile=localstack sqs create-queue --queue-name $SOURCE_SQS \
            --attributes '{
                "RedrivePolicy": "{\"deadLetterTargetArn\":\"'"$DLQ_SQS_ARN"'\",\"maxReceiveCount\":\"2\"}",
                "VisibilityTimeout": "10"
            }'
        {
            "QueueUrl": "http://localhost:4566/000000000000/source-sqs"
        }

        ❯ echo "########### Listing queues ###########"
        ❯ awslocal sqs list-queues
        {
            "QueueUrls": [
                "http://localhost:4566/000000000000/dlq-sqs",
                "http://localhost:4566/000000000000/source-sqs"
            ]
        }

        ❯ echo "########### Listing Source SQS Attributes ###########"
        ❯ awslocal sqs get-queue-attributes \
            --attribute-name All --queue-url=http://localhost:4566/000000000000/"$SOURCE_SQS"       
        {
            "Attributes": {
                "ApproximateNumberOfMessages": "0",
                "ApproximateNumberOfMessagesDelayed": "0",
                "ApproximateNumberOfMessagesNotVisible": "0",
                "CreatedTimestamp": "1711607676.183656",
                "DelaySeconds": "0",
                "LastModifiedTimestamp": "1711607676.183656",
                "MaximumMessageSize": "262144",
                "MessageRetentionPeriod": "345600",
                "QueueArn": "arn:aws:sqs:us-east-1:000000000000:source-sqs",
                "RedrivePolicy": "{\"deadLetterTargetArn\":\"arn:aws:sqs:us-east-1:000000000000:dlq-sqs\",\"maxReceiveCount\":2}",
                "ReceiveMessageWaitTimeSeconds": "0",
                "VisibilityTimeout": "10"
            }
        } 

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        #Put message to Source SQS
        ❯ awslocal sqs send-message --queue-url=http://localhost:4566/000000000000/source-sqs --message-body="BMKG | Mag:3.7, 28-Mar-2024 04:03:03WIB, Lok:5.83LS, 112.35BT (123 km TimurLaut TUBAN-JATIM), Kedlmn:10 Km"
            {
                "MD5OfMessageBody": "bb433e30faecdbee39f3ba4a2789a928",
                "MessageId": "5cf62b6c-aedd-461d-3b46-c3e4bca66aa0"
            }

        #Receive message from Source SQS
        ❯ awslocal sqs receive-message --queue-url=http://localhost:4566/000000000000/source-sqs
            {
                "Messages": [
                    {
                        "MessageId": "5cf62b6c-aedd-461d-3b46-c3e4bca66aa0",
                        "ReceiptHandle": "cnbjndbmvmesqxthhvdannmntjfzvqplqpitmmairnlcemffrzwhnmbpgfbsbfjexucaudbjsbcavkoctrtlxshmpokvnambiwdnzmbmzjuemsbxdmcluxydpfbwsctfciltmxysgqwramfimocaanvcrxqfmmqvwmuhxwkytphlojikyycflimhu",
                        "MD5OfBody": "bb433e30faecdbee39f3ba4a2789a928",
                        "Body": "BMKG | Mag:3.7, 28-Mar-2024 04:03:03WIB, Lok:5.83LS, 112.35BT (123 km TimurLaut TUBAN-JATIM), Kedlmn:10 Km"
                    }
                ]
            }

        #Receive message from DLQ SQS
        ❯ awslocal sqs receive-message --queue-url=http://localhost:4566/000000000000/dlq-sqs     
            &lt;nothing&gt;
</pre>

---

&nbsp;

Note : To delete all existing queues in the default profile.
<pre>
        ❯ /bin/sh /home/localstack/delete_all_queues_awslocal.sh 
</pre>

&nbsp;

Configure dead-letter-queue to be a DLQ for input-queue:
<pre>
           ❯ aws configure set default.region ap-southeast-3
           ❯ aws configure list
                    Name                    Value             Type    Location
                    ----                    -----             ----    --------
                profile                   <not set>             None    None
                access_key                <not set>             None    None
                secret_key                <not set>             None    None
                    region           ap-southeast-3              env    AWS_DEFAULT_REGION
</pre>
<pre>
            ❯ awslocal sqs create-queue --queue-name dead-letter-queue
                    {
                        "QueueUrl": "http://localhost:4566/000000000000/dead-letter-queue"
                    }
</pre>
<pre>
            ❯ DLQ_SQS_ARN=$(awslocal sqs get-queue-attributes --attribute-name QueueArn --queue-url=http://localhost:4566/000000000000/dead-letter-queue\
                    |  sed 's/"QueueArn"/\n"QueueArn"/g' | grep '"QueueArn"' | awk -F '"QueueArn":' '{print $2}' | tr -d '"' | xargs)

            ❯ echo $DLQ_SQS_ARN
                    arn:aws:sqs:us-east-1:000000000000:dead-letter-queue
</pre>
<pre>
            ❯ awslocal sqs create-queue --queue-name input-queue \
                --attributes '{ "RedrivePolicy": "{\"deadLetterTargetArn\":\"'"$DLQ_SQS_ARN"'\",\"maxReceiveCount\":\"2\"}" }'
                    {
                        "QueueUrl": "http://localhost:4566/000000000000/input-queue"
                    }
</pre>
<pre>
            ❯ awslocal sqs get-queue-attributes --attribute-name All --queue-url=http://localhost:4566/000000000000/input-queue
                    {
                        "Attributes": {
                            "ApproximateNumberOfMessages": "0",
                            "ApproximateNumberOfMessagesDelayed": "0",
                            "ApproximateNumberOfMessagesNotVisible": "0",
                            "CreatedTimestamp": "1711612966.648888",
                            "DelaySeconds": "0",
                            "LastModifiedTimestamp": "1711612966.648888",
                            "MaximumMessageSize": "262144",
                            "MessageRetentionPeriod": "345600",
                            "QueueArn": "arn:aws:sqs:us-east-1:000000000000:input-queue",
                            "RedrivePolicy": "{\"deadLetterTargetArn\":\"arn:aws:sqs:us-east-1:000000000000:dead-letter-queue\",\"maxReceiveCount\":2}",
                            "ReceiveMessageWaitTimeSeconds": "0",
                            "VisibilityTimeout": "30"
                        }
                    }            
</pre>
<pre>
            ❯ awslocal sqs send-message --queue-url http://localhost:4566/000000000000/input-queue --message-body '{"hello": "world"}'
                    {
                        "MD5OfMessageBody": "49dfdd54b01cbcd2d2ab5e9e5ee6b9b9",
                        "MessageId": "40cb2a7c-80d9-5eac-f375-844b060807f2"
                    }
</pre>
<pre>
            ❯ awslocal sqs receive-message --visibility-timeout 0 --queue-url http://localhost:4566/000000000000/input-queue
                    {
                        "Messages": [
                            {
                                "MessageId": "40cb2a7c-80d9-5eac-f375-844b060807f2",
                                "ReceiptHandle": "vvyvgbxviazkxfaxtqgmagjchlpsljasabrxserqvwqxygzlvpcfhnfbcrwfqolhudzbrlhljxwjippcpehwimjjoruvdrkdunqkraxgdueesjdhsgpcpmuhwyllplfpjednmwhjadmkzjsvyxoawcryusnrwwkdhneejalaohpxmjxfzwacfovrg",
                                "MD5OfBody": "49dfdd54b01cbcd2d2ab5e9e5ee6b9b9",
                                "Body": "{\"hello\": \"world\"}"
                            }
                        ]
                    }

            ❯ awslocal sqs receive-message --visibility-timeout 0 --queue-url http://localhost:4566/000000000000/input-queue 
                    {
                        "Messages": [
                            {
                                "MessageId": "40cb2a7c-80d9-5eac-f375-844b060807f2",
                                "ReceiptHandle": "dagfmqjafpmcnvpackpjivprsarlvcjnbwykwbqfohfjhqvgcytdyszforbnztumzuhjjqghxzdpjaujeyfigvrggbyznjgrdtieesgrzcbpdlqiupjynxibzyqoxshmkjeepdsxxduxiclesqbhgzeuzaxpegndtazssusoqbwsptsdkbmjowtsf",
                                "MD5OfBody": "49dfdd54b01cbcd2d2ab5e9e5ee6b9b9",
                                "Body": "{\"hello\": \"world\"}"
                            }
                        ]
                    }

            ❯ awslocal sqs receive-message --visibility-timeout 0 --queue-url http://localhost:4566/000000000000/input-queue 
                &lt;nothing&gt;
</pre>

&nbsp;

<pre>
            # Check pada DLQ
            ❯ awslocal sqs receive-message --queue-url http://localhost:4566/000000000000/dead-letter-queue --max-number-of-messages 10
                    {
                        "Messages": [
                            {
                                "MessageId": "40cb2a7c-80d9-5eac-f375-844b060807f2",
                                "ReceiptHandle": "eaerqhzrodpozktvbumindshwcleyqeortgohonhppowmpgmnkutaerilwdknabxbqyixjoujlxmenjcypmffkmzouqswzjuttfwbxdnuweatlnhuioweztyyiuqdiztvdgwvtogmsoqqpswjhbavqijdgrgpwtplvypkktyrqwehiqfiudbuemzy",
                                "MD5OfBody": "49dfdd54b01cbcd2d2ab5e9e5ee6b9b9",
                                "Body": "{\"hello\": \"world\"}"
                            },
                            {
                                "MessageId": "9943070c-354c-58d6-3ae1-4252e00a902c",
                                "ReceiptHandle": "wectrhnzqabitzfpytoifjhsquwrqrdozmwdswmsgxcxuxnogigisinkyxhpaorvfqymphdxkkopsvmahctcjaqioialwryavwsddfuvpiybfapkdqmnxrtocvbmcmysxaegtzohgguhzwmteaaxjzjnfakafmwhdloagjrateffphccbsbpoprni",
                                "MD5OfBody": "0237ca22b5fecd42206e72dd72f5bc47",
                                "Body": "{\"event\": \"purchase\", \"user_id\": 123, \"timestamp\": \"2024-03-28T12:00:00\"}"
                            },
                            {
                                "MessageId": "97907360-0880-fe16-2204-5a87c728f80c",
                                "ReceiptHandle": "qrfbytupwtnlnhqwbxvzlvwpszyydgeiyjvcrtpgitwdnooogfhwfllobbysvjdzymwtfepkhskywbqgfzdwphymqypsovohhftyiqtkswmycbppufiazeggbzmxbyrygankuwispfzbkvjpdktkzvifqqtqpagoglcomitvzgjjyspemtpsmeipi",
                                "MD5OfBody": "49dfdd54b01cbcd2d2ab5e9e5ee6b9b9",
                                "Body": "{\"hello\": \"world\"}"
                            }
                        ]
                    }
</pre>

&nbsp;

<pre>
            ❯ awslocal sqs start-message-move-task \
                    --source-arn arn:aws:sqs:us-east-1:000000000000:dead-letter-queue \
                    --destination-arn arn:aws:sqs:us-east-1:000000000000:recovery-queue

            ❯ awslocal sqs receive-message --queue-url http://localhost:4566/000000000000/recovery-queue

            aws sqs move-message --source-queue-url rn:aws:sqs:us-east-1:000000000000:dead-letter-queue --queue-url arn:aws:sqs:us-east-1:000000000000:recovery-queue --receipt-handle "vvyvgbxviazkxfaxtqgmagjchlpsljasabrxserqvwqxygzlvpcfhnfbcrwfqolhudzbrlhljxwjippcpehwimjjoruvdrkdunqkraxgdueesjdhsgpcpmuhwyllplfpjednmwhjadmkzjsvyxoawcryusnrwwkdhneejalaohpxmjxfzwacfovrg"

</pre>

&nbsp;

&nbsp;

&nbsp;

### &#x1F530; command used outside the container:

<pre>
❯ aws --endpoint-url=http://localhost:4566 sqs list-queues --queue-name-prefix submit
    {
        "QueueUrls": [
            "http://localhost:4566/000000000000/submit_order"
        ]
    } 

❯ aws --endpoint-url=http://localhost:4566 sqs send-message --queue-url http://localhost:4566/000000000000/submit_order --message-body "Welcome to SQS queue by Dhony Abu Muhammad"
    {
        "MD5OfMessageBody": "7505439829c760b42b22a2c6a81a3746",
        "MessageId": "6483c5e2-71ce-1845-de5d-6dd7aa41807a"
    }

❯ aws --endpoint-url=http://localhost:4566 sqs receive-message --queue-url http://localhost:4566/000000000000/submit_order
    {
        "Messages": [
            {
                "MessageId": "9ee99b4a-7204-8a83-e3c5-ae4617b45dcd",
                "ReceiptHandle": "kevpbdhhkwpmaptwjvzktnbszkhluxxbrvcsvqzdruofmapwvocjybtzaorqmulumewwiaprsxgawbcqkqdlvhoctspfdqyncqwtizbzmsrfwrthrvcwxgsspgbkmletyfvufcgexukptirfussliwpmsrkjpssujkvzfzzycryxhqkfrexhgxtvo",
                "MD5OfBody": "7505439829c760b42b22a2c6a81a3746",
                "Body": "Welcome to SQS queue by Dhony Abu Muhammad"
            }
        ]
    }
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