PREFIX=/usr/local

bindir=$(PREFIX)/bin
sysconfdir=/etc
unitdir=$(sysconfdir)/systemd/system
tmpfilesdir=$(sysconfdir)/tmpfiles.d

RESTIC_PATH=$(bindir)/restic

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

SERVICES = \
	restic-backup@.service \
	restic-forget@.service \
	restic-prune@.service \
	restic-check@.service

UNITS = \
	$(SERVICES) \
	$(TIMERS)

SCRIPTS = restic-helper

INSTALL = install

%.service: %.service.in
	@echo generate $@
	@sed 's,@RESTIC_PATH@,$(RESTIC_PATH),g' $< > $@ || rm -f $@

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

install-units: install-services install-timers

install-services: $(SERVICES)
	$(INSTALL) -m 755 -d $(DESTDIR)$(unitdir)
	for unit in $(SERVICES); do \
		$(INSTALL) -m 644 $$unit $(DESTDIR)$(unitdir); \
	done

install-timers: $(TIMERS)
	$(INSTALL) -m 755 -d $(DESTDIR)$(unitdir)
	for unit in $(TIMERS); do \
		$(INSTALL) -m 644 $$unit $(DESTDIR)$(unitdir); \
	done

clean:
	rm -f $(TIMERS) $(SERVICES)

reload:
	systemctl daemon-reload

activate-targets:
	systemctl start $(TARGETS)
