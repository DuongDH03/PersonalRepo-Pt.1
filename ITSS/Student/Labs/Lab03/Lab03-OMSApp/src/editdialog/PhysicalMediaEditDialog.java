package editdialog;

import javax.swing.JLabel;
import javax.swing.JTextField;

import com.oms.bean.Dimension;
import com.oms.bean.Media;
import com.oms.bean.PhysicalMedia;

import abstractdata.IDataManageController;

@SuppressWarnings("serial")
public class PhysicalMediaEditDialog extends MediaEditDialog{
	
	private JTextField barcodeField;
	private JTextField descriptionField;
	private JTextField quantityField;
	private JTextField weightField;
	private JTextField dimensionWidthField;
	private JTextField dimensionHeightField;
	private JTextField dimensionDepthField;
	
	public PhysicalMediaEditDialog(Media media, IDataManageController<Media> controller) {
		super(media, controller);
	}

	@Override
	public void buildControls() {
		super.buildControls();
		
		if (t instanceof PhysicalMedia) {
			PhysicalMedia pMedia = (PhysicalMedia) t;
			
			int row = getLastRowIndex();
			JLabel barcodeLabel = new JLabel("Barcode");
			c.gridx = 0;
			c.gridy = row;
			getContentPane().add(barcodeLabel, c);
			barcodeField = new JTextField(15);
			barcodeField.setText(pMedia.getBarcode());
			c.gridx = 1;
			c.gridy = row;
			getContentPane().add(barcodeField, c);
			
			
			row = getLastRowIndex();
			JLabel descriptionLabel = new JLabel("Description");
			c.gridx = 0;
			c.gridy = row;
			getContentPane().add(descriptionLabel, c);
			descriptionField = new JTextField(15);
			descriptionField.setText(pMedia.getDescription());
			c.gridx = 1;
			c.gridy = row;
			getContentPane().add(descriptionField, c);
			
			
			row = getLastRowIndex();
			JLabel quantityLabel = new JLabel("Quantity");
			c.gridx = 0;
			c.gridy = row;
			getContentPane().add(quantityLabel, c);
			quantityField = new JTextField(15);
			quantityField.setText(pMedia.getQuantity() + "");
			c.gridx = 1;
			c.gridy = row;
			getContentPane().add(quantityField, c);
			
			
			row = getLastRowIndex();
			JLabel weightLabel = new JLabel("Weight");
			c.gridx = 0;
			c.gridy = row;
			getContentPane().add(weightLabel, c);
			weightField = new JTextField(15);
			weightField.setText(pMedia.getWeight() + "");
			c.gridx = 1;
			c.gridy = row;
			getContentPane().add(weightField, c);
			
			
			row = getLastRowIndex();
			JLabel dimensionWidthLabel = new JLabel("Dimension Width");
			c.gridx = 0;
			c.gridy = row;
			getContentPane().add(dimensionWidthLabel, c);
			dimensionWidthField = new JTextField(15);
			dimensionWidthField.setText(pMedia.getDimension().getWidth() + "");
			c.gridx = 1;
			c.gridy = row;
			getContentPane().add(dimensionWidthField, c);
			
			
			row = getLastRowIndex();
			JLabel dimensionHeightLabel = new JLabel("Dimension Height");
			c.gridx = 0;
			c.gridy = row;
			getContentPane().add(dimensionHeightLabel, c);
			dimensionHeightField = new JTextField(15);
			dimensionHeightField.setText(pMedia.getDimension().getHeight() + "");
			c.gridx = 1;
			c.gridy = row;
			getContentPane().add(dimensionHeightField, c);
			
			
			row = getLastRowIndex();
			JLabel dimensionDepthLabel = new JLabel("Dimension Depth");
			c.gridx = 0;
			c.gridy = row;
			getContentPane().add(dimensionDepthLabel, c);
			dimensionDepthField = new JTextField(15);
			dimensionDepthField.setText(pMedia.getDimension().getDepth() + "");
			c.gridx = 1;
			c.gridy = row;
			getContentPane().add(dimensionDepthField, c);
		}
	}

	@Override
	public Media getNewData() {
		super.getNewData();
		
		if (t instanceof PhysicalMedia) {
			PhysicalMedia pMedia = (PhysicalMedia) t;
			
			pMedia.setBarcode(barcodeField.getText());
			pMedia.setDescription(descriptionField.getText());
			pMedia.setQuantity(Integer.parseInt(quantityField.getText()));
			pMedia.setWeight(Float.parseFloat(weightField.getText()));
			Dimension d = new Dimension(Float.parseFloat(dimensionWidthField.getText()), Float.parseFloat(dimensionHeightField.getText()), Float.parseFloat(dimensionDepthField.getText()));
			pMedia.setDimension(d);
		}
		
		return t;
	}
}
