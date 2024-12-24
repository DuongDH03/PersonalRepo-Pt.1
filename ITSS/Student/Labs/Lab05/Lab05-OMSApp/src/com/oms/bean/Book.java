package com.oms.bean;

import java.util.ArrayList;
import java.util.Date;

public class Book extends PhysicalMedia {
	private String publisher;
	private Date publicationDate;
	private ArrayList<String> authors = new ArrayList<String>();
	private int numberOfPages;
	private String language;
	
	public Book() {
		super();
	}
	
	public Book(String id, String title, String category, float cost) {
		super(id, title, category, cost);
	}

	public Book(String id, String title, String category, float cost, String barcode, String description, int quantity, float weight, Dimension dimension, String publisher, Date publicationDate, ArrayList<String> authors, int numberOfPages, String language) {
		super(id, title, category, cost, barcode, description, quantity, weight, dimension);
		this.publisher = publisher;
		this.publicationDate = publicationDate;
		this.authors = authors;
		this.numberOfPages = numberOfPages;
		this.language = language;
	}

	public String getPublisher() {
		return publisher;
	}

	public void setPublisher(String publisher) {
		this.publisher = publisher;
	}

	public Date getPublicationDate() {
		return publicationDate;
	}

	public void setPublicationDate(Date publicationDate) {
		this.publicationDate = publicationDate;
	}

	public ArrayList<String> getAuthors() {
		return authors;
	}

	public void setAuthors(ArrayList<String> authors) {
		this.authors = authors;
	}

	public int getNumberOfPages() {
		return numberOfPages;
	}

	public void setNumberOfPages(int numberOfPages) {
		this.numberOfPages = numberOfPages;
	}

	public String getLanguage() {
		return language;
	}

	public void setLanguage(String language) {
		this.language = language;
	}
	
	@Override
	public String toString() {
		return super.toString() + ", publisher: " + publisher + ", publication date: " + publicationDate;
	}
	
	@Override
	public boolean match(Media media) {
		if (media == null)
			return true;
		
		
		boolean res = super.match(media);
		if (!res) {
			return false;
		}
		
		
		if (!(media instanceof Book))
			return false;
		Book book = (Book) media;
		
		if (book.publisher != null && !book.publisher.equals("") && !this.publisher.contains(book.publisher)) {
			return false;
		}
		if (book.publicationDate != null && !this.publicationDate.equals(book.publicationDate)) {
			return false;
		}
		if (book.numberOfPages != 0 && this.numberOfPages != book.numberOfPages) {
			return false;
		}
		if (book.language != null && !book.language.equals("") && !this.language.contains(book.language)) {
			return false;
		}
		return true;
	}
}