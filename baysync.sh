#!/usr/bin/env bash

## baysync.sh v1.01 (20th January 2026) by Andrew Davison
##  Backs up the local drive bays to Drobo.

LOGFILE="$HOME/Library/Logs/baysync.log"
echo > "$LOGFILE"

EXCLUDES=(
	--exclude='.bzvol/*.log'
	--exclude='.bzvol/bzscratch'
	--exclude='.fseventsd'
	--exclude='.DocumentRevisions-V100'
	--exclude='.Spotlight-V100'
	--exclude='.Trashes'
	--exclude='.TemporaryItems'
)

# Function to log messages
log() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOGFILE"
}

log "=== Backup started ==="

# Check for destination.
DESTINATION="Drobo"
if [ ! -d "/Volumes/$DESTINATION" ]; then
	log "ERROR: Volume not found at /Volumes/$DESTINATION"
	log "Please check that $DESTINATION is alive."
	exit 1
fi

SOURCE="Bay 1"
if [ ! -d "/Volumes/$SOURCE" ]; then
	log "WARNING: Volume not found at /Volumes/$SOURCE"
	log "Skipping $SOURCE sync."
else
	log "Starting sync of /Volumes/$SOURCE/..."
	rsync -avh --delete --progress \
		"${EXCLUDES[@]}" \
		"/Volumes/$SOURCE/" "/Volumes/$DESTINATION/Backups/$SOURCE/" >> "$LOGFILE" 2>&1
	
	if [ $? -eq 0 ]; then
		log "$SOURCE backup completed successfully."
	else
		log "ERROR: $SOURCE backup failed with exit code $?"
	fi
fi

SOURCE="Bay 2"
if [ ! -d "/Volumes/$SOURCE" ]; then
	log "WARNING: Volume not found at /Volumes/$SOURCE"
	log "Skipping $SOURCE sync."
else
	log "Starting sync of /Volumes/$SOURCE/..."
	rsync -avh --delete --progress \
		"${EXCLUDES[@]}" \
		--exclude='Library' \
		--exclude='Syncthing' \
		"/Volumes/$SOURCE/" "/Volumes/$DESTINATION/Backups/$SOURCE/" >> "$LOGFILE" 2>&1
	
	if [ $? -eq 0 ]; then
		log "$SOURCE backup completed successfully."
	else
		log "ERROR: $SOURCE backup failed with exit code $?"
	fi
fi

log "=== Backup process complete ==="
