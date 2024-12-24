package com.oms.bean;

public class Track {

	private String title;
	private int length;

	public Track() {
		super();
	}

	public Track(String title, int length) {
		super();
		this.title = title;
		this.length = length;
	}


	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public int getLength() {
		return length;
	}

	public void setLength(int length) {
		this.length = length;
	}
}