process squirrel {
label "squirrel"
    cpus params.squirrel_threads

    publishDir "${params.outdir}/${task.process.replaceAll(":","_")}", pattern: "squirrel/all_consensus.aln.fa", mode: 'copy'
    publishDir "${params.outdir}/${task.process.replaceAll(":","_")}", pattern: "squirrel", mode: 'copy'

    container "docker.io/articnetworkorg/squirrel@sha256:f855d4c43063845de22fdebd9d0a0a4b51a034ed276980e17a01335d658d79f5"

    input:
        path fasta
        path refs
    output:
        path "squirrel/all_consensus.aln.fasta", emit: alignment
        path "squirrel", emit: all
        path "squirrel.version", emit: version

  script:
    extra = ""
    if ( params.squirrel_assembly_refs )
        extra += " --assembly-refs ${refs}"
    if ( params.clade )
        extra += " --clade ${params.clade}"
    if ( params.run_phylo )
        extra += " --run-phylo"
    if ( params.outgroups )
        extra += " --outgroups ${params.outgroups}"

    """
    XDG_CACHE_HOME=\$PWD/.cache
    squirrel --version 2>&1 | sed 's/: /,/' > squirrel.version
    squirrel ${fasta} --seq-qc -o squirrel_output --outfile all_consensus.aln.fasta --tempdir squirrel_tmp -t ${task.cpus} ${extra}
    """
}