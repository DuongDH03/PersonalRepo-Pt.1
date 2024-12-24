package com.oms.components.media.gui;

import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JSpinner;
import javax.swing.SpinnerNumberModel;

import com.oms.bean.Media;
import com.oms.components.abstractdata.controller.ADataPageController;
import com.oms.components.abstractdata.gui.ADataListPane;
import com.oms.components.abstractdata.gui.ADataSinglePane;
import com.oms.components.media.controller.UserMediaPageController;

@SuppressWarnings("serial")
public class UserMediaListPane extends ADataListPane<Media>{
	
	public UserMediaListPane(ADataPageController<Media> controller) {
		this.controller = controller;
	}
	

	@Override
	public void decorateSinglePane(ADataSinglePane<Media> singlePane) {
		JSpinner spin = new JSpinner();
		spin.setModel(new SpinnerNumberModel(1, 0, null, 1));
		singlePane.addDataHandlingComponent(spin);
		spin.setPreferredSize(new Dimension(100, 20));
		
		JButton button = new JButton("Add to cart");
		singlePane.addDataHandlingComponent(button);
		
		button.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				if (controller instanceof UserMediaPageController) {
					((UserMediaPageController) controller).addToCart(singlePane.getData().getId(), singlePane.getData().getTitle(), singlePane.getData().getCost(), (int)spin.getValue());
				}
			}
		});
	}
}
