package com.bc.tep.wps;

import com.bc.tep.wps.exceptions.JobNotFoundException;
import com.bc.tep.wps.exceptions.ProcessorNotFoundException;
import com.bc.tep.wps.operations.UtepDescribeProcessOperation;
import com.bc.tep.wps.operations.UtepExecuteOperation;
import com.bc.tep.wps.operations.UtepGetCapabilitiesOperation;
import com.bc.tep.wps.operations.UtepGetStatusOperation;
import com.bc.wps.api.WpsRequestContext;
import com.bc.wps.api.WpsServiceInstance;
import com.bc.wps.api.exceptions.WpsServiceException;
import com.bc.wps.api.schema.Capabilities;
import com.bc.wps.api.schema.Execute;
import com.bc.wps.api.schema.ExecuteResponse;
import com.bc.wps.api.schema.ProcessDescriptionType;
import com.bc.wps.utilities.WpsLogger;

import javax.xml.bind.JAXBException;
import javax.xml.datatype.DatatypeConfigurationException;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author hans
 */
public class UtepWpsProvider implements WpsServiceInstance {

    private Logger logger = WpsLogger.getLogger();

    @Override
    public Capabilities getCapabilities(WpsRequestContext wpsRequestContext) throws WpsServiceException {
        logger.log(Level.INFO, "processing GetCapabilities request for user : " + wpsRequestContext.getUserName());
        UtepGetCapabilitiesOperation getCapabilitiesOperation = new UtepGetCapabilitiesOperation();
        try {
            return getCapabilitiesOperation.getCapabilities();
        } catch (JAXBException exception) {
            logger.log(Level.SEVERE, "Unable to perform GetCapabilities operation successfully", exception);
            throw new WpsServiceException(exception);
        }
    }

    @Override
    public List<ProcessDescriptionType> describeProcess(WpsRequestContext wpsRequestContext, String processId) throws WpsServiceException {
        logger.log(Level.INFO, "processing DescribeProcess request for user : " + wpsRequestContext.getUserName());
        UtepDescribeProcessOperation describeProcessOperation = new UtepDescribeProcessOperation();
        try {
            return describeProcessOperation.getProcesses(processId);
        } catch (IOException exception) {
            logger.log(Level.SEVERE, "Unable to perform DescribeProcess operation successfully", exception);
            throw new WpsServiceException(exception);
        }
    }

    @Override
    public ExecuteResponse doExecute(WpsRequestContext wpsRequestContext, Execute execute) throws WpsServiceException {
        logger.log(Level.INFO, "processing Execute request for user : " + wpsRequestContext.getUserName());
        UtepExecuteOperation executeOperation = new UtepExecuteOperation();
        try {
            return executeOperation.doExecute(execute, wpsRequestContext);
        } catch (IOException | ProcessorNotFoundException exception) {
            logger.log(Level.SEVERE, "Unable to perform Execute operation successfully", exception);
            throw new WpsServiceException(exception);
        }
    }

    @Override
    public ExecuteResponse getStatus(WpsRequestContext wpsRequestContext, String jobId) throws WpsServiceException {
        logger.log(Level.INFO, "processing GetStatus request for user : " + wpsRequestContext.getUserName());
        UtepGetStatusOperation getStatusOperation = new UtepGetStatusOperation();
        try {
            return getStatusOperation.getStatus(jobId);
        } catch (JobNotFoundException | DatatypeConfigurationException exception) {
            logger.log(Level.SEVERE, "Unable to perform GetStatus operation successfully", exception);
            throw new WpsServiceException(exception);
        }
    }

    @Override
    public void dispose() {

    }
}
