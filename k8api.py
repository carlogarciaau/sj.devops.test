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

