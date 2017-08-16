=pod

=head1 NAME

    Hive::PipeConfig::RunVerifyBAMID_conf.pm

=head1 SYNOPSIS

    init_pipeline.pl Hive::PipeConfig::RunVerifyBAMID_conf -inputfile file_list -work_dir dir_name -db reseqtrack_db_name -pwd db_pwd


=cut


package Hive::PipeConfig::RunVerifyBAMID_conf;

use strict;
use warnings;

use base ('Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf');  # All Hive databases configuration files should inherit from HiveGeneric, directly or indirectly


sub default_options {
    my ($self) = @_;
    return {
        %{ $self->SUPER::default_options() },               # inherit other stuff from the base class

        'pipeline_name' => 'run_verifybamid',                   # name used by the beekeeper to prefix job names on the farm

        # runnable-specific parameters' defaults:
        'hostname'   => 'mysql-g1kdcc-public',
        'username'     => 'g1krw',
        'port'        => 4197,
	'db' => undef,
	'pwd' => undef,
        'work_dir'    => undef,
	'final_dir' => undef,
	'python_folder' => '/nfs/production/reseq-info/work/ernesto/bin/anaconda3/bin/',
	'script_folder' => '/homes/ernesto/lib/reseq-personal/ernesto/igsr/BamQC/src/',
	'verifybamid_folder' => '/nfs/production/reseq-info/work/bin/verifyBamID_1.1.3/verifyBamID/bin/',
        'lsf_queue'   => 'production-rh7',
    };
}


sub pipeline_create_commands {
    my ($self) = @_;
    return [
        @{$self->SUPER::pipeline_create_commands},  # inheriting database and hive tables' creation

        'mkdir -p '.$self->o('work_dir'),
    ];
}

sub resource_classes {
  my ($self) = @_;
    return {
          %{$self->SUPER::resource_classes},
	  '500Mb' => { 'LSF' => '-C0 -M512 -q '.$self->o('lsf_queue').' -R"select[mem>512] rusage[mem=512]"' },
	  '1Gb' => { 'LSF' => '-C0 -M1024 -q '.$self->o('lsf_queue').' -R"select[mem>1024] rusage[mem=1024]"' },
	  '2Gb' => { 'LSF' => '-C0 -M2048 -q '.$self->o('lsf_queue').' -R"select[mem>2048] rusage[mem=2048]"' },
    };
}

sub hive_meta_table {
  my ($self) = @_;
  return {
    %{$self->SUPER::hive_meta_table},
    'hive_use_param_stack' => 1,
   };
}

sub pipeline_analyses {
    my ($self) = @_;
    return [
        {   -logic_name => 'find_files',
            -module     => 'Bio::EnsEMBL::Hive::RunnableDB::JobFactory',
            -parameters => {
                'inputcmd'     => 'cat #file#',
                'column_names' => [ 'filename' ],
            },
            -flow_into => {
                2  =>  [ 'analyze_bam' ]
            },
        },

        {   -logic_name => 'analyze_bam',
            -module        => 'Bio::EnsEMBL::Hive::RunnableDB::SystemCmd',
            -parameters    => {
		'hostname' => $self->o('hostname'),
		'username' => $self->o('username'),
		'port' => $self->o('port'),
		'db' => $self->o('db'),
		'pwd' => $self->o('pwd'),
		'genotype_folder' => $self->o('genotype_folder'),
		'prefix' => $self->o('prefix'),
		'python_folder' => $self->o('python_folder'),
		'script_folder' => $self->o('script_folder'),
		'verifybamid_folder' => $self->o('verifybamid_folder'),
		'final_dir' => $self->o('final_dir'),
                'cmd'       => '#python_folder#/python #script_folder#/run_verifybamid.py --hostname #hostname# --username #username# --port #port# --pwd #pwd# --db #db# --exe #verifybamid_folder# --filename #filename# --outdir #final_dir# --genotypes #genotype_folder# --prefix #prefix#',
            },
            -analysis_capacity => 200,
            -rc_name => '500Mb'
        },
    ];
}

1;
