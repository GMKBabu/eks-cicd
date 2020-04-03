#!/bin/bash
/root/bin/kubectl get ingress -n babu |grep ingress | awk '{print $3}'