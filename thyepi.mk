# generated via include mk-git-list.mk

MAKEFLAGS += -Rr
Makefile:;

top:; @date

~ := thyepi
$~ =
$~ += amr-disk-part
$~ += amr-pysphere-misc
$~ += ansible-hg-modules
$~ += ar-common-tools
$~ += ar-if-rename-first
$~ += ar-vsphere-clone
$~ += ar-vsphere-disk-add
$~ += ar-vsphere-if-add
$~ += dispatch-log
$~ += infra-misc
$~ += infra-misc-plays
$~ += infra-upgrade
$~ += rsync-pair
$~ += sort-error-log

amr-disk-part        :=  git@thyepi.github.com:thyepi/amr-disk-part.git
amr-pysphere-misc    :=  git@thyepi.github.com:thyepi/amr-pysphere-misc.git
ansible-hg-modules   :=  git@thyepi.github.com:thyepi/ansible-hg-modules.git
ar-common-tools      :=  git@thyepi.github.com:thyepi/ar-common-tools.git
ar-if-rename-first   :=  git@thyepi.github.com:thyepi/ar-if-rename-first.git
ar-vsphere-clone     :=  git@thyepi.github.com:thyepi/ar-vsphere-clone.git
ar-vsphere-disk-add  :=  git@thyepi.github.com:thyepi/ar-vsphere-disk-add.git
ar-vsphere-if-add    :=  git@thyepi.github.com:thyepi/ar-vsphere-if-add.git
dispatch-log         :=  git@thyepi.github.com:thyepi/dispatch-log.git
infra-misc           :=  git@thyepi.github.com:thyepi/infra-misc.git
infra-misc-plays     :=  git@thyepi.github.com:thyepi/infra-misc-plays.git
infra-upgrade        :=  git@thyepi.github.com:thyepi/infra-upgrade.git
rsync-pair           :=  git@thyepi.github.com:thyepi/rsync-pair.git
sort-error-log       :=  git@thyepi.github.com:thyepi/sort-error-log.git

$(thyepi):; git clone $($@)
thyepi: $(thyepi);
.PHONY: thyepi
