package com.oms.service;

import java.util.ArrayList;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;

import com.oms.bean.DigitalVideoDisc;
import com.oms.bean.Media;
import com.oms.db.IMediaDatabase;
import com.oms.db.JsonMediaDatabase;

@Path("/dvds")
public class DigitalVideoDiscService {
	
	private IMediaDatabase mediaDatabase;
	
	public DigitalVideoDiscService() {
		mediaDatabase = JsonMediaDatabase.singleton();
	}
	
	@GET
	@Path("")
	@Produces(MediaType.APPLICATION_JSON)
	public ArrayList<Media> getDvds(@QueryParam("id") String id, @QueryParam("title") String title,
			@QueryParam("category") String category, @QueryParam("director") String director,
			@QueryParam("studio") String studio) {
		DigitalVideoDisc dvd = new DigitalVideoDisc(id, title, category, 0);
		dvd.setDirector(director);
		dvd.setStudio(studio);
		ArrayList<Media> res = mediaDatabase.searchMedia(dvd);
		return res;
	}
}