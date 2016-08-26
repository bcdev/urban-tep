package com.bc.tep.wps.processes;

import com.bc.tep.wps.ProductionStatus;
import com.bc.wps.api.schema.ExecuteResponse;

/**
 * @author hans
 */
public interface UtepProcess {

    ProductionStatus processAsynchronous(UtepProcessBuilder processBuilder);

    ProductionStatus processSynchronous(UtepProcessBuilder processBuilder);

    ExecuteResponse createLineageAsyncExecuteResponse(ProductionStatus status, UtepProcessBuilder processBuilder);

    ExecuteResponse createLineageSyncExecuteResponse(ProductionStatus status, UtepProcessBuilder processBuilder);

}
