
#
#    Debian 7 (wheezy) Rsyslog58 Log Server (dockerfile)
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

#
# Build
#

# Base image to use
FROM stafli/stafli.init.supervisor:supervisor30_debian7

# Labels to apply
LABEL description="Stafli Rsyslog Log Server (stafli/stafli.log.rsyslog), Based on Stafli Supervisor Init (stafli/stafli.init.supervisor)" \
      maintainer="lp@algarvio.org" \
      org.label-schema.schema-version="1.0.0-rc.1" \
      org.label-schema.name="Stafli Rsyslog Log Server (stafli/stafli.log.rsyslog)" \
      org.label-schema.description="Based on Stafli Supervisor Init (stafli/stafli.init.supervisor)" \
      org.label-schema.keywords="stafli, rsyslog, log, debian, centos" \
      org.label-schema.url="https://stafli.org/" \
      org.label-schema.license="GPLv3" \
      org.label-schema.vendor-name="Stafli" \
      org.label-schema.vendor-email="info@stafli.org" \
      org.label-schema.vendor-website="https://www.stafli.org" \
      org.label-schema.authors.lpalgarvio.name="Luis Pedro Algarvio" \
      org.label-schema.authors.lpalgarvio.email="lp@algarvio.org" \
      org.label-schema.authors.lpalgarvio.homepage="https://lp.algarvio.org" \
      org.label-schema.authors.lpalgarvio.role="Maintainer" \
      org.label-schema.registry-url="https://hub.docker.com/r/stafli/stafli.log.rsyslog" \
      org.label-schema.vcs-url="https://github.com/stafli-org/stafli.log.rsyslog" \
      org.label-schema.vcs-branch="master" \
      org.label-schema.os-id="debian" \
      org.label-schema.os-version-id="7" \
      org.label-schema.os-architecture="amd64" \
      org.label-schema.version="1.0"

#
# Arguments
#

ARG app_rsyslog_listen_port="514"

#
# Environment
#

# Working directory to use when executing build and run instructions
# Defaults to /.
#WORKDIR /

# User and group to use when executing build and run instructions
# Defaults to root.
#USER root:root

#
# Packages
#

# Install rsyslog packages
#  - rsyslog: for rsyslogd, the rocket-fast system for log processing
RUN printf "Installing repositories and packages...\n" && \
    \
    printf "Install the selected packages...\n" && \
    apt-get update && apt-get install -qy \
      rsyslog && \
    \
    printf "Cleanup the package manager...\n" && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    \
    printf "Finished installing repositories and packages...\n";

#
# Configuration
#

# Update daemon configuration
# - Supervisor
# - Rsyslog
RUN printf "Updading Daemon configuration...\n" && \
    \
    printf "Updading Supervisor configuration...\n" && \
    \
    # /etc/supervisor/conf.d/init.conf \
    file="/etc/supervisor/conf.d/init.conf" && \
    printf "\n# Applying configuration for ${file}...\n" && \
    printf "# init\n\
[program:init]\n\
command=/bin/bash -c \"supervisorctl start rsyslogd;\"\n\
autostart=true\n\
autorestart=false\n\
startsecs=0\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
stdout_events_enabled=true\n\
stderr_events_enabled=true\n\
\n" > ${file} && \
    printf "Done patching ${file}...\n" && \
    \
    # /etc/supervisor/conf.d/rsyslogd.conf \
    file="/etc/supervisor/conf.d/rsyslogd.conf" && \
    printf "\n# Applying configuration for ${file}...\n" && \
    printf "# Rsyslog\n\
[program:rsyslogd]\n\
command=/bin/bash -c \"\$(which rsyslogd) -f /etc/rsyslog.conf -c5 -n\"\n\
autostart=false\n\
autorestart=true\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
stdout_events_enabled=true\n\
stderr_events_enabled=true\n\
\n" > ${file} && \
    printf "Done patching ${file}...\n" && \
    \
    printf "Updading Rsyslog configuration...\n" && \
    \
    # ignoring /etc/default/rsyslog \
    \
    # /etc/rsyslog.conf \
    file="/etc/rsyslog.conf" && \
    printf "\n# Applying configuration for ${file}...\n" && \
    # Enable tcp and udp communication \
    perl -0p -i -e "s>.*\\$\\ModLoad imtcp>\\$\\ModLoad imtcp>" ${file} && \
    perl -0p -i -e "s>.*\\$\\InputTCPServerRun .*>\\$\\InputTCPServerRun 514>" ${file} && \
    perl -0p -i -e "s>.*\\$\\ModLoad imudp>\\$\\ModLoad imudp>" ${file} && \
    perl -0p -i -e 's>.*UDPServerRun .*>'"\\$"'UDPServerRun 514>' ${file} && \
    # Disable kernel logging \
    perl -0p -i -e "s>\\$\\ModLoad imklog>#\\$\\ModLoad imklog>" ${file} && \
    # Enable local logging \
    perl -0p -i -e "s>.*\\$\\ModLoad imuxsock>\\$\\ModLoad imuxsock>" ${file} && \
    # Enable cron logging \
    perl -0p -i -e "s>#cron\.\*>cron.*>" ${file} && \
    # Disable xconsole \
    perl -0p -i -e "s>daemon.*;mail>#daemon.*;mail>" ${file} && \
    perl -0p -i -e "s>\t*news.err;>#\tnews.err;>" ${file} && \
    perl -0p -i -e "s>\t\*\.\=debug>#\t*.debug>" ${file} && \
    perl -0p -i -e "s>\t\*\.\=debug>#\t*.debug>" ${file} && \
    perl -0p -i -e "s>\t*\*\.=notice;\*\.=warn\t\|/dev/xconsole>#\t*.=notice;*.=warn\t\|/dev/xconsole>" ${file} && \
    printf "Done patching ${file}...\n" && \
    \
    printf "\n# Testing configuration...\n" && \
    echo "Testing $(which rsyslogd):" && $(which rsyslogd) -v && \
    printf "Done testing configuration...\n" && \
    \
    printf "Finished Daemon configuration...\n";

#
# Run
#

# Command to execute
# Defaults to /bin/bash.
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "--nodaemon"]

# Ports to expose
# Defaults to 514
EXPOSE ${app_rsyslog_listen_port}

