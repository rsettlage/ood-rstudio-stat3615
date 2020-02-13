## helpful read: https://divingintogeneticsandgenomics.rbind.io/post/run-rstudio-server-with-singularity-on-hpc/
## combining the tidyverse and verse Dockerfiles, wanting to make sure I have the rstudio-r version

FROM rocker/rstudio:3.6.1

LABEL org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/rsettlag" \
      maintainer="Robert Settlage <rsettlag@vt.edu>"
## helpful read: https://divingintogeneticsandgenomics.rbind.io/post/run-rstudio-server-with-singularity-on-hpc/

ENV PATH=$PATH:/opt/TinyTeX/bin/x86_64-linux/

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  libxml2-dev \
  libcairo2-dev \
  libsqlite3-dev \
  libmariadbd-dev \
  libmariadb-client-lgpl-dev \
  libpq-dev \
  libssh2-1-dev \
  mesa-common-dev \
  libglu1-mesa-dev \
  unixodbc-dev \
  libsasl2-dev \
  libhdf5-dev \
  curl \
  rustc
RUN Rscript -e 'install.packages(Ncpus=6,c("tidyverse","dplyr","devtools","formatR","remotes","selectr","caTools","ggpubr","data.table","BiocManager","lme4","VennDiagram","doParallel","gplots","ggrepel","randomForest","rlecuyer","tibble","RcppEigen","mvtnorm","IDPmisc","visreg","swirl"))' \
  && Rscript -e "instpkgs<-c('Biostrings','biobase','MLSeq','biomaRt','DESeq2','DT','edgeR','Heatplus'); BiocManager::install(instpkgs)" \
  && Rscript -e "library(swirl);install_course('R Programming');install_course('A (very) short introduction to R');install_course('Exploratory Data Analysis ');install_course('Getting and Cleaning Data');install_course('Statistical Inference');install_course('Psychology Statistics');install_course('Advanced R Programming')" \
  && wget "https://travis-bin.yihui.name/texlive-local.deb" \
  && dpkg -i texlive-local.deb \
  && rm texlive-local.deb \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ## for rJava
    default-jdk \
    ## Nice Google fonts
    fonts-roboto \
    ## used by some base R plots
    ghostscript \
    ## used to build rJava and other packages
    libbz2-dev \
    libicu-dev \
    liblzma-dev \
    ## system dependency of hunspell (devtools)
    libhunspell-dev \
    ## system dependency of hadley/pkgdown
    libmagick++-dev \
    ## rdf, for redland / linked data
    librdf0-dev \
    ## for V8-based javascript wrappers
    libv8-dev \
    ## R CMD Check wants qpdf to check pdf sizes, or throws a Warning
    qpdf \
    ## For building PDF manuals
    texinfo \
    ## for git via ssh key
    ssh \
 ## parallelization
    libzmq3-dev \
    libopenmpi-dev \
 ## for gifski
    cargo \
 && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
  ## Use tinytex for LaTeX installation
  && install2.r --error tinytex \
 ## Admin-based install of TinyTeX:
  && wget -qO- \
    "https://github.com/yihui/tinytex/raw/master/tools/install-unx.sh" | \
    sh -s - --admin --no-path \
  && mv ~/.TinyTeX /opt/TinyTeX \
  && /opt/TinyTeX/bin/*/tlmgr path add \
  && tlmgr install ae inconsolata listings metafont mfware parskip pdfcrop tex \
  && tlmgr path add \
  && Rscript -e "tinytex::r_texmf()" \
  && chown -R root:staff /opt/TinyTeX \
  && chown -R root:staff /usr/local/lib/R/site-library \
  && chmod -R g+w /opt/TinyTeX \
  && chmod -R g+wx /opt/TinyTeX/bin \
  && echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron \
  ## Currently (2017-06-06) need devel PKI for ssl issue: https://github.com/s-u/PKI/issues/19
  && install2.r --error PKI \
  ## And some nice R packages for publishing-related stuff
  && install2.r --error --deps TRUE \
    bookdown \
    rticles \
    rmdshower \
    rJava \
    knitr \
    pkgmaker

RUN apt-get clean
RUN sed -i '/^R_LIBS_USER=/d' /usr/local/lib/R/etc/Renviron
RUN echo 'R_ENVIRON=~/.Renviron.OOD \
      \nR_ENVIRON_USER=~/.Renviron.OOD \
      \n' >>/usr/local/lib/R/etc/Renviron
RUN rm /usr/local/lib/R/etc/Rprofile.site
