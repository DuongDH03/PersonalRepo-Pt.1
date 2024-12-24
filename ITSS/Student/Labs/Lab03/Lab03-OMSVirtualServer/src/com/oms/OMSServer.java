package com.oms;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;

import com.oms.service.BookService;
import com.oms.service.CompactDiscService;
import com.oms.service.DigitalVideoDiscService;
import com.oms.service.MediaService;

public class OMSServer {
	public static final int PORT = 8080;
	
	public static void main(String[] args) throws Exception {
		ServletContextHandler context = new ServletContextHandler(ServletContextHandler.SESSIONS);
		context.setContextPath("/");

		Server jettyServer = new Server(PORT);
		jettyServer.setHandler(context);

		ServletHolder jerseyServlet = context.addServlet(org.glassfish.jersey.servlet.ServletContainer.class, "/*");
		jerseyServlet.setInitOrder(0);

		
		jerseyServlet.setInitParameter("jersey.config.server.provider.classnames",
				MediaService.class.getCanonicalName() + ", " + 
				BookService.class.getCanonicalName() + ", " +
				CompactDiscService.class.getCanonicalName() + ", " +
				DigitalVideoDiscService.class.getCanonicalName()
		);

		
		try {
			jettyServer.start();
			jettyServer.join();
		} finally {
			jettyServer.destroy();
		}
	}
}