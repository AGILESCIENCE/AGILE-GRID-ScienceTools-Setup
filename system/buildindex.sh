#!/bin/bash

# Copyright (c) 2016, AGILE team
# Authors: Andrea Zoli <zoli@iasfbo.inaf.it>
#
# Any information contained in this software is property of the AGILE TEAM
# and is strictly private and confidential. All rights reserved.

log_index=/ASDC_PROC2/DATA_2/INDEX/LOG.log.index
$AGILE/bin/AG_indexgen /ASDC_PROC2/DATA_2/LOG LOG ${log_index}_tmp
sort -k3 ${log_index}_tmp -o ${log_index}_tmp
mv ${log_index}_tmp ${log_index}

evt_index=/ASDC_PROC2/FM3.119_2/INDEX/EVT.index
$AGILE/bin/AG_indexgen /ASDC_PROC2/FM3.119_2/EVT EVT ${evt_index}_tmp
sort -k3 ${evt_index}_tmp -o ${evt_index}_tmp
mv ${evt_index}_tmp ${evt_index}
