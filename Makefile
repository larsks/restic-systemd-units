PREFIX=/usr/local

bindir=$(PREFIX)/bin
sysconfdir=/etc
unitdir=$(sysconfdir)/systemd/system
tmpfilesdir=$(sysconfdir)/tmpfiles.d

TIMERS = \
	restic-backup-daily@.timer \
	restic-backup-weekly@.timer \
	restic-backup-monthly@.timer \
	restic-clean-daily@.timer \
	restic-clean-weekly@.timer \
	restic-clean-monthly@.timer

UNITS = \
	restic-backup@.service \
	restic-clean@.service \
	restic-backup.target \
	$(TIMERS)

INSTALL = install

restic-backup-%@.timer: restic-backup-schedule.timer
	schedule=$(shell echo $@ | cut -f1 -d@ | cut -f3 -d-); \
		 sed "s/@schedule@/$$schedule/g" $< > $@ || rm -f $@

restic-clean-%@.timer: restic-clean-schedule.timer
	schedule=$(shell echo $@ | cut -f1 -d@ | cut -f3 -d-); \
		 sed "s/@schedule@/$$schedule/g" $< > $@ || rm -f $@

all: $(UNITS)

install: install-tmpfiles install-units

install-tmpfiles:
	$(INSTALL) -m 644 restic-tmpfiles.conf $(tmpfilesdir)/restic.conf

install-units: $(UNITS)
	for unit in $(UNITS); do \
		$(INSTALL) -m 644 $$unit $(unitdir); \
	done
	systemctl daemon-reload

clean:
	rm -f $(TIMERS)
