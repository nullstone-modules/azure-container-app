# 0.2.0 (Oct 2, 2026)
* Pinned `nullstone-io/ns` provider to `~> 0.13.0`.
* Replaced `ns_env_variables` with the layered `ns_env_layout`, `ns_env_values`, and `ns_env_platform_data` data sources to aggregate environment variables and secrets.
* Emitted the `env` platform data record, including the source of each variable and the container app secret name of each managed secret.
* Reported the variables Container Apps injects into containers (`CONTAINER_APP_NAME`, `CONTAINER_APP_ENV_DNS_SUFFIX`) in the `cloud` layer of the `env` platform data record.

# 0.1.0 (Unreleased)
* Initial release
