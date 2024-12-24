package media;

import java.util.Map;

import javax.swing.JLabel;
import javax.swing.JTextField;

@SuppressWarnings("serial")
public class PhysicalMediaSearchPane extends MediaSearchPane {
	private JTextField descriptionField;

	public PhysicalMediaSearchPane() {
		super();
	}
	
	@Override
	public void buildControls() {
		super.buildControls();
		
		
		JLabel descriptionLabel = new JLabel("Description");
		descriptionField = new JTextField(15);
		int row = getLastRowIndex();
		c.gridx = 0;
		c.gridy = row;
		add(descriptionLabel, c);
		c.gridx = 1;
		c.gridy = row;
		add(descriptionField, c);
	}

	@Override
	public Map<String, String> getQueryParams() {
		Map<String, String> res = super.getQueryParams();
		
		if (!descriptionField.getText().trim().equals("")) {
			res.put("description", descriptionField.getText().trim());
		}
		
		return res;
	}
}
