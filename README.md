# Bricklink PowerShell Module

The Bricklink PowerShell Module provides a suite of tools for interacting with the Bricklink API, enabling automation and management of Bricklink resources such as inventory, wanted lists, and order management.

## Prerequisites

Before using this module, you must have:

- PowerShell 7 or later installed on your system.
- A Bricklink account to access the Bricklink API.
- Additionally, you need to obtain API keys from Bricklink by registering your application in the Bricklink API Developer website. The following API credentials are required:

  - Consumer Key
  - Consumer Secret
  - Token Value
  - Token Secret

## Initial Setup

- Clone the repository from GitHub or install the module from the PowerShell Gallery by running `Install-Module Bricklink`.
- Copy the configuration.example.json file to configuration.json and fill in your Bricklink API keys and other relevant information.
- Load the module with Import-Module ./Bricklink (adjust the path according to where you placed the module).

## Configuring Authentication

The Bricklink module communicates with Bricklink in two different ways; via the API and also via the web for wanted list management.

To use any function that depends on the API which is all functions _not_ related to wanted lists, you must use the Save-BricklinkConfiguration command to save your initial API information securely by running the following commands in PowerShell, replacing <value> with your actual API credentials:

```
Save-BricklinkConfiguration -Name "ConsumerKey" -Value "<your_consumer_key>"
Save-BricklinkConfiguration -Name "ConsumerSecret" -Value "<your_consumer_secret>"
Save-BricklinkConfiguration -Name "TokenValue" -Value "<your_token_value>"
Save-BricklinkConfiguration -Name "TokenSecret" -Value "<your_token_secret>"
```

To work with wanted lists, you must also provide your Bricklink store username and password.

```
Save-BricklinkConfiguration -Name "username" -Value "<username>"
Save-BricklinkConfiguration -Name "password" -Value "<password>"
```

This information is stored securely and is used by the module to authenticate your API requests.

## Getting Started

After the initial setup and configuration, you can begin using the module to interact with the Bricklink API. Here are a few examples of what you can do:

- Get a list of categories: Get-CategoryList
- Add an item to a wanted list: Add-WantedListItem -WantedListId <id> -ItemNo "<item_no>" -Qty <quantity> -ColorId <color_id>
- Get price guide information for an item: Get-PriceGuide -Type "<type>" -No "<no>" -NewOrUsed "N" -GuideType "sold" -CountryCode "US"

For detailed information on each cmdlet and its parameters, refer to the cmdlet help within PowerShell.

## Contributing

Contributions to the Bricklink PowerShell Module are welcome! Please submit pull requests or issues through GitHub.