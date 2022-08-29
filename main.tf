# module "dev_cluster" {
#     source     = "./main"
#     env_name   = "dev"
# }

module "staging_cluster" {
    source     = "./main"
    env_name   = "staging"
}

# module "prod_cluster" {
#     source     = "./main"
#     env_name   = "prod"
# }