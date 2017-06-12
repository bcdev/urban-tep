#!/bin/bash

exec java -cp "$CALVALUS_INST/etc:$CALVALUS_INST/lib/calvalus-extractor.jar" com.bc.calvalus.extractor.ExtractCalvalusReport start
