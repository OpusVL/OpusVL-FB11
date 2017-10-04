FROM quay.io/opusvl/perl-5.20-dev:master as dbic-catalyst

ENV http_proxy=http://dev-05:3128
ENV PERL_CPANM_OPT=' \
    --configure-timeout 84000 \
    --build-timeout 84000 \
    --test-timeout 84000 \
    --mirror http://cpan.opusvl.com' 

RUN /opt/perl5/bin/cpanm Term::ReadKey HTML::FormFu Catalyst::Runtime DBIx::Class Devel::Confess
RUN /opt/perl5/bin/cpanm JSON::XS Starman

# ----- #

FROM quay.io/opusvl/perl-5.20-dev:master as release
COPY --from=dbic-catalyst /opt/perl5 /opt/perl5
COPY entrypoint.pl /
ENTRYPOINT [ "/entrypoint.pl" ]

RUN apt-get update && apt-get -y install libexpat1-dev

ENV http_proxy=http://dev-05:3128
ENV no_proxy=localhost,127.0.0.1

ENV PERL_CPANM_OPT=' \
    --configure-timeout 84000 \
    --build-timeout 84000 \
    --test-timeout 84000 \
    --mirror http://cpan.opusvl.com \
    -l /opt/fb11/'

RUN useradd -m -U -b /opt fb11
ENV PERL5LIB /opt/fb11/lib/perl5

USER fb11
WORKDIR /opt/fb11

ARG version
RUN if [ -z "$version" ]; then echo "Version not provided"; exit 1; fi;

COPY OpusVL-FB11-$version.tar.gz .
RUN /opt/perl5/bin/cpanm ./OpusVL-FB11-$version.tar.gz \
    && rm ./OpusVL-FB11-$version.tar.gz 
