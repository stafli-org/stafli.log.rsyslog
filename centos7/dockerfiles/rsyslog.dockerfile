
#
#    CentOS 7 (centos7) Rsyslog824 Log Server (dockerfile)
#    Copyright (C) 2016-2017 Stafli
#    Luís Pedro Algarvio
#    This file is part of the Stafli Application Stack.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

FROM stafli/stafli.system.base:base10_centos7

#
# Arguments
#

#
# Packages
#

# Install daemon and utilities packages
#  - rsyslog: for rsyslogd, the rocket-fast system for log processing
#  - logrotate: for logrotate, the log rotation utility
RUN printf "Installing repositories and packages...\n" && \
    \
    printf "Install the required packages...\n" && \
    yum makecache && yum install -y \
      rsyslog logrotate && \
    printf "Cleanup the Package Manager...\n" && \
    yum clean all && rm -Rf /var/lib/yum/*; \
    \
    printf "Finished installing repositories and packages...\n";

#
# Configuration
#

# Update daemon configuration
# - Supervisor
# - Rsyslog
RUN printf "Updading Daemon configuration...\n"; \
    \
    printf "Updading Supervisor configuration...\n"; \
    \
    # /etc/supervisord.d/init.conf \
    file="/etc/supervisord.d/init.conf"; \
    printf "\n# Applying configuration for ${file}...\n"; \
    printf "# init\n\
[program:init]\n\
command=/bin/bash -c \"supervisorctl start rsyslogd;\"\n\
autostart=true\n\
autorestart=false\n\
startsecs=0\n\
\n" > ${file}; \
    printf "Done patching ${file}...\n"; \
    \
    # /etc/supervisord.d/rsyslogd.conf \
    file="/etc/supervisord.d/rsyslogd.conf"; \
    printf "\n# Applying configuration for ${file}...\n"; \
    printf "# Rsyslog\n\
[program:rsyslogd]\n\
command=/bin/bash -c \"\$(which rsyslogd) -f /etc/rsyslog.conf -n\"\n\
autostart=false\n\
autorestart=true\n\
\n" > ${file}; \
    printf "Done patching ${file}...\n"; \
    \
    printf "Updading Rsyslog configuration...\n"; \
    \
    # ignoring /etc/sysconfig/rsyslog \
    \
    # /etc/rsyslog.conf \
    file="/etc/rsyslog.conf"; \
    printf "\n# Applying configuration for ${file}...\n"; \
    # Disable kernel logging \
    perl -0p -i -e "s>\\$\\ModLoad imklog>#\\$\\ModLoad imklog>" ${file}; \
    # Enable socket input and local logging \
    # http://www.projectatomic.io/blog/2014/09/running-syslog-within-a-docker-container/ \
    perl -0p -i -e "s>#\\$\\ModLoad imuxsock>\\$\\ModLoad imuxsock>" ${file}; \
    perl -0p -i -e "s>\\$\\OmitLocalLogging on>\\$\\OmitLocalLogging off>" ${file}; \
    # Disable systemd (journald) logging \
    # http://www.projectatomic.io/blog/2014/09/running-syslog-within-a-docker-container/ \
    perl -0p -i -e "s>\\$\\ModLoad imjournal>#\\$\\ModLoad imjournal>" ${file}; \
    perl -0p -i -e "s>\\$\\IMJournalStateFile>#\\$\\IMJournalStateFile>" ${file}; \
    printf "Done patching ${file}...\n"; \
    \
    # /etc/rsyslog.d/listen.conf \
    file="/etc/rsyslog.d/listen.conf"; \
    printf "\n# Applying configuration for ${file}...\n"; \
    # Disable systemd (journald) logging \
    perl -0p -i -e "s>\\$\\SystemLogSocketName>#\\$\\SystemLogSocketName>" ${file}; \
    printf "Done patching ${file}...\n"; \
    \
    printf "\n# Testing configuration...\n"; \
    echo "Testing $(which rsyslogd):"; $(which rsyslogd) -v; \
    printf "Done testing configuration...\n"; \
    \
    printf "Finished Daemon configuration...\n";

