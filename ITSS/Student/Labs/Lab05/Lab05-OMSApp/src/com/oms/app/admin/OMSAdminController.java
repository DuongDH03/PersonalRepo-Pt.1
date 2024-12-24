package com.oms.app.admin;

import javax.swing.JPanel;

import com.oms.bean.Media;
import com.oms.components.abstractdata.controller.ADataPageController;
import com.oms.components.media.book.controller.AdminBookPageController;

public class OMSAdminController {
	public OMSAdminController() {
	}
	
	public JPanel getBookPage() {
		ADataPageController<Media> controller = new AdminBookPageController();
		return controller.getDataPagePane();
	}
}
