package com.oms.bean;

import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.annotation.JsonSubTypes.Type;

@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, include = JsonTypeInfo.As.PROPERTY, property = "type")
@JsonSubTypes({ @Type(value = CompactDisc.class, name = "cd"), @Type(value = DigitalVideoDisc.class, name = "dvd"), @Type(value = Book.class, name = "book")})
public class PhysicalMedia extends Media{
	private String barcode;
	private String description;
	private int quantity;
	private float weight;
	private Dimension dimension;
	
	public PhysicalMedia() {
	}
	
	public PhysicalMedia(String id, String title, String category, float cost) {
		super(id, title, category, cost);
	}
	
	public PhysicalMedia(String id, String title, String category, float cost, String barcode, String description, int quantity, float weight, Dimension dimension) {
		super(id, title, category, cost);
		
		this.barcode = barcode;
		this.description = description;
		this.quantity = quantity;
		this.weight = weight;
		this.dimension = dimension;
	}

	public String getBarcode() {
		return barcode;
	}

	public void setBarcode(String barcode) {
		this.barcode = barcode;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public int getQuantity() {
		return quantity;
	}

	public void setQuantity(int quantity) {
		this.quantity = quantity;
	}

	public float getWeight() {
		return weight;
	}

	public void setWeight(float weight) {
		this.weight = weight;
	}

	public Dimension getDimension() {
		return dimension;
	}

	public void setDimension(Dimension dimension) {
		this.dimension = dimension;
	}
	
	@Override
	public String toString() {
		return super.toString() + ", barcode: " + barcode + ", description: " + description + ", quantity: " + quantity + ", weight: " + weight + ", dimension: " + dimension;
	}
	
	@Override
	public boolean match(Media media) {
		if (media == null)
			return true;
		
		
		boolean res = super.match(media);
		if (!res) {
			return false;
		}
		
		
		if (!(media instanceof PhysicalMedia))
			return false;
		PhysicalMedia pMedia = (PhysicalMedia) media;
		
		
		
		if (pMedia.barcode != null && !pMedia.barcode.equals("") && !this.barcode.contains(pMedia.barcode)) {
			return false;
		}
		if (pMedia.description != null && !pMedia.description.equals("") && !this.description.contains(pMedia.description)) {
			return false;
		}
		if (pMedia.quantity != 0 && this.quantity != pMedia.quantity) {
			return false;
		}
		if (pMedia.weight != 0 && this.weight != pMedia.weight) {
			return false;
		}
		return true;
	}
}