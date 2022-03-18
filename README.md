# ![nf-core/raredisease](docs/images/nf-core-raredisease_logo_light.png#gh-light-mode-only) ![nf-core/raredisease](docs/images/nf-core-raredisease_logo_dark.png#gh-dark-mode-only)

[![GitHub Actions CI Status](https://github.com/nf-core/raredisease/workflows/nf-core%20CI/badge.svg)](https://github.com/nf-core/raredisease/actions?query=workflow%3A%22nf-core+CI%22)
[![GitHub Actions Linting Status](https://github.com/nf-core/raredisease/workflows/nf-core%20linting/badge.svg)](https://github.com/nf-core/raredisease/actions?query=workflow%3A%22nf-core+linting%22)
[![AWS CI](https://img.shields.io/badge/CI%20tests-full%20size-FF9900?labelColor=000000&logo=Amazon%20AWS)](https://nf-co.re/raredisease/results)
[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.XXXXXXX)

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A521.10.3-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

[![Get help on Slack](http://img.shields.io/badge/slack-nf--core%20%23raredisease-4A154B?labelColor=000000&logo=slack)](https://nfcore.slack.com/channels/raredisease)
[![Follow on Twitter](http://img.shields.io/badge/twitter-%40nf__core-1DA1F2?labelColor=000000&logo=twitter)](https://twitter.com/nf_core)
[![Watch on YouTube](http://img.shields.io/badge/youtube-nf--core-FF0000?labelColor=000000&logo=youtube)](https://www.youtube.com/c/nf-core)

## Introduction

**nf-core/raredisease** is a bioinformatics best-practice analysis pipeline for call and score variants from WGS/WES of rare disease patients.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies. Where possible, these processes have been submitted to and installed from [nf-core/modules](https://github.com/nf-core/modules) in order to make them available to all nf-core pipelines, and to everyone within the Nextflow community!

<!-- TODO nf-core: Add full-sized test dataset and amend the paragraph below if applicable -->
On release, automated continuous integration tests run the pipeline on a full-sized dataset on the AWS cloud infrastructure. This ensures that the pipeline runs on AWS, has sensible resource allocation defaults set to run on real-world datasets, and permits the persistent storage of results to benchmark between pipeline releases and other analysis sources. The results obtained from the full-sized test can be viewed on the [nf-core website](https://nf-co.re/raredisease/results).

## Pipeline summary

1. Metrics: [`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/), [`MultiQC`](http://multiqc.info/)
2. Data preprocessing: [`bwamem2`](http://bio-bwa.sourceforge.net/bwa.shtml) (can [`merge`](http://www.htslib.org/doc/samtools-merge.html)), [`MarkDuplicates`](https://broadinstitute.github.io/picard/command-line-overview.html#MarkDuplicates),
3. Variant calling + aggregation:
    1. SNVs: [`DeepVariant`](https://github.com/google/deepvariant)
    2. SVs: [`tiddit/sv`](https://github.com/SciLifeLab/TIDDIT),
4. Annotation: [`VCFanno`](https://github.com/brentp/vcfanno),[`VEP`](https://www.ensembl.org/info/docs/tools/vep/index.html)
    1. SNVs:
    2. SVs:
    3. Mitochondria: [`HmtNote`](https://github.com/robertopreste/HmtNote)

> Databases: [`gnomAD`](https://gnomad.broadinstitute.org/)

5. Variant ranking:

The different steps and corresponding tools are represented in the flowchart below. Note that this chart is meant as a tool to help with coordination during pipeline development and hence is modified regularly. Some tools might be added or removed as suitable. If you would like to modify the flowchart, please contact us on the slack channel (see "Contributions and Support" further down).

<img src="https://docs.google.com/drawings/d/e/2PACX-1vTam7xjHBQTo1QsOpMUpd5F2vUZK5aXuf51OpSBaaV_2xMwfS1oN6GgVeQEJHjNNXRtCVHdGjCVFyzO/pub?w=2268&amp;h=2268">

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=21.10.3`)

2. Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility _(please only use [`Conda`](https://conda.io/miniconda.html) as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_

3. Download the pipeline and test it on a minimal dataset with a single command:

    ```console
    nextflow run nf-core/raredisease -revision dev -profile test,YOURPROFILE --outdir <OUTDIR>
    ```

    Note that some form of configuration will be needed so that Nextflow knows how to fetch the required software. This is usually done in the form of a config profile (`YOURPROFILE` in the example command above). You can chain multiple config profiles in a comma-separated string.

    > * The pipeline comes with config profiles called `docker`, `singularity`, `podman`, `shifter`, `charliecloud` and `conda` which instruct the pipeline to use the named tool for software management. For example, `-profile test,docker`.
    > * Please check [nf-core/configs](https://github.com/nf-core/configs#documentation) to see if a custom config file to run nf-core pipelines already exists for your Institute. If so, you can simply use `-profile <institute>` in your command. This will enable either `docker` or `singularity` and set the appropriate execution settings for your local compute environment.
    > * If you are using `singularity`, please use the [`nf-core download`](https://nf-co.re/tools/#downloading-pipelines-for-offline-use) command to download images first, before running the pipeline. Setting the [`NXF_SINGULARITY_CACHEDIR` or `singularity.cacheDir`](https://www.nextflow.io/docs/latest/singularity.html?#singularity-docker-hub) Nextflow options enables you to store and re-use the images from a central location for future pipeline runs.
    > * If you are using `conda`, it is highly recommended to use the [`NXF_CONDA_CACHEDIR` or `conda.cacheDir`](https://www.nextflow.io/docs/latest/conda.html) settings to store the environments in a central location for future pipeline runs.

4. Start running your own analysis!

    ```console
    nextflow run nf-core/raredisease \
        --input samplesheet.csv --outdir <OUTDIR> --genome GRCh38 \
        --analysis_type <wgs|wes|mito> \
        -revision dev \
        -profile <docker/singularity/podman/shifter/charliecloud/conda/institute>
    ```

Note that the `-revision` is used because pipeline is still under development and the latest working branch is dev.

## Documentation

The nf-core/raredisease pipeline comes with documentation about the pipeline [usage](https://nf-co.re/raredisease/usage), [parameters](https://nf-co.re/raredisease/parameters) and [output](https://nf-co.re/raredisease/output).

## Credits

nf-core/raredisease was originally written by Clinical Genomics Stockholm.

Big thanks to the contributors for their extensive assistance in the development of this pipeline.

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on the [Slack `#raredisease` channel](https://nfcore.slack.com/channels/raredisease) (you can join with [this invite](https://nf-co.re/join/slack)).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use  nf-core/raredisease for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->
An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
