package com.bc.tep.wps.processes;

import com.bc.tep.wps.GpfProductionService;
import com.bc.tep.wps.GpfTask;
import com.bc.tep.wps.ProductionState;
import com.bc.tep.wps.ProductionStatus;
import com.bc.tep.wps.UtepExecuteResponse;
import com.bc.wps.api.schema.DocumentOutputDefinitionType;
import com.bc.wps.api.schema.ExecuteResponse;
import com.bc.wps.utilities.WpsLogger;
import org.esa.beam.framework.gpf.GPF;
import org.esa.beam.framework.gpf.OperatorException;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author hans
 */
public class UtepSubsettingProcess implements UtepProcess {

    private Logger logger = WpsLogger.getLogger();

    @Override
    public ProductionStatus processAsynchronous(UtepProcessBuilder processBuilder) {
        logger.log(Level.INFO, "[" + processBuilder.getJobId() + "] starting asynchronous process...");
        ProductionStatus status = new ProductionStatus(processBuilder.getJobId(), ProductionState.ACCEPTED, 0, "The request has been queued.", null);
        GpfProductionService.getProductionStatusMap().put(processBuilder.getJobId(), status);
        GpfTask gpfTask = new GpfTask(processBuilder.getJobId(),
                                      processBuilder.getParameters(),
                                      processBuilder.getSourceProduct(),
                                      processBuilder.getTargetDirPath().toFile(),
                                      processBuilder.getServerContext().getHostAddress(),
                                      processBuilder.getServerContext().getPort());
        GpfProductionService.getWorker().submit(gpfTask);
        logger.log(Level.INFO, "[" + processBuilder.getJobId() + "] job has been queued...");
        return status;
    }

    @Override
    public ProductionStatus processSynchronous(UtepProcessBuilder processBuilder) {
        try {
            logger.log(Level.INFO, "[" + processBuilder.getJobId() + "] starting synchronous process...");
            GPF.createProduct("LCCCI.Subset", processBuilder.getParameters(), processBuilder.getSourceProduct());

            logger.log(Level.INFO, "[" + processBuilder.getJobId() + "] constructing result URLs...");
            List<String> resultUrls = GpfProductionService.getProductUrls(processBuilder.getServerContext().getHostAddress(),
                                                                          processBuilder.getServerContext().getPort(),
                                                                          processBuilder.getTargetDirPath().toFile());
            logger.log(Level.INFO, "[" + processBuilder.getJobId() + "] job has been completed, creating successful response...");
            return new ProductionStatus(processBuilder.getJobId(),
                                        ProductionState.SUCCESSFUL,
                                        100,
                                        "The request has been processed successfully.",
                                        resultUrls);
        } catch (OperatorException exception) {
            return new ProductionStatus(processBuilder.getJobId(),
                                        ProductionState.FAILED,
                                        0,
                                        "Processing failed : " + exception.getMessage(),
                                        null);
        }
    }

    @Override
    public ExecuteResponse createLineageAsyncExecuteResponse(ProductionStatus status, UtepProcessBuilder processBuilder) {
        UtepExecuteResponse executeAcceptedResponse = new UtepExecuteResponse();
        List<DocumentOutputDefinitionType> outputType = processBuilder.getExecuteRequest().getResponseForm().getResponseDocument().getOutput();
        return executeAcceptedResponse.getAcceptedWithLineageResponse(status, processBuilder.getExecuteRequest().getDataInputs(),
                                                                      outputType, processBuilder.getServerContext());
    }

    @Override
    public ExecuteResponse createLineageSyncExecuteResponse(ProductionStatus status, UtepProcessBuilder processBuilder) {
        UtepExecuteResponse executeSuccessfulResponse = new UtepExecuteResponse();
        List<DocumentOutputDefinitionType> outputType = processBuilder.getExecuteRequest().getResponseForm().getResponseDocument().getOutput();
        return executeSuccessfulResponse.getSuccessfulWithLineageResponse(status, processBuilder.getExecuteRequest().getDataInputs(), outputType);
    }
}
