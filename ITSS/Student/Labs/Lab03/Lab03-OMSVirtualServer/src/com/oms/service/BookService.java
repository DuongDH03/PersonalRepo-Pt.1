package com.oms.service;

import java.util.ArrayList;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;

import com.oms.bean.Book;
import com.oms.bean.Media;
import com.oms.db.IMediaDatabase;
import com.oms.db.JsonMediaDatabase;

@Path("/books")
public class BookService {

	private IMediaDatabase mediaDatabase;

	public BookService() {
		mediaDatabase = JsonMediaDatabase.singleton();
	}

	@GET
	@Path("")
	@Produces(MediaType.APPLICATION_JSON)
	public ArrayList<Media> getBooks(@QueryParam("id") String id, @QueryParam("title") String title,
			@QueryParam("category") String category, @QueryParam("description") String description,
			@QueryParam("publisher") String publisher, @QueryParam("language") String language) {
		Book book = new Book(id, title, category, 0);
		book.setDescription(description);
		book.setPublisher(publisher);
		book.setLanguage(language);
		ArrayList<Media> res = mediaDatabase.searchMedia(book);
		return res;
	}

	@POST
	@Path("/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	@Consumes(MediaType.APPLICATION_JSON)
	public Media updateBook(@PathParam("id") String id, Book book) {
		return mediaDatabase.updateMedia(book);
	}
}