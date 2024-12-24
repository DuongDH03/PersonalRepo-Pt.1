package com.oms.service;

import java.util.ArrayList;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;

import com.oms.bean.Media;
import com.oms.db.IMediaDatabase;
import com.oms.db.JsonMediaDatabase;

@Path("/medias")
public class MediaService {
	
	private IMediaDatabase mediaDatabase;
	
	public MediaService() {
		mediaDatabase = JsonMediaDatabase.singleton();
	}

    @GET
    @Path("")
    @Produces(MediaType.APPLICATION_JSON)
    public ArrayList<Media> getAllMedias() {
    	ArrayList<Media> res = mediaDatabase.searchMedia(null);
        return res;
    }
}