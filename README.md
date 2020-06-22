# sj.devops.test

### 1. Based on the above resources, the deployment will create a pod with a memory resource request and limit of 2Gi. Tell us what you think about the allocated resources and describe, in your own words, your understanding of these parameters.
*Requests is the minimum amount of resources Kubernetes guarantees the pod to get. Kubernetes also allows bursts of additional resources when required, and limits help to cap that.*

<br/>

### 2. The dockerfile and the hello-world-deploy.yaml have a few issues Please try to identify a few things that could be optimised or fixed.
*The list of issues I fixed were:*
- missing selector
- added port name
- parameterize heap size in Dockerfile
- fixed the liveness/readiness probe path to root / as /health doesn't exist
- reduced readiness probe wait time
- added configMap as volume mount
- heap size and requests/limits tuning

<br/>

### 3. Every time the developer of hello-world wants more memory, they have to simultaneously increase the Docker memory parameters with the devops team modifying the hello-world-deploy.yaml. Why do they need to do that simultaneously? What problem could appear if the memory value is modified in only one of those two files above? Can you think of a way to automate that process? (Please provide an updated Dockerfile / deployment yaml file as an answer). 
*If the app increased its memory parameters without the deployment yaml being updated accordingly, we run the risk of the app encountering OOM exceptions as the container does not have enough resources to accomodate the heap size requirements.*<br/>
*For this exercise, I've parameterized xms/xmx in the Dockerfile and requests/limits in the deployment yaml manifest file, and have the `set_heap_size.sh` script perform the build and deployment.*<br/>
*In practice, a CI/CD pipeline will manage the build and deployment and a tool like Helm can be useful at managing and templating K8s resources.* 

<br/>

### 4. You now have an updated docker file and yaml deploy file. Please share the updated files with all the optimisations that you thought of. Considering the nature of this service (helloworld app), please comment on the amount of resources you've assigned to run this application and the cost optimisation aspect of it.
*The heap size of 12g was too much for the hello world app. I threw it 20 requests per second and monitored using docker stats, it seemed to settle with a memory utilisation between 180m and 200m. I suggest to set the heap size at a starting point of 256m and request/limit to 512Mi. Scaling can be better done horizontally using a HPA.*

<br/>

### 5. Having over over 70 services per namespace (environment) running in kubernetes pods, each of them has a unique configuration. Some of that configuration contains values that are shared between services and any mis-configured service will cause a wide range of issues not so easy to track down. (ie. wrong shared database credentials). What would you put in place to verify configurations and avoid issues when deploying new services? Please describe the system you would put in place to keep all those configuration updated instead of updating the same value for all 70 services when you need to make a change
*I would separate management of app specific configuration and shared configuration. Any app specific configuration can remain coupled with the app while shared configuration must be managed separately, ideally in its own repository and pipeline. ConfigMaps are very useful for this. ConfigMaps can be shared across multiple pods and you only have to update that ConfigMap to push out the changes. Depending on the version/flavor of K8s, you may have to do a rolling restart of every service/pods. Secrets are similarly useful for critical/sensitive data.*

<br/>

### 6. Please share a snippet in the language of your choice leveraging kubernetes API to create/update a configmap from a config file.

*I would say kubectl does the job and just invoke it from your script.*
```
# To create a new configMap:
kubectl create configmap hello-world-config --from-file application.properties

# To update an existing configMap:
kubectl create configmap hello-world-config --from-file application.properties -o yaml --dry-run=client | kubectl replace -f -
```

*If the requirement is to leverage the API on your own code, this is how I'd do it in Python:*
```
from kubernetes import client, config

config.load_kube_config()
api = client.CoreV1Api()

def read_config_file(file):
  myvars = {}
  with open(file) as myfile:
    for line in myfile:
      name, var = line.partition("=")[::2]
      myvars[name.strip()] = var.strip()
  return myvars

def configmap_create(data, name, namespace="default"):
  cm = client.V1ConfigMap()
  cm.metadata = client.V1ObjectMeta(name=name)
  cm.data = data
  api.create_namespaced_config_map(namespace=namespace, body=cm)

def configmap_update(data, name, namespace="default"):
  cm = client.V1ConfigMap()
  cm.data = data
  api.patch_namespaced_config_map(name=name, namespace=namespace, body=cm)

def main():
  data = read_config_file("application.properties")
  
  # create config map
  configmap_create(data, "api-configmap")

  # update config map
  configmap_update(data, "api-configmap")

if __name__ == "__main__":
  main()
```