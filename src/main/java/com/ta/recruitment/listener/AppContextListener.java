package com.ta.recruitment.listener;

import com.ta.recruitment.model.DataStore;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/**
 * Initializes the DataStore when the application starts.
 */
@WebListener
public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext ctx = sce.getServletContext();
        // Store data files in WEB-INF/data/
        String dataPath = ctx.getRealPath("/WEB-INF/data");
        if (dataPath == null) {
            // Fallback to temp directory
            dataPath = System.getProperty("java.io.tmpdir") + "/ta-recruitment-data";
        }
        ctx.log("Initializing DataStore at: " + dataPath);
        DataStore.getInstance().init(dataPath);
        ctx.log("DataStore initialized successfully.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Nothing to clean up
    }
}
