package media;

import com.oms.bean.Media;

@SuppressWarnings("serial")
public class BookSinglePane extends PhysicalMediaSinglePane {
	
	public BookSinglePane() {
		super();
	}
	
	public BookSinglePane(Media media) {
		this();
		this.t = media;

		displayData();
	}
}
