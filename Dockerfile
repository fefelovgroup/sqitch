FROM gliderlabs/alpine:3.1
MAINTAINER Andy Fefelov <andy@fefelovgroup.com>

RUN apk update
RUN apk add wget build-base perl tzdata
RUN apk add postgresql-dev postgresql-client libpq perl-dev

RUN cpan App::cpanminus
RUN cpanm --notest -q App::Sqitch
RUN cpanm --notest -q DBD::Pg
RUN cpanm --notest -q TAP::Parser::SourceHandler::pgTAP

RUN apk del --purge postgresql-dev perl-dev build-base wget
RUN rm -rf ~/.cpan ~/.cpanm
RUN ln -sf /usr/share/zoneinfo/UTC  /etc/localtime
