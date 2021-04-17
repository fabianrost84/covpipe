FROM continuumio/miniconda3
ENV VERSION 3.0.4
ENV TOOL covpipe

# meta data
LABEL base_image="continuumio/miniconda3"
LABEL about.summary="CovPipe is a pipeline to generate consensus sequences from NGS reads based on a reference sequence. The pipeline is tailored to be used for SARS-CoV-2 data, but may be used for other viruses."
LABEL about.license="GLP3"
LABEL about.tags="ncov"
LABEL about.home="https://gitlab.com/RKIBioinformaticsPipelines/ncov_minipipe"

LABEL maintainer="RKI MF1 Bioinformatics <https://www.rki.de/EN/Content/Institute/DepartmentsUnits/MF/MF1/mf1_node.html>"


# install basics
RUN apt update && apt install -y procps wget gzip pigz bc build-essential libbz2-dev && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN pip install Cython \
    && conda install -c bioconda -c conda-forge python=3.7 mamba \
    && pip install covpipe==${VERSION} \
    && mamba clean -a \
    && chmod -R a+w /opt/conda


COPY hash.py . 
RUN chmod +x hash.py \
    && for YAML in $(ls /opt/conda/lib/python3.7/site-packages/covpipe/envs/*.yaml);\
        do export YAML; MD5=$(python hash.py | cut -c 1-8) \
           && mamba env create --prefix /.snakemake/conda/$MD5 -f $YAML \
           && rm -rf /tmp/* \
           && rm -rf /root/.conda/pkgs/* \
           && rm -rf /opt/conda/pkgs/* \
           && cp $YAML /.snakemake/conda/$MD5.yaml;\
        done \
   && mamba clean -a \
   && chmod -R a+w /opt/conda && chmod -R a+w /.snakemake

# integrate kraken database into the container (will increase container size by ~4 GB!)
RUN wget -q -O kraken_db.tar.gz https://zenodo.org/record/4534746/files/GRCh38.p13_SC2_2021-02-08.tar.gz?download=1 \
    && tar zxvf kraken_db.tar.gz \
    && rm kraken_db.tar.gz \
    && chmod -R a+rX /GRCh38.p13_SC2_2021-02-08
