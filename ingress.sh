#!/bin/bash
host_url = `/root/bin/kubectl get ingress -n babu |grep ingress | awk '{print $3}'`