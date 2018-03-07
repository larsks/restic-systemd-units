PREFIX=/usr/local

bindir=$(PREFIX)/bin
sysconfdir=/etc
unitdir=$(sysconfdir)/systemd/system
tmpfilesdir=$(sysconfdir)/tmpfiles.d

UNITS = \
	restic-backup@.service \
	restic-clean@.service \
	restic-backup.target

INSTALL = install

all:

install: install-tmpfiles install-units

install-tmpfiles:
	$(INSTALL) -m 644 restic-tmpfiles.conf $(tmpfilesdir)/restic.conf

install-units:
	for unit in $(UNITS); do \
		$(INSTALL) -m 644 $$unit $(unitdir); \
	done
