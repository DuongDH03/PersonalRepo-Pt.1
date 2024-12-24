package com.oms.service;

import java.util.ArrayList;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;

import com.oms.bean.CompactDisc;
import com.oms.bean.Media;
import com.oms.db.IMediaDatabase;
import com.oms.db.JsonMediaDatabase;

@Path("/cds")
public class CompactDiscService {
	
	private IMediaDatabase mediaDatabase;
	
	public CompactDiscService() {
		mediaDatabase = JsonMediaDatabase.singleton();
	}
	
	@GET
	@Path("")
	@Produces(MediaType.APPLICATION_JSON)
	public ArrayList<Media> getCds(@QueryParam("id") String id, @QueryParam("title") String title,
			@QueryParam("category") String category, @QueryParam("artist") String artist) {
		CompactDisc cd = new CompactDisc(id, title, category, 0);
		cd.setArtist(artist);
		ArrayList<Media> res = mediaDatabase.searchMedia(cd);
		return res;
	}
}