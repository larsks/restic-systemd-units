RESTIC_RELEASE=0.15.2

prefix=/usr
bindir=$(prefix)/bin
libexecdir=$(prefix)/libexec/restic
sysconfdir=/etc
unitdir=$(sysconfdir)/systemd/system
localstatedir=/var
cachedir=$(localstatedir)/cache/restic

RESTIC_USER=restic
RESTIC_GROUP=restic

TIMERS = \
	restic-backup-daily@.timer \
	restic-backup-weekly@.timer \
	restic-backup-monthly@.timer

SERVICES = \
	restic-backup@.service

UNITS = \
	$(SERVICES) \
	$(TIMERS)

BINSCRIPTS = restic-helper
LIBEXECSCRIPTS = restic-backup

INSTALL = install

restic-backup-%@.timer: restic-backup-schedule.timer
	@echo generating $@
	@schedule=$(shell echo $@ | cut -f1 -d@ | cut -f3 -d-); \
		 sed "s/@schedule@/$$schedule/g" $< > $@ || rm -f $@

all: $(UNITS)

install: install-restic install-units install-libexec install-bin

restic:
	curl -fL -o $(RESTIC_USER).bz2 https://github.com/restic/restic/releases/download/v$(RESTIC_RELEASE)/restic_$(RESTIC_RELEASE)_linux_amd64.bz2
	bunzip2	restic.bz2

install-bindir:
	$(INSTALL) -d -m 755 $(bindir)

install-bin: install-bindir $(BINSCRIPTS)
	for x in $(BINSCRIPTS); do \
		$(INSTALL) -m 750 -o $(RESTIC_USER) -g $(RESTIC_GROUP) $$x $(bindir); \
	done

install-libexecdir:
	$(INSTALL) -d -m 750 -o $(RESTIC_USER) -g $(RESTIC_GROUP) $(libexecdir)

install-libexec: install-libexecdir $(LIBEXECSCRIPTS)
	for x in $(LIBEXECSCRIPTS); do \
		$(INSTALL) -m 750 -o $(RESTIC_USER) -g $(RESTIC_GROUP) $$x $(libexecdir); \
	done

install-cachedir:
	$(INSTALL) -d -m 750 -o $(RESTIC_USER) -g $(RESTIC_GROUP) $(cachedir)

install-restic: restic install-libexec install-bin install-cachedir
	$(INSTALL) -m 755 restic $(bindir)/restic
	$(INSTALL) -m 550 -o $(RESTIC_USER) -g $(RESTIC_GROUP) restic $(libexecdir)/restic
	setcap cap_dac_read_search=+ep $(libexecdir)/restic

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
	rm -f $(TIMERS)
