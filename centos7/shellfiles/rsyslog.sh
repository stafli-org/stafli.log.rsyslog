#!/bin/bash
#
#    CentOS 7 (centos7) Rsyslog824 Log Server (shellscript)
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

# Workaround for docker commands
alias FROM="#";
alias MAINTAINER="#";
alias LABEL="#";
alias ARG='export';
alias ENV='export';
alias RUN='';
alias CMD='#';
shopt -s expand_aliases;

# Load project settings
source $(dirname "${BASH_SOURCE[0]}")/../.env;

# Load dockerfile
source "$(dirname $(readlink -f $0))/../dockerfiles/rsyslog.dockerfile";

#
# Cleanup
#

# Remove dupplicated services
#yum remove -y rsyslog;

#
# Configuration
#

# Enable daemon
systemctl enable rsyslog.service;

# Start daemon
systemctl restart rsyslog.service;

