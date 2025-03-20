rgname                 = "stage-pilotgab-rg"
service_principal_name = "stage-pilotgab-spn"
keyvault_name          = "stage-pilotgab-kv-101"
SUB_ID = "2fdeef7a-f11a-4a4e-8db7-b318d3f3d86a"
node_pool_name = "stagenp"
cluster_name = "stage-pilotgab-cluster"


address_space        = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.0.0/21", "10.0.8.0/21"]
private_subnet_cidrs = ["10.0.16.0/21", "10.0.24.0/21"]
name                 = "pilotgab"
