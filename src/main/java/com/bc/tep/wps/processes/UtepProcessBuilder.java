package com.bc.tep.wps.processes;

import com.bc.wps.api.WpsServerContext;
import com.bc.wps.api.schema.Execute;
import org.esa.beam.framework.datamodel.Product;

import java.nio.file.Path;
import java.util.Map;

/**
 * @author hans
 */
public class UtepProcessBuilder {

    private String jobId;
    private Map<String, Object> parameters;
    private Product sourceProduct;
    private Path targetDirPath;
    private WpsServerContext serverContext;
    private Execute executeRequest;

    public static UtepProcessBuilder create() {
        return new UtepProcessBuilder();
    }

    public String getJobId() {
        return jobId;
    }

    public UtepProcessBuilder withJobId(String jobId) {
        this.jobId = jobId;
        return this;
    }

    public Map<String, Object> getParameters() {
        return parameters;
    }

    public UtepProcessBuilder withParameters(Map<String, Object> parameters) {
        this.parameters = parameters;
        return this;
    }

    public Product getSourceProduct() {
        return sourceProduct;
    }

    public UtepProcessBuilder withSourceProduct(Product sourceProduct) {
        this.sourceProduct = sourceProduct;
        return this;
    }

    public Path getTargetDirPath() {
        return targetDirPath;
    }

    public UtepProcessBuilder withTargetDirPath(Path targetDirPath) {
        this.targetDirPath = targetDirPath;
        return this;
    }

    public WpsServerContext getServerContext() {
        return serverContext;
    }

    public UtepProcessBuilder withServerContext(WpsServerContext serverContext) {
        this.serverContext = serverContext;
        return this;
    }

    public Execute getExecuteRequest() {
        return executeRequest;
    }

    public UtepProcessBuilder withExecuteRequest(Execute executeRequest) {
        this.executeRequest = executeRequest;
        return this;
    }
}
