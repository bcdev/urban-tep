package com.bc.tep.wps.processes;


import com.bc.tep.wps.exceptions.ProcessorNotFoundException;

/**
 * @author hans
 */
public class UtepProcessFactory {

    public static UtepProcess getProcessor(String processId) throws ProcessorNotFoundException {
        if ("subsetting".equals(processId)) {
            return new UtepSubsettingProcess();
        } else {
            throw new ProcessorNotFoundException(processId);
        }
    }

}
