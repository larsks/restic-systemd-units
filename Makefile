PREFIX=/usr/local

bindir=$(PREFIX)/bin
sysconfdir=/etc
unitdir=$(sysconfdir)/systemd/system
tmpfilesdir=$(sysconfdir)/tmpfiles.d

TIMERS = \
	restic-backup-daily@.timer \
	restic-backup-weekly@.timer \
	restic-backup-monthly@.timer \
	restic-check-daily@.timer \
	restic-check-weekly@.timer \
	restic-check-monthly@.timer \
	restic-forget-daily@.timer \
	restic-forget-weekly@.timer \
	restic-forget-monthly@.timer \
	restic-prune-daily@.timer \
	restic-prune-weekly@.timer \
	restic-prune-monthly@.timer

UNITS = \
	restic-backup@.service \
	restic-forget@.service \
	restic-prune@.service \
	restic-check@.service \
	restic-backup.target \
	restic-forget.target \
	restic-prune.target \
	$(TIMERS)

SCRIPTS = restic-helper

INSTALL = install

restic-backup-%@.timer: restic-backup-schedule.timer
	@echo generate $@
	@schedule=$(shell echo $@ | cut -f1 -d@ | cut -f3 -d-); \
		 sed "s/@schedule@/$$schedule/g" $< > $@ || rm -f $@

restic-forget-%@.timer: restic-forget-schedule.timer
	@echo generate $@
	@schedule=$(shell echo $@ | cut -f1 -d@ | cut -f3 -d-); \
		 sed "s/@schedule@/$$schedule/g" $< > $@ || rm -f $@

restic-prune-%@.timer: restic-prune-schedule.timer
	@echo generate $@
	@schedule=$(shell echo $@ | cut -f1 -d@ | cut -f3 -d-); \
		 sed "s/@schedule@/$$schedule/g" $< > $@ || rm -f $@

restic-check-%@.timer: restic-check-schedule.timer
	@echo generate $@
	@schedule=$(shell echo $@ | cut -f1 -d@ | cut -f3 -d-); \
		 sed "s/@schedule@/$$schedule/g" $< > $@ || rm -f $@

all: $(UNITS)

install: install-tmpfiles install-units install-scripts

install-scripts:
	$(INSTALL) -m 755 -d $(DESTDIR)$(bindir)
	for script in $(SCRIPTS); do \
		$(INSTALL) -m 755 $$script $(DESTDIR)$(bindir); \
	done

install-tmpfiles:
	$(INSTALL) -m 755 -d $(DESTDIR)$(tmpfilesdir)
	$(INSTALL) -m 644 restic-tmpfiles.conf $(DESTDIR)$(tmpfilesdir)/restic.conf

install-units: $(UNITS)
	$(INSTALL) -m 755 -d $(DESTDIR)$(unitdir)
	for unit in $(UNITS); do \
		$(INSTALL) -m 644 $$unit $(DESTDIR)$(unitdir); \
	done

clean:
	rm -f $(TIMERS)

reload:
	systemctl daemon-reload
