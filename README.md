# restic systemd units

This is a collection of systemd units for managing backups with
[restic][].

[restic]: https://restic.net/

## Installing

To install systemd units into `/etc/systemd/system`:

    make && sudo make install

### What gets installed?

    /etc/systemd/system/restic-backup-daily@.timer
    /etc/systemd/system/restic-backup-monthly@.timer
    /etc/systemd/system/restic-backup@.service
    /etc/systemd/system/restic-backup.target
    /etc/systemd/system/restic-backup-weekly@.timer

    /etc/systemd/system/restic-check-daily@.timer
    /etc/systemd/system/restic-check-monthly@.timer
    /etc/systemd/system/restic-check@.service
    /etc/systemd/system/restic-check-weekly@.timer
    
    /etc/systemd/system/restic-forget-daily@.timer
    /etc/systemd/system/restic-forget-monthly@.timer
    /etc/systemd/system/restic-forget@.service
    /etc/systemd/system/restic-forget.target
    /etc/systemd/system/restic-forget-weekly@.timer
    
    /etc/systemd/system/restic-prune-daily@.timer
    /etc/systemd/system/restic-prune-monthly@.timer
    /etc/systemd/system/restic-prune@.service
    /etc/systemd/system/restic-prune.target
    /etc/systemd/system/restic-prune-weekly@.timer

## Configuration

In `/etc/restic/config.env`:

    # Backblaze B2 configuration
    B2_ACCOUNT_ID="1234"
    B2_ACCOUNT_KEY="secret"

    # Restic configuration
    RESTIC_PASSWORD_FILE=/etc/restic/password

    XDG_CACHE_HOME=/var/cache/restic

In `/etc/restic/home/config.env`:

    BACKUP_DIR=/home
    RESTIC_BACKUP_ARGS="--tag home"
    RESTIC_FORGET_ARGS="--tag home --keep-daily 2 --keep-weekly 2 --keep-monthly 1"
    RESTIC_REPOSITORY=b2:my-backup-bucket

## Enabling backups

Assuming that you have `/etc/restic/home` configured as above, then to
schedule daily backups of `/home`:

    systemctl enable --now restic-backup-daily@home.timer

Or to schedule weekly backups:

    systemctl enable --now restic-backup-weekly@home.timer

## Lockfiles

These units use the `flock` binary to serialize multiple instances of
the same template unit.  This means if you start two backups in
parallel...

    systemctl start restic-backup@home restic-backup@database

...that they will actually run one after the other instead of running
at the same time.
