package cart;

import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;

@SuppressWarnings("serial")
public class CartPane extends JPanel{
	private JLabel cartStatusLabel;
	private CartController controller;
	
	public CartPane() {
		this.setLayout(new FlowLayout(FlowLayout.RIGHT));
		cartStatusLabel = new JLabel();
		this.add(cartStatusLabel);
		JButton detailButton = new JButton("Detail");
		this.add(detailButton);
		
		
		detailButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				controller.showCartDialog();
			}
		});
	}
	
	public void setController(CartController controller) {
		this.controller = controller;
	}
	
	public void updateData(String text) {
		cartStatusLabel.setText(text);
	}
}