package com.bc.tep.wps;

import com.bc.wps.api.WpsServerContext;
import com.bc.wps.api.WpsServiceInstance;
import com.bc.wps.api.WpsServiceProvider;
import com.bc.wps.api.exceptions.WpsRuntimeException;
import com.bc.wps.utilities.PropertiesWrapper;

import java.io.IOException;

/**
 * @author hans
 */
public class UtepWpsSpi implements WpsServiceProvider {

    @Override
    public String getId() {
        return "utep";
    }

    @Override
    public String getName() {
        return "Urban TEP WPS Server";
    }

    @Override
    public String getDescription() {
        return "This is an Urban TEP WPS implementation";
    }

    @Override
    public WpsServiceInstance createServiceInstance(WpsServerContext wpsServerContext) {
        String propertiesFileName = "utep-wps.properties";
        try {
            PropertiesWrapper.loadConfigFile(propertiesFileName);
        } catch (IOException exception) {
            throw new WpsRuntimeException("Unable to load " + propertiesFileName + " file", exception);
        }
        return new UtepWpsProvider();
    }
}
