package com.oms.bean;

public class Dimension {
	private float width;
	private float height;
	private float depth;
	
	public Dimension() {
	}

	public Dimension(float width, float height, float depth) {
		super();
		this.width = width;
		this.height = height;
		this.depth = depth;
	}

	public float getWidth() {
		return width;
	}

	public void setWidth(float width) {
		this.width = width;
	}

	public float getHeight() {
		return height;
	}

	public void setHeight(float height) {
		this.height = height;
	}

	public float getDepth() {
		return depth;
	}

	public void setDepth(float depth) {
		this.depth = depth;
	}
	
	@Override
	public String toString() {
		return width + "cm x " + height + "cm x " + depth + "cm";
	}
}
