package api;

import java.util.ArrayList;
import java.util.Map;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.Invocation;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.GenericType;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import com.oms.bean.Book;
import com.oms.bean.CompactDisc;
import com.oms.bean.DigitalVideoDisc;
import com.oms.bean.Media;

public class MediaApi {
	public static final String PATH = "http://localhost:8080/";
	
	private Client client;
	
	public MediaApi() {
		client = ClientBuilder.newClient();
	}
	
	public ArrayList<Media> getAllMedias() {
		WebTarget webTarget = client.target(PATH).path("medias");

		Invocation.Builder invocationBuilder = webTarget.request(MediaType.APPLICATION_JSON);
		Response response = invocationBuilder.get();

		ArrayList<Media> res = response.readEntity(new GenericType<ArrayList<Media>>(){});
		System.out.println(res);
		return res;
	}

	public ArrayList<Book> getBooks(Map<String, String> queryParams) {
		WebTarget webTarget = client.target(PATH).path("books");
		
		
		if (queryParams != null) {
			for (String key : queryParams.keySet()) {
				String value = queryParams.get(key);
				webTarget = webTarget.queryParam(key, value);
			}
		}
		

		Invocation.Builder invocationBuilder = webTarget.request(MediaType.APPLICATION_JSON);
		Response response = invocationBuilder.get();
		ArrayList<Book> res = response.readEntity(new GenericType<ArrayList<Book>>() {});
		System.out.println(res);
		return res;
	}
	

	public Book updateBook(Book book) {
		WebTarget webTarget = client.target(PATH).path("books").path(book.getId());
		
		Invocation.Builder invocationBuilder =  webTarget.request(MediaType.APPLICATION_JSON);
		Response response = invocationBuilder.post(Entity.entity(book, MediaType.APPLICATION_JSON));
		
		Book res = response.readEntity(Book.class);
		return res;
	}
	
	
	public ArrayList<CompactDisc> getCds(Map<String, String> queryParams) {
		WebTarget webTarget = client.target(PATH).path("cds");

		
		if (queryParams != null) {
			for (String key : queryParams.keySet()) {
				String value = queryParams.get(key);
				webTarget = webTarget.queryParam(key, value);
			}
		}
		

		Invocation.Builder invocationBuilder = webTarget.request(MediaType.APPLICATION_JSON);
		Response response = invocationBuilder.get();
		ArrayList<CompactDisc> res = response.readEntity(new GenericType<ArrayList<CompactDisc>>() {});
		System.out.println(res);
		return res;
	}

	
	public ArrayList<DigitalVideoDisc> getDvds(Map<String, String> queryParams) {
		WebTarget webTarget = client.target(PATH).path("dvds");

		
		if (queryParams != null) {
			for (String key : queryParams.keySet()) {
				String value = queryParams.get(key);
				webTarget = webTarget.queryParam(key, value);
			}
		}
		

		Invocation.Builder invocationBuilder = webTarget.request(MediaType.APPLICATION_JSON);
		Response response = invocationBuilder.get();
		ArrayList<DigitalVideoDisc> res = response.readEntity(new GenericType<ArrayList<DigitalVideoDisc>>() {});
		System.out.println(res);
		return res;
	}
}
