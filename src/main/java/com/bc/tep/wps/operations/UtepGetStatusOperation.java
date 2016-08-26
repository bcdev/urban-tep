package com.bc.tep.wps.operations;

import com.bc.tep.wps.GpfProductionService;
import com.bc.tep.wps.ProductionState;
import com.bc.tep.wps.ProductionStatus;
import com.bc.tep.wps.UtepExecuteResponse;
import com.bc.tep.wps.exceptions.JobNotFoundException;
import com.bc.wps.api.schema.ExecuteResponse;

import javax.xml.datatype.DatatypeConfigurationException;

/**
 * @author hans
 */
public class UtepGetStatusOperation {

    public ExecuteResponse getStatus(String jobId) throws JobNotFoundException, DatatypeConfigurationException {
        ProductionStatus status = GpfProductionService.getProductionStatusMap().get(jobId);
        if (status != null) {
            if (status.getState() == ProductionState.SUCCESSFUL) {
                return getExecuteSuccessfulResponse(status);
            } else if (status.getState() == ProductionState.FAILED) {
                return getExecuteFailedResponse(status);
            } else {
                return getExecuteInProgressResponse(status);
            }
        } else {
            throw new JobNotFoundException("Unable to retrieve the job with jobId '" + jobId + "'.");
        }
    }

    private ExecuteResponse getExecuteInProgressResponse(ProductionStatus status) throws DatatypeConfigurationException {
        UtepExecuteResponse executeResponse = new UtepExecuteResponse();
        return executeResponse.getStartedResponse(status);
    }

    private ExecuteResponse getExecuteFailedResponse(ProductionStatus status) throws DatatypeConfigurationException {
        UtepExecuteResponse executeResponse = new UtepExecuteResponse();
        return executeResponse.getFailedResponse(status);
    }

    private ExecuteResponse getExecuteSuccessfulResponse(ProductionStatus status) throws DatatypeConfigurationException {
        UtepExecuteResponse executeResponse = new UtepExecuteResponse();
        return executeResponse.getSuccessfulResponse(status);
    }


}
