package com.oms.bean;

import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.annotation.JsonTypeName;
import com.fasterxml.jackson.annotation.JsonSubTypes.Type;

@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, include = JsonTypeInfo.As.PROPERTY, property = "type")
@JsonTypeName("media")
@JsonSubTypes({ @Type(value = PhysicalMedia.class, name = "phmedia") })
public class Media {
	private String id;
	
	private String title;

	private String category;

	private float cost;
	
	public Media() {
		super();
	}

	public Media(String id, String title, String category, float cost) {
		super();
		this.id = id;
		this.title = title;
		this.category = category;
		this.cost = cost;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public float getCost() {
		return cost;
	}

	public void setCost(float cost) {
		this.cost = cost;
	}
	
	@Override
	public String toString() {
		return "id: " + this.id + ", title: " + this.title + ", category: " + this.category + ", cost: " + this.cost;
	}
	
	
	public boolean match(Media media) {
		if (media == null)
			return true;
		
		
		if (media.id != null && !media.id.equals("") && !this.id.contains(media.id)) {
			return false;
		}
		if (media.title != null && !media.title.equals("") && !this.title.contains(media.title)) {
			return false;
		}
		if (media.category != null && !media.category.equals("") && !this.category.contains(media.category)) {
			return false;
		}
		if (media.cost != 0 && this.cost != media.cost) {
			return false;
		}
		return true;
	}
	
	@Override
	public boolean equals(Object obj) {
		if (obj instanceof Media) {
			return this.id.equals(((Media) obj).id);
		}
		return false;
	}
}