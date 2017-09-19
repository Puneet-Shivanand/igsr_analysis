import os
import pytest
import subprocess
import glob
from VcfIntegration import VcfIntegration

# test_runBeagle.py

@pytest.fixture
def clean_tmp():
    yield
    print("Cleanup files")
    files = glob.glob('data/outdir/*')
    for f in files:
        os.remove(f)

def test_runBeagle():
    vcf_f= pytest.config.getoption("vcf")
    beagle_folder=pytest.config.getoption("beagle_folder")
    hive_scripts= pytest.config.getoption("hive_lib")+"/scripts/" 
    work_dir= "data/outdir"

    command="perl {0}/standaloneJob.pl PyHive.VcfIntegration.run_Beagle -language python3 -vcf_file {1} -beagle_folder {2} -work_dir {3} -outprefix {4} \
             -window {5} -overlap {6} -niterations {7} -nthreads {8} -region_chunk {9} -verbose True".format(hive_scripts, vcf_f, beagle_folder, work_dir, 
                                                                                                             'test', 12000, 2000, 15, 1, 'chr20:1000000-1000150')
    try:
        subprocess.check_output(command, shell=True)
        assert True
    except subprocess.CalledProcessError as exc:
        assert False
        raise Exception(exc.output)
    
def test_runBeagle_noparams(clean_tmp):
    vcf_f= pytest.config.getoption("vcf")
    beagle_folder=pytest.config.getoption("beagle_folder")
    hive_scripts= pytest.config.getoption("hive_lib")+"/scripts/"
    work_dir= "data/outdir"

    command="perl {0}/standaloneJob.pl PyHive.VcfIntegration.run_Beagle -language python3 -vcf_file {1} -beagle_folder {2} -work_dir {3} -outprefix {4} \
             -region_chunk {5} -verbose True".format(hive_scripts, vcf_f, beagle_folder, work_dir,
                                                     'test', 'chr20:1000000-1000150')
    try:
        subprocess.check_output(command, shell=True)
        assert True
    except subprocess.CalledProcessError as exc:
        assert False
        raise Exception(exc.output)