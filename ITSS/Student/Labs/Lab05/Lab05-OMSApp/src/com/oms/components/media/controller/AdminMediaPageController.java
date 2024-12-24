package com.oms.components.media.controller;

import com.oms.bean.Media;
import com.oms.components.abstractdata.controller.ADataPageController;
import com.oms.components.abstractdata.gui.ADataListPane;
import com.oms.components.media.gui.AdminMediaListPane;

public abstract class AdminMediaPageController extends ADataPageController<Media> {
	public AdminMediaPageController() {
		super();
	}
	
	@Override
	public ADataListPane<Media> createListPane() {
		return new AdminMediaListPane(this);
	}
	
	public abstract Media updateMedia(Media media);
	
}
