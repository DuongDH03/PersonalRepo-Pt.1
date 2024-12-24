package cart;

import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JSpinner;
import javax.swing.JTextField;
import javax.swing.SpinnerNumberModel;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import com.oms.bean.Order;
import com.oms.bean.OrderLine;

@SuppressWarnings("serial")
public class CartDialog extends JDialog{
	private GridBagLayout layout;
	private GridBagConstraints c;
	
	private JTextField customerNameField;
	private JTextField customerPhoneField;
	private JTextField customerAddressField;
	
	private CartController controller;
	
	public CartDialog() {
		layout = new GridBagLayout();
		this.setLayout(layout);
		c = new GridBagConstraints();
		
		updateData(null);
	}
	
	public void setController(CartController controller) {
		this.controller = controller;
	}
	
	public void updateData(Order order) {
		this.getContentPane().removeAll();

		c.insets = new Insets(10,0,5,0);
		c.gridx = 0;
		c.gridy = 0;
		add(new JLabel("Customer name"), c);
		c.gridx = 1;
		c.gridy = 0;
		customerNameField = new JTextField(15);
		add(customerNameField, c);
		
		c.insets = new Insets(0,0,5,0);
		c.gridx = 0;
		c.gridy = 1;
		add(new JLabel("Customer phone"), c);
		c.gridx = 1;
		c.gridy = 1;
		customerPhoneField = new JTextField(15);
		add(customerPhoneField, c);
		
		
		c.gridx = 0;
		c.gridy = 2;
		add(new JLabel("Customer address"), c);
		c.gridx = 1;
		c.gridy = 2;
		customerAddressField = new JTextField(15);
		add(customerAddressField, c);
		

		
		customerNameField.addKeyListener(new KeyAdapter() {
			@Override
			public void keyTyped(KeyEvent e) {
				order.setCustomerName(customerNameField.getText());
			}
		});
		customerPhoneField.addKeyListener(new KeyAdapter() {
			@Override
			public void keyTyped(KeyEvent e) {
				order.setCustomerPhoneNumber(customerPhoneField.getText());
			}
		});
		customerAddressField.addKeyListener(new KeyAdapter() {
			@Override
			public void keyTyped(KeyEvent e) {
				order.setCustomerAddress(customerAddressField.getText());
			}
		});
		
		
		
		if (order != null) {
			for (int i=0; i<order.getOrderLines().size(); ++i) {
				OrderLine ol = order.getOrderLines().get(i);
				
				int row = getLastRowIndex();
				c.gridx = 0;
				c.gridy = row;
				JLabel label = new JLabel(ol.getProductTitle());
				add(label, c);
				
				c.gridx = 1;
				c.gridy = row;
				JSpinner spin = new JSpinner();
				spin.setModel(new SpinnerNumberModel(ol.getProductQuantity(), 0, null, 1));
				add(spin, c);
				spin.setPreferredSize(new Dimension(190, 20));
				
				spin.addChangeListener(new ChangeListener() {
					@Override
					public void stateChanged(ChangeEvent e) {
						controller.setOrderLineQuantity(ol, (int) spin.getValue());
						
						if ((int) spin.getValue() == 0) { // Remove item with 0 quantity
							remove(spin);
							remove(label);
							pack();
						}
					}
				});
			}
			
			int row = getLastRowIndex();
			c.gridx = 0;
			c.gridy = row;
			JButton button = new JButton("Check out!");
			add(button, c);
			button.addActionListener(new ActionListener() {
				@Override
				public void actionPerformed(ActionEvent e) {
					controller.checkOut();
				}
			});
		}

		this.revalidate();
		this.repaint();
		this.pack();
		this.setResizable(false);
	}
	
	
	protected int getLastRowIndex() {
		layout.layoutContainer(this.getContentPane());
		int[][] dim = layout.getLayoutDimensions();
	    int rows = dim[1].length;
	    return rows;
	}
}