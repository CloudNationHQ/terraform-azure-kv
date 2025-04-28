# Changelog

## [3.2.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v3.1.0...v3.2.0) (2025-04-28)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#95](https://github.com/CloudNationHQ/terraform-azure-kv/issues/95)) ([442bc14](https://github.com/CloudNationHQ/terraform-azure-kv/commit/442bc143002d565405aad9d94189c6c97d6bcf50))
* **deps:** bump golang.org/x/crypto from 0.31.0 to 0.35.0 in /tests ([#101](https://github.com/CloudNationHQ/terraform-azure-kv/issues/101)) ([5280a8d](https://github.com/CloudNationHQ/terraform-azure-kv/commit/5280a8d7711154567a16896680b7868ea0e11716))
* **deps:** bump golang.org/x/net from 0.33.0 to 0.38.0 in /tests ([#102](https://github.com/CloudNationHQ/terraform-azure-kv/issues/102)) ([3e5687d](https://github.com/CloudNationHQ/terraform-azure-kv/commit/3e5687d6d7d392273a37c7d0d1922adaa47fbe7a))

## [3.1.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v3.0.1...v3.1.0) (2025-01-20)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#78](https://github.com/CloudNationHQ/terraform-azure-kv/issues/78)) ([e0140c7](https://github.com/CloudNationHQ/terraform-azure-kv/commit/e0140c7cb8223f254fa04faff7e33224d4dc77f6))
* **deps:** bump golang.org/x/crypto from 0.29.0 to 0.31.0 in /tests ([#80](https://github.com/CloudNationHQ/terraform-azure-kv/issues/80)) ([2f39fd8](https://github.com/CloudNationHQ/terraform-azure-kv/commit/2f39fd811eb7438e28e4497947cd49cb1fe55246))
* **deps:** bump golang.org/x/net from 0.31.0 to 0.33.0 in /tests ([#81](https://github.com/CloudNationHQ/terraform-azure-kv/issues/81)) ([4b72458](https://github.com/CloudNationHQ/terraform-azure-kv/commit/4b724587d389cbe8e4621c19cae2795974f627db))

## [3.0.1](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v3.0.0...v3.0.1) (2024-12-06)


### Bug Fixes

* fix typos usages ([#75](https://github.com/CloudNationHQ/terraform-azure-kv/issues/75)) ([978a73b](https://github.com/CloudNationHQ/terraform-azure-kv/commit/978a73b6fd6d6b0185187bc916492e1cb779d6f2))

## [3.0.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v2.2.1...v3.0.0) (2024-12-04)


### ⚠ BREAKING CHANGES

* keys of the secrets changed, which will cause a replacement.

### Features

* small refactor ([#73](https://github.com/CloudNationHQ/terraform-azure-kv/issues/73)) ([bc168d9](https://github.com/CloudNationHQ/terraform-azure-kv/commit/bc168d93f3971000874791abab59e43d3b1d331f))

### Upgrade from v2.2.1 to v3.0.0:

- Update module reference to: `version = "~> 3.0"`

## [2.2.1](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v2.2.0...v2.2.1) (2024-11-12)


### Bug Fixes

* increment private dns module usage ([#71](https://github.com/CloudNationHQ/terraform-azure-kv/issues/71)) ([a4a7211](https://github.com/CloudNationHQ/terraform-azure-kv/commit/a4a7211823956e6571ed0a9d21b96c78413fe369))

## [2.2.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v2.1.0...v2.2.0) (2024-11-11)


### Features

* enhance testing with sequential, parallel modes and flags for exceptions and skip-destroy ([#69](https://github.com/CloudNationHQ/terraform-azure-kv/issues/69)) ([425e3cd](https://github.com/CloudNationHQ/terraform-azure-kv/commit/425e3cd5b3713ff1ea23ea5896570b8b01482460))

## [2.1.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v2.0.0...v2.1.0) (2024-10-11)


### Features

* auto generated docs and refine makefile ([#67](https://github.com/CloudNationHQ/terraform-azure-kv/issues/67)) ([8dd4030](https://github.com/CloudNationHQ/terraform-azure-kv/commit/8dd40302737c19da3d9b92b58bbdcaa3a1ab3a60))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#66](https://github.com/CloudNationHQ/terraform-azure-kv/issues/66)) ([5bdfbe3](https://github.com/CloudNationHQ/terraform-azure-kv/commit/5bdfbe37bcb4d30897ec0d7e266c4ff33c698f84))

## [2.0.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v1.1.0...v2.0.0) (2024-09-24)


### ⚠ BREAKING CHANGES

* Version 4 of the azurerm provider includes breaking changes.

### Features

* upgrade azurerm provider to v4 ([#64](https://github.com/CloudNationHQ/terraform-azure-kv/issues/64)) ([24bc2c1](https://github.com/CloudNationHQ/terraform-azure-kv/commit/24bc2c11f2e71c69f245be871b4071bab01d1dd3))

### Upgrade from v1.1.0 to v2.0.0:

- Update module reference to: `version = "~> 2.0"`

## [1.1.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v1.0.0...v1.1.0) (2024-09-24)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#62](https://github.com/CloudNationHQ/terraform-azure-kv/issues/62)) ([7be2e25](https://github.com/CloudNationHQ/terraform-azure-kv/commit/7be2e25af763d32051232c5a867d63a39804f996))

## [1.0.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v0.14.0...v1.0.0) (2024-08-15)


### ⚠ BREAKING CHANGES

* data structure has changed due to renaming of properties and output variables.

### Features

* aligned several properties ([#60](https://github.com/CloudNationHQ/terraform-azure-kv/issues/60)) ([17499ee](https://github.com/CloudNationHQ/terraform-azure-kv/commit/17499ee05026d38d943b7e65868adc7db72f2d34))

### Upgrade from v0.14.0 to v1.0.0:

- Update module reference to: `version = "~> 1.0"`
- Rename properties in vault object:
  - resourcegroup -> resource_group
  - sku -> sku_name
- Rename variable:
  - resourcegroup -> resource_group
- Rename output variable:
  - subscriptionId -> subscription_id'

## [0.14.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v0.13.0...v0.14.0) (2024-08-13)


### Features

* added code of conduct and security documentation ([#57](https://github.com/CloudNationHQ/terraform-azure-kv/issues/57)) ([1895413](https://github.com/CloudNationHQ/terraform-azure-kv/commit/1895413641bbaf9b13084797c5174ba47e895375))

## [0.13.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v0.12.0...v0.13.0) (2024-08-13)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#56](https://github.com/CloudNationHQ/terraform-azure-kv/issues/56)) ([3826ce2](https://github.com/CloudNationHQ/terraform-azure-kv/commit/3826ce221af9d4d5c8df8d9a05c7270a1a49eeab))
* update contribution docs ([#54](https://github.com/CloudNationHQ/terraform-azure-kv/issues/54)) ([b06196d](https://github.com/CloudNationHQ/terraform-azure-kv/commit/b06196d4d89cc64e24d6339668d9a00ef9572530))

## [0.12.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v0.11.0...v0.12.0) (2024-07-02)


### Features

* update version of random & tls providers ([#50](https://github.com/CloudNationHQ/terraform-azure-kv/issues/50)) ([c03a62d](https://github.com/CloudNationHQ/terraform-azure-kv/commit/c03a62d385b2b16432cebdbec1de1d8e54ce927b))

## [0.11.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v0.10.0...v0.11.0) (2024-07-02)


### Features

* add issue template ([#48](https://github.com/CloudNationHQ/terraform-azure-kv/issues/48)) ([d413469](https://github.com/CloudNationHQ/terraform-azure-kv/commit/d413469ad6b197afe2b83236f4c8a0cdf869afec))
* **deps:** bump github.com/Azure/azure-sdk-for-go/sdk/azidentity ([#44](https://github.com/CloudNationHQ/terraform-azure-kv/issues/44)) ([f77b159](https://github.com/CloudNationHQ/terraform-azure-kv/commit/f77b159636481ff1fb13303973ee4d38e484f321))
* **deps:** bump github.com/Azure/azure-sdk-for-go/sdk/azidentity ([#45](https://github.com/CloudNationHQ/terraform-azure-kv/issues/45)) ([204c4e6](https://github.com/CloudNationHQ/terraform-azure-kv/commit/204c4e60b5ac0f0f81d32ba935d9d818e75f6d39))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#47](https://github.com/CloudNationHQ/terraform-azure-kv/issues/47)) ([39a428b](https://github.com/CloudNationHQ/terraform-azure-kv/commit/39a428bca29bc814430260aeb487dcb176b2cbb2))

## [0.10.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v0.9.1...v0.10.0) (2024-06-07)


### Features

* add pull request template ([#42](https://github.com/CloudNationHQ/terraform-azure-kv/issues/42)) ([ffa6f87](https://github.com/CloudNationHQ/terraform-azure-kv/commit/ffa6f871b7eb010f018df39053fc16bfe2a9c5de))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#41](https://github.com/CloudNationHQ/terraform-azure-kv/issues/41)) ([fb2a72b](https://github.com/CloudNationHQ/terraform-azure-kv/commit/fb2a72b518a604e152c6b9d9777e4c9a02303f5e))

## [0.9.1](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v0.9.0...v0.9.1) (2024-05-03)


### Bug Fixes

* small fix to skip tls keys ([#39](https://github.com/CloudNationHQ/terraform-azure-kv/issues/39)) ([b4b0f7a](https://github.com/CloudNationHQ/terraform-azure-kv/commit/b4b0f7a77dfaf2f6ec06bddc45db9623eb64012e))

## [0.9.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v0.8.0...v0.9.0) (2024-04-29)


### Features

* add support for non randomly generated secrets ([#34](https://github.com/CloudNationHQ/terraform-azure-kv/issues/34)) ([891aa3a](https://github.com/CloudNationHQ/terraform-azure-kv/commit/891aa3a30cd9a3d499761e11afe33f980b7e472f))
* **deps:** bump github.com/Azure/azure-sdk-for-go/sdk/azidentity ([#32](https://github.com/CloudNationHQ/terraform-azure-kv/issues/32)) ([78ce5a8](https://github.com/CloudNationHQ/terraform-azure-kv/commit/78ce5a8b18725e5d147c5c2f6991372baa9dfb5a))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#37](https://github.com/CloudNationHQ/terraform-azure-kv/issues/37)) ([1cc4c34](https://github.com/CloudNationHQ/terraform-azure-kv/commit/1cc4c344c75718ae136ff10ec3f6fe69df391000))
* **deps:** bump github.com/hashicorp/go-getter in /tests ([#36](https://github.com/CloudNationHQ/terraform-azure-kv/issues/36)) ([b4c79c1](https://github.com/CloudNationHQ/terraform-azure-kv/commit/b4c79c1a7aafb921688c14366e1d471d4ce732ed))
* **deps:** bump golang.org/x/net from 0.19.0 to 0.23.0 in /tests ([#33](https://github.com/CloudNationHQ/terraform-azure-kv/issues/33)) ([8a16e84](https://github.com/CloudNationHQ/terraform-azure-kv/commit/8a16e84db930d015c34832b35e4cc56cb530904c))

## [0.8.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v0.7.0...v0.8.0) (2024-03-15)


### Features

* **deps:** bump google.golang.org/protobuf in /tests ([#28](https://github.com/CloudNationHQ/terraform-azure-kv/issues/28)) ([fcd881d](https://github.com/CloudNationHQ/terraform-azure-kv/commit/fcd881d7e816d2d0afc34ca44bbaf3f73f676e41))
* small refactor private endpoints ([#29](https://github.com/CloudNationHQ/terraform-azure-kv/issues/29)) ([6d1d4fd](https://github.com/CloudNationHQ/terraform-azure-kv/commit/6d1d4fdc96025ecf9e7b90dea9ae0467a3b01e1b))

## [0.7.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v0.6.0...v0.7.0) (2024-03-08)


### Features

* add conditional expressions to allow some global properties and updated documentation ([#26](https://github.com/CloudNationHQ/terraform-azure-kv/issues/26)) ([82430e8](https://github.com/CloudNationHQ/terraform-azure-kv/commit/82430e8f62daca8b4810aed4aec196a4b5d63fa1))
* **deps:** bump github.com/stretchr/testify in /tests ([#24](https://github.com/CloudNationHQ/terraform-azure-kv/issues/24)) ([7b987fc](https://github.com/CloudNationHQ/terraform-azure-kv/commit/7b987fc5f8cbe3a501f7474b8945dcd6ce9b42c8))

## [0.6.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v0.5.0...v0.6.0) (2024-02-27)


### Features

* add missing tag properties ([#22](https://github.com/CloudNationHQ/terraform-azure-kv/issues/22)) ([b2a7f98](https://github.com/CloudNationHQ/terraform-azure-kv/commit/b2a7f9815ae68d35a43196949d422f9d2f7765fd))
* **deps:** bump github.com/Azure/azure-sdk-for-go/sdk/azidentity ([#18](https://github.com/CloudNationHQ/terraform-azure-kv/issues/18)) ([4edc171](https://github.com/CloudNationHQ/terraform-azure-kv/commit/4edc1717195cf010c64d17ee2ce1b196e4359d6f))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#19](https://github.com/CloudNationHQ/terraform-azure-kv/issues/19)) ([bde8211](https://github.com/CloudNationHQ/terraform-azure-kv/commit/bde82111e421c466a3bcdb9918e0301d9537a346))
* improve naming sub resources ([#20](https://github.com/CloudNationHQ/terraform-azure-kv/issues/20)) ([b8eade6](https://github.com/CloudNationHQ/terraform-azure-kv/commit/b8eade6ab01f3790d33f7048488ca096f1c0825e))
* improved alignment for several vault properties and added some missing ones ([#23](https://github.com/CloudNationHQ/terraform-azure-kv/issues/23)) ([ba6efee](https://github.com/CloudNationHQ/terraform-azure-kv/commit/ba6efee760f538d17b20715a0fae0f0db8f9134a))

## [0.5.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v0.4.0...v0.5.0) (2024-01-19)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#14](https://github.com/CloudNationHQ/terraform-azure-kv/issues/14)) ([00c8633](https://github.com/CloudNationHQ/terraform-azure-kv/commit/00c8633eb6c27f8c8e6bc4978b3e6c9004c4b040))
* small refactor workflows ([#16](https://github.com/CloudNationHQ/terraform-azure-kv/issues/16)) ([074e792](https://github.com/CloudNationHQ/terraform-azure-kv/commit/074e79266e62a05239a75455e11cc18991d99bfa))

## [0.4.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v0.3.0...v0.4.0) (2023-12-22)


### Features

* add the ability to specify custom role assignment admin ids ([#12](https://github.com/CloudNationHQ/terraform-azure-kv/issues/12)) ([6019d57](https://github.com/CloudNationHQ/terraform-azure-kv/commit/6019d57c2275c4a92160d31b49368078817a84fa))

## [0.3.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v0.2.0...v0.3.0) (2023-12-19)


### Features

* **deps:** bump github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/keyvault/armkeyvault ([#9](https://github.com/CloudNationHQ/terraform-azure-kv/issues/9)) ([677e200](https://github.com/CloudNationHQ/terraform-azure-kv/commit/677e2004c19c50f47e3601e7cc79fddf5ad8d6b5))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#10](https://github.com/CloudNationHQ/terraform-azure-kv/issues/10)) ([e2d1fb6](https://github.com/CloudNationHQ/terraform-azure-kv/commit/e2d1fb6d3e84220755eed2e66809201bee443f67))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#5](https://github.com/CloudNationHQ/terraform-azure-kv/issues/5)) ([dd6778e](https://github.com/CloudNationHQ/terraform-azure-kv/commit/dd6778e529e908a1556d77fa628c811e15153388))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#7](https://github.com/CloudNationHQ/terraform-azure-kv/issues/7)) ([d13af7a](https://github.com/CloudNationHQ/terraform-azure-kv/commit/d13af7ab8d33b8d83bed666a92683d7654589dff))
* **deps:** bump golang.org/x/crypto from 0.14.0 to 0.17.0 in /tests ([#11](https://github.com/CloudNationHQ/terraform-azure-kv/issues/11)) ([a928a38](https://github.com/CloudNationHQ/terraform-azure-kv/commit/a928a382482ae332392bc4f4fbfb185753f0b63f))

## [0.2.0](https://github.com/CloudNationHQ/terraform-azure-kv/compare/v0.1.0...v0.2.0) (2023-11-06)


### Features

* add support for network acls ([#3](https://github.com/CloudNationHQ/terraform-azure-kv/issues/3)) ([adbf119](https://github.com/CloudNationHQ/terraform-azure-kv/commit/adbf11935909b3086c68fb1936ed5a80257ed09b))

## 0.1.0 (2023-11-06)


### Features

* add initial resources ([#1](https://github.com/CloudNationHQ/terraform-azure-kv/issues/1)) ([0f7abab](https://github.com/CloudNationHQ/terraform-azure-kv/commit/0f7abab35234bfd3bbc1871cbf8ee99199e5c431))
