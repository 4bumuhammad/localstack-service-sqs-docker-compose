#!/bin/bash

queues=$(awslocal sqs list-queues --output text --query 'QueueUrls')

for queue_url in $queues
do
    awslocal sqs delete-queue --queue-url $queue_url
done