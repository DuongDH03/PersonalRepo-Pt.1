package com.oms.components.media.gui;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;

import com.oms.bean.Media;
import com.oms.components.abstractdata.controller.ADataPageController;
import com.oms.components.abstractdata.controller.IDataManageController;
import com.oms.components.abstractdata.gui.ADataListPane;
import com.oms.components.abstractdata.gui.ADataSinglePane;
import com.oms.components.media.book.gui.BookEditDialog;
import com.oms.components.media.controller.AdminMediaPageController;

@SuppressWarnings("serial")
public class AdminMediaListPane extends ADataListPane<Media>{
	
	public AdminMediaListPane(ADataPageController<Media> controller) {
		this.controller = controller;
	}
	
	@Override
	public void decorateSinglePane(ADataSinglePane<Media> singlePane) {
		JButton button = new JButton("Edit");
		singlePane.addDataHandlingComponent(button);
		
		IDataManageController<Media> manageController = new IDataManageController<Media>() {
			@Override
			public void update(Media t) {
				if (controller instanceof AdminMediaPageController) {
					Media newMedia = ((AdminMediaPageController) controller).updateMedia(t);
					singlePane.updateData(newMedia);
				}
			}

			@Override
			public void create(Media t) {
			}

			@Override
			public void read(Media t) {
			}

			@Override
			public void delete(Media t) {
				
			}
		};
		
		button.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				new BookEditDialog(singlePane.getData(), manageController);
			}
		});	
	}
}
