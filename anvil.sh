#!/usr/bin/env bash
set -euo pipefail

## anvil.sh v0.03 (2nd April 2026) by Andrew Davison

# Usage:
#   anvil.sh install <domain> <cf_account_id> <cf_token>
#   anvil.sh remove <domain>
#
# Run as the user who owns the acme.sh install.
#
# Prerequisites:
#   acme.sh must be installed before running this script:
#   curl https://get.acme.sh | sh -s email=you@example.com

SSL_DIR="/etc/nginx/ssl"
ACME_SH="/home/$USER/.acme.sh/acme.sh"

usage() {
	echo "Usage:"
	echo "  $0 install <domain> <cf_account_id> <cf_token>"
	echo "  $0 remove <domain>"
	exit 1
}

cmd_install() {

	if [ "$#" -ne 3 ]; then
		echo "Error: install requires 3 arguments"
		usage
	fi

	LOCAL_USER="$USER"
	DOMAIN="$1"
	CF_ACCOUNT_ID="$2"
	CF_TOKEN="$3"

	echo "==> Ensuring passwordless sudo for $LOCAL_USER..."
	SUDOERS_FILE="/etc/sudoers.d/98-$LOCAL_USER"
	echo "$LOCAL_USER ALL=(ALL) NOPASSWD: ALL" | sudo tee "$SUDOERS_FILE" > /dev/null
	sudo chmod 440 "$SUDOERS_FILE"
	echo "    Written: $SUDOERS_FILE"

	echo ""
	echo "==> Issuing wildcard cert for $DOMAIN via Cloudflare DNS..."
	export CF_Account_ID="$CF_ACCOUNT_ID"
	export CF_Token="$CF_TOKEN"

	"$ACME_SH" --force --issue \
		-d "$DOMAIN" \
		-d "*.$DOMAIN" \
		--dns dns_cf \
		--server letsencrypt \
		--keylength ec-384

	echo "==> Setting up ssl-cert group..."
	sudo groupadd -f ssl-cert
	sudo usermod -aG ssl-cert "$LOCAL_USER"

	echo "==> Creating SSL directory $SSL_DIR..."
	sudo mkdir -p "$SSL_DIR"
	sudo chown -R "root:ssl-cert" "$SSL_DIR"
	sudo chmod -R 770 "$SSL_DIR"

	echo ""
	echo "==> Installing to $SSL_DIR..."
	sg ssl-cert -c "'$ACME_SH' --install-cert \
		-d '$DOMAIN' \
		-d '*.$DOMAIN' \
		--key-file '$SSL_DIR/$DOMAIN.key' \
		--fullchain-file '$SSL_DIR/$DOMAIN.cer'"

	while true; do

		echo ""
		echo "==> Testing Nginx config..."
		if sudo nginx -t; then
			break
		fi

		echo ""
		echo "Update your Nginx config to use the key and fullchain paths above."
		echo ""
		read -rp "Press Enter to re-test..." < /dev/tty || true

	done

	echo ""
	echo "==> Registering reload command and reloading Nginx..."
	sg ssl-cert -c "'$ACME_SH' --install-cert \
		-d '$DOMAIN' \
		-d '*.$DOMAIN' \
		--key-file '$SSL_DIR/$DOMAIN.key' \
		--fullchain-file '$SSL_DIR/$DOMAIN.cer' \
		--reloadcmd 'sudo systemctl reload nginx'"

	echo ""
	"$ACME_SH" list

}

cmd_remove() {

	if [ "$#" -ne 1 ]; then
		echo "Error: remove requires 1 argument"
		usage
	fi

	DOMAIN="$1"

	echo "==> Removing $DOMAIN from acme.sh..."
	"$ACME_SH" --remove -d "$DOMAIN"

	echo "==> Deleting acme.sh cert directory..."
	rm -rf "$HOME/.acme.sh/${DOMAIN}_ecc"

	echo "==> Deleting Nginx SSL files..."
	sudo rm -f "$SSL_DIR/$DOMAIN".*

	echo ""
	"$ACME_SH" list

}

# ---- Entry point ----

if [ "$#" -lt 1 ]; then
	usage
fi

ACTION="$1"
shift

case "$ACTION" in
	install) cmd_install "$@" ;;
	remove)  cmd_remove "$@" ;;
	*)
		echo "Error: unknown command '$ACTION'"
		usage
		;;
esac
