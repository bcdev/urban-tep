package com.bc.tep.wps.operations;

import com.bc.tep.wps.ExecuteRequestExtractor;
import com.bc.tep.wps.GpfProductionService;
import com.bc.tep.wps.ProductionState;
import com.bc.tep.wps.ProductionStatus;
import com.bc.tep.wps.UtepExecuteResponse;
import com.bc.tep.wps.exceptions.MissingInputParameterException;
import com.bc.tep.wps.exceptions.ProcessorNotFoundException;
import com.bc.tep.wps.processes.UtepProcess;
import com.bc.tep.wps.processes.UtepProcessBuilder;
import com.bc.tep.wps.processes.UtepProcessFactory;
import com.bc.wps.api.WpsRequestContext;
import com.bc.wps.api.WpsServerContext;
import com.bc.wps.api.exceptions.WpsServiceException;
import com.bc.wps.api.schema.Execute;
import com.bc.wps.api.schema.ExecuteResponse;
import com.bc.wps.api.schema.ResponseDocumentType;
import com.bc.wps.api.schema.ResponseFormType;
import com.bc.wps.utilities.PropertiesWrapper;
import com.bc.wps.utilities.WpsLogger;
import org.esa.beam.framework.dataio.ProductIO;
import org.esa.beam.framework.datamodel.Product;
import org.esa.beam.framework.gpf.GPF;
import org.esa.beam.framework.gpf.OperatorException;
import org.esa.beam.util.StringUtils;
import org.esa.cci.lc.subset.PredefinedRegion;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

/**
 * @author hans
 */
public class UtepExecuteOperation {

    private static final String CATALINA_BASE = System.getProperty("catalina.base");
    private Logger logger = WpsLogger.getLogger();

    public ExecuteResponse doExecute(Execute executeRequest, WpsRequestContext requestContext)
                throws WpsServiceException, IOException, OperatorException, ProcessorNotFoundException {

        WpsServerContext serverContext = requestContext.getServerContext();
        ResponseFormType responseFormType = executeRequest.getResponseForm();
        ResponseDocumentType responseDocumentType = responseFormType.getResponseDocument();
        boolean isAsynchronous = responseDocumentType.isStatus();
        boolean isLineage = responseDocumentType.isLineage();
        String processId = executeRequest.getIdentifier().getValue();

        ExecuteRequestExtractor requestExtractor = new ExecuteRequestExtractor(executeRequest);
        Map<String, String> inputParameters = requestExtractor.getInputParametersMap();

        GPF.getDefaultInstance().getOperatorSpiRegistry().loadOperatorSpis();

        final Product sourceProduct = getSourceProduct(inputParameters);
        String jobId = GpfProductionService.createJobId(requestContext.getUserName());
        Path targetDirPath = getTargetDirectoryPath(jobId);
        HashMap<String, Object> parameters = getSubsettingParameters(inputParameters, targetDirPath);
        UtepExecuteResponse executeResponse = new UtepExecuteResponse();
        UtepProcessBuilder processBuilder = UtepProcessBuilder.create()
                    .withJobId(jobId)
                    .withParameters(parameters)
                    .withSourceProduct(sourceProduct)
                    .withTargetDirPath(targetDirPath)
                    .withServerContext(serverContext)
                    .withExecuteRequest(executeRequest);
        UtepProcess UtepProcess = UtepProcessFactory.getProcessor(processId);

        if (isAsynchronous) {
            ProductionStatus status = UtepProcess.processAsynchronous(processBuilder);
            if (isLineage) {
                return UtepProcess.createLineageAsyncExecuteResponse(status, processBuilder);
            }
            return executeResponse.getAcceptedResponse(status, serverContext);
        } else {
            ProductionStatus status = UtepProcess.processSynchronous(processBuilder);
            if (status.getState() != ProductionState.SUCCESSFUL) {
                return executeResponse.getFailedResponse(status);
            }
            if (isLineage) {
                return UtepProcess.createLineageSyncExecuteResponse(status, processBuilder);
            }
            return executeResponse.getSuccessfulResponse(status);
        }
    }

    private HashMap<String, Object> getSubsettingParameters(Map<String, String> inputParameters, Path targetDirPath)
                throws MissingInputParameterException {
        HashMap<String, Object> parameters = new HashMap<>();
        parameters.put("targetDir", targetDirPath.toString());
        String predefinedRegionName = inputParameters.get("predefinedRegion");
        PredefinedRegion predefinedRegion = null;
        for (PredefinedRegion region : PredefinedRegion.values()) {
            if (region.name().equals(predefinedRegionName)) {
                predefinedRegion = region;
            }
        }
        if (predefinedRegion != null) {
            parameters.put("predefinedRegion", predefinedRegion);
        } else if (StringUtils.isNotNullAndNotEmpty(inputParameters.get("north")) &&
                   StringUtils.isNotNullAndNotEmpty(inputParameters.get("west")) &&
                   StringUtils.isNotNullAndNotEmpty(inputParameters.get("east")) &&
                   StringUtils.isNotNullAndNotEmpty(inputParameters.get("south"))) {
            parameters.put("north", inputParameters.get("north"));
            parameters.put("west", inputParameters.get("west"));
            parameters.put("east", inputParameters.get("east"));
            parameters.put("south", inputParameters.get("south"));
        } else {
            throw new MissingInputParameterException("The region is not properly defined in the request.");
        }
        return parameters;
    }

    private Path getTargetDirectoryPath(String jobId) throws IOException {
        Path targetDirectoryPath = Paths.get(CATALINA_BASE + PropertiesWrapper.get("wps.application.path")
                                             + "/" + PropertiesWrapper.get("utep.output.directory"),
                                             jobId);
        Files.createDirectories(targetDirectoryPath);
        return targetDirectoryPath;
    }

    private Product getSourceProduct(Map<String, String> inputParameters) throws IOException {
        final Product sourceProduct;
        Path dir = Paths.get(CATALINA_BASE + PropertiesWrapper.get("wps.application.path"), PropertiesWrapper.get("utep.input.directory"));
        List<File> files = new ArrayList<>();
        DirectoryStream<Path> stream = Files.newDirectoryStream(dir, inputParameters.get("sourceProduct"));
        for (Path entry : stream) {
            files.add(entry.toFile());
        }

        String sourceProductPath;
        if (files.size() != 0) {
            sourceProductPath = files.get(0).getAbsolutePath();
        } else {
            throw new FileNotFoundException("The source product '" + inputParameters.get("sourceProduct") + "' cannot be found");
        }

        sourceProduct = ProductIO.readProduct(sourceProductPath);
        return sourceProduct;
    }
}
