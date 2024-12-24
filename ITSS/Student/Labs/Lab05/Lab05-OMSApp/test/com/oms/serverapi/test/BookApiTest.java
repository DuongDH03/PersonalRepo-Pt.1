package com.oms.serverapi.test;
import org.junit.Test;

import com.oms.bean.Book;
import com.oms.serverapi.MediaApi;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.util.ArrayList;
import java.util.HashMap;

public class BookApiTest {
	private MediaApi api = new MediaApi();
	
	@Test
	public void testGetAllBooks() {
		ArrayList<Book> list= api.getBooks(null);
		assertEquals("Error in getBooks API!", list.size(), 3);
	}
	
	@Test(timeout = 1000)
	public void testResponse() {
		api.getBooks(null);
	}
	
	@Test
	public void testUpdateBook() {
		ArrayList<Book> list= api.getBooks(null);
		assertTrue("No data", list.size() > 0);
		
		
		Book book = list.get(0);
		String newPublisher = "O'Reilly";
		book.setPublisher(newPublisher);
		api.updateBook(book);
		
		
		HashMap<String, String> params = new HashMap<String, String>();
		params.put("publisher", newPublisher);
		list = api.getBooks(params);
		assertTrue("Eror in updateBook API!", list.size() > 0);
		
	
		Book newBook = api.getBooks(params).get(0);
		assertEquals("Eror in updateBook API!", newBook.getPublisher(), newPublisher);
	}
}