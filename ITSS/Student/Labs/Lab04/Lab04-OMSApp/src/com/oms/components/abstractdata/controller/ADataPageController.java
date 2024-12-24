package com.oms.components.abstractdata.controller;

import java.util.List;
import java.util.Map;

import javax.swing.JPanel;

import com.oms.components.abstractdata.gui.ADataListPane;
import com.oms.components.abstractdata.gui.DataPagePane;
import com.oms.components.abstractdata.gui.ADataSearchPane;
import com.oms.components.abstractdata.gui.ADataSinglePane;

public abstract class ADataPageController<T> {
	private DataPagePane<T> pagePane;
	
	public ADataPageController() {
		ADataSearchPane searchPane = createSearchPane();
		
		ADataListPane<T> listPane = createListPane();
		
		searchPane.setController(new IDataSearchController() {
			@Override
			public void search(Map<String, String> searchParams) {
				List<? extends T> list = ADataPageController.this.search(searchParams);
				listPane.updateData(list);
			}
		});
		
		searchPane.fireSearchEvent();
		
		pagePane = new DataPagePane<T>(searchPane, listPane);
	}
	
	public JPanel getDataPagePane() {
		return pagePane;
	}
	
	
	public abstract ADataSearchPane createSearchPane();

	public abstract List<? extends T> search(Map<String, String> searchParams);
	
	
	
	public abstract ADataSinglePane<T> createSinglePane();
	
	public abstract ADataListPane<T> createListPane();
}
