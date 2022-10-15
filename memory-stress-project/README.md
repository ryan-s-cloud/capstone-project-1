# Memory stress application {#memory-stress-application .list-paragraph}

**memory-stress.c** is the source code of a C application that allocates
memory in a loop. This app is used to trigger the horizontal scaling of
the DB portion of the k8s application based on memory.

**Compiling:**

Execute the build.sh script:

sh build.sh

**Triggering the memory HA:**

1.  Copy the utility to the DB pod:

kubectl cp \~/memory-stress
capstone-project1/vehicle-quotes-db-76f6f646c5-67lrt:/tmp

2.  Interact with the pod:

kubectl exec -it -n capstone-project1
pods/vehicle-quotes-web-857885f566-52cl2 -- bash

3.  Execute:

cd /tmp

./memory-stress \> /dev/null&

./memory-stress \> /dev/null&

./memory-stress \> /dev/null&

./memory-stress \> /dev/null&

./memory-stress \> /dev/null&

./memory-stress \> /dev/null&
