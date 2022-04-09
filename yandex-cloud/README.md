## Version for Yandex Cloud

### Set credentials and required variables

```
export TF_VAR_yc_token="xxxxxxxxxxxxxxxxx"
export TF_VAR_yc_project='{ cloud_id = "yyyyyyyyyyyyyy", folder_id = "zzzzzzzzzzzzzzz" }'
export TF_VAR_ssh_public_key="your ssh public key"
```

### Unset environments for clean up

```
unset TF_VAR_yc_token
unset TF_VAR_yc_project
unset TF_VAR_ssh_public_key
```