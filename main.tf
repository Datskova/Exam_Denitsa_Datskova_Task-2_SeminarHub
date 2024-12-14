# код от create resourse group terraform, use provider

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.13.0"
    }
  }
}

# добавяне на Subscription ID -> получаваме ID-то след като сме се логнали в azure с az login
provider "azurerm" {
  subscription_id = "6235a27e-8322-4554-924a-cc1f638c4a0f"
  features {

  }
}
# изпълняваме terraform fmt + terraform init


# създаване на самата ресурсна група с код от terraform create_resource_group
resource "azurerm_resource_group" "azurerg" {
  name     = "BazarRGDeni"
# name = var.resource_group_name  
  location = "North Europe"
# name = var.resource_group_location 
}

# създаване на plan с код от terraform azurerm_service_plan и azurerm_linux_web_app
resource "azurerm_service_plan" "azuresp" {
  name                = "BazarServicePlan"
# name = var.app_service_plan_name 
  resource_group_name = azurerm_resource_group.azurerg.name
  location            = azurerm_resource_group.azurerg.location
  os_type             = "Linux"
  sku_name            = "F1" # е нашият базов ресурс, взет е от упражнение 8, зад.2
}

resource "azurerm_linux_web_app" "azurewebapp" {
  name                = "BazarAppDeni"
# name = var.app_service_name 
  resource_group_name = azurerm_resource_group.azurerg.name
  location            = azurerm_resource_group.azurerg.location
  service_plan_id     = azurerm_service_plan.azuresp.id

  site_config { # тук се поставя връзката към базата данни
    application_stack {
      dotnet_version = "6.0" # търсим ги от репото, в папка SoftUniBazar/SoftUniBazar.csproj -> <TargetFramework>net6.0</TargetFramework>
    }
    always_on = false
  }
  connection_string {           # търсим ги от репото, в папка SoftUniBazar/appsetings.json 
    name  = "DefaultConnection" # от "ConnectionString"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.azuresql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.azuredb.name};User ID=${azurerm_mssql_server.azuresql.administrator_login};Password=${azurerm_mssql_server.azuresql.administrator_login_password};Trusted_Connection=False;MultipleActiveResultSets=True;"
  } # Data Source се попълва с имената на server-a "azuresql" и database-a "azuredb"
}

# създаване на server and database с код от terraform zaurerm_mssql_server and zaurerm_mssql_database
resource "azurerm_mssql_server" "azuresql" {
  name                         = "bazardenisqlserver"
# name = var.sql_server_name 
  resource_group_name          = azurerm_resource_group.azurerg.name
  location                     = azurerm_resource_group.azurerg.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
# name = var.sql_user 
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
# name = var.sql_user_pass 
}

resource "azurerm_mssql_database" "azuredb" {
  name           = "bazardenidb"
# name = var.sql_database_name 
  server_id      = azurerm_mssql_server.azuresql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  zone_redundant = false
  sku_name       = "S0"

}
# изпълняваме terraform fmt + terraform validate


# създаване на firewall_rule с код от terraform azurerm_mssql_firewall_rule
resource "azurerm_mssql_firewall_rule" "azurefirewall" {
  name             = "FirewallRule1Deni"
# name = var.firewall_rule_name 
  server_id        = azurerm_mssql_server.azuresql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# създаване на source_control с код от terraform azurerm_app_service_source_control
resource "azurerm_app_service_source_control" "github" {
  app_id                 = azurerm_linux_web_app.azurewebapp.id
  repo_url               = "https://github.com/Datskova/exam-2-preparation-SofUniBazar"
# name = var.github_repo 
  branch                 = "main"
  use_manual_integration = true
}
# изпълняваме terraform fmt + terraform validate
