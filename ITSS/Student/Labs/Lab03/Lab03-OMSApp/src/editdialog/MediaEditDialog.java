package editdialog;

import javax.swing.JLabel;
import javax.swing.JTextField;

import com.oms.bean.Media;

import abstractdata.IDataManageController;

@SuppressWarnings("serial")
public class MediaEditDialog extends ADataEditDialog<Media>{
	
	private JTextField titleField;
	private JTextField categoryField;
	private JTextField costField;
	
	public MediaEditDialog(Media media, IDataManageController<Media> controller) {
		super(media, controller);
	}

	@Override
	public void buildControls() {
		int row = getLastRowIndex();
		JLabel titleLabel = new JLabel("Title");
		c.gridx = 0;
		c.gridy = row;
		getContentPane().add(titleLabel, c);
		titleField = new JTextField(15);
		titleField.setText(t.getTitle());
		c.gridx = 1;
		c.gridy = row;
		getContentPane().add(titleField, c);
		
		
		row = getLastRowIndex();
		JLabel categoryLabel = new JLabel("Category");
		c.gridx = 0;
		c.gridy = row;
		getContentPane().add(categoryLabel, c);
		categoryField = new JTextField(15);
		categoryField.setText(t.getCategory());
		c.gridx = 1;
		c.gridy = row;
		getContentPane().add(categoryField, c);
		
		
		row = getLastRowIndex();
		JLabel costLabel = new JLabel("Cost");
		c.gridx = 0;
		c.gridy = row;
		getContentPane().add(costLabel, c);
		costField = new JTextField(15);
		costField.setText(t.getCost() + "");
		c.gridx = 1;
		c.gridy = row;
		getContentPane().add(costField, c);
	}

	@Override
	public Media getNewData() {
		t.setTitle(titleField.getText());
		t.setCategory(categoryField.getText());
		t.setCost(Float.parseFloat(costField.getText()));
		
		return t;
	}
}
