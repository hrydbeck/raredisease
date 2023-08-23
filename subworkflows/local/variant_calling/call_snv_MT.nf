//
// Call SNV MT
//

include { HAPLOCHECK as HAPLOCHECK_MT                                       } from '../../../modules/nf-core/haplocheck/main'
include { GATK4_MUTECT2 as GATK4_MUTECT2_MT                                 } from '../../../modules/nf-core/gatk4/mutect2/main'
include { GATK4_FILTERMUTECTCALLS as  GATK4_FILTERMUTECTCALLS_MT            } from '../../../modules/nf-core/gatk4/filtermutectcalls/main'
include { MT_DELETION                                                       } from '../../../modules/local/mt_deletion_script'
include { EKLIPSE as EKLIPSE_MT                                             } from '../../../modules/nf-core/eklipse/main'

workflow CALL_SNV_MT {
    take:
        ch_bam_bai    // channel: [mandatory] [ val(meta), path(bam), path(bai) ]
        ch_fasta      // channel: [mandatory] [ val(meta), path(fasta) ]
        ch_fai        // channel: [mandatory] [ val(meta), path(fai) ]
        ch_dict       // channel: [mandatory] [ val(meta), path(dict) ]
        ch_intervals  // channel: [mandatory] [ path(interval_list) ]

    main:
        ch_versions = Channel.empty()

        ch_bam_bai_int = ch_bam_bai.combine(ch_intervals)

        GATK4_MUTECT2_MT (ch_bam_bai_int, ch_fasta, ch_fai, ch_dict, [], [], [],[])

        HAPLOCHECK_MT (GATK4_MUTECT2_MT.out.vcf)

        // Filter Mutect2 calls
        ch_mutect_vcf = GATK4_MUTECT2_MT.out.vcf.join(GATK4_MUTECT2_MT.out.tbi, failOnMismatch:true, failOnDuplicate:true)
        ch_mutect_out = ch_mutect_vcf.join(GATK4_MUTECT2_MT.out.stats, failOnMismatch:true, failOnDuplicate:true)
        ch_to_filt    = ch_mutect_out.map {
                            meta, vcf, tbi, stats ->
                            return [meta, vcf, tbi, stats, [], [], [], []]
                        }

        GATK4_FILTERMUTECTCALLS_MT (ch_to_filt, ch_fasta, ch_fai, ch_dict)

        ch_versions = ch_versions.mix(GATK4_MUTECT2_MT.out.versions.first())
        ch_versions = ch_versions.mix(HAPLOCHECK_MT.out.versions.first())
        ch_versions = ch_versions.mix(GATK4_FILTERMUTECTCALLS_MT.out.versions.first())

    emit:
        vcf            = GATK4_FILTERMUTECTCALLS_MT.out.vcf   // channel: [ val(meta), path(vcf) ]
        tbi            = GATK4_FILTERMUTECTCALLS_MT.out.tbi   // channel: [ val(meta), path(tbi) ]
        stats          = GATK4_MUTECT2_MT.out.stats           // channel: [ val(meta), path(stats) ]
        filt_stats     = GATK4_FILTERMUTECTCALLS_MT.out.stats // channel: [ val(meta), path(tsv) ]
        txt            = HAPLOCHECK_MT.out.txt                // channel: [ val(meta), path(txt) ]
        html           = HAPLOCHECK_MT.out.html               // channel: [ val(meta), path(html) ]
        versions       = ch_versions                          // channel: [ path(versions.yml) ]
}
