configfile: "config.yaml"

rule all:
    input:
        expand("{sample}/percolator/percolator.target.psms.txt", sample=config["data"])
    # lambda wildcards: config["MSDATA"][wildcards.sample]

rule MS_Search:
    input: mzml = lambda wildcards: config["data"][wildcards.timepoint]
    output:
        psms="{timepoint}/percolator/percolator.target.psms.txt"
    log: "{timepoint}/comet.log"
    # threads: config["threads"]["comet"]
    benchmark: "{timepoint}/comet.benchmark.txt"
    params:
        comet=config["paths"]["comet"],
        percolator=config["paths"]["percolator"],
        comet_params=config["paths"]["comet_params"],
        fasta=config["paths"]["fasta"]
    shell: #
        """
        {params.comet} -P{params.comet_params} -D{params.fasta} {input}/*.mzML 1>> {log}
        {params.percolator} --protein T {input}/*.pep.xml --decoy-prefix DECOY_ \\
         --overwrite T --output-dir {wildcards.timepoint}/percolator \\
         --spectral-counting-fdr 0.01 --maxiter 15 1>> {log} 2>>{log}
        """

