# Scripts

Personal scripts which may be of little or no use to anybody else.

## anvil.sh

Drops certificates into Nginx using acme.sh, without typ-typ-typing.

```
Usage:
   anvil.sh install <domain> <cf_account_id> <cf_token>
   anvil.sh remove <domain>
```

I usually just:

```
curl -s https://andydvsn.github.io/scripts/anvil.sh | \
bash -s install <domain> <cf_account_id> <cf_token>
```
