package com.oms.db.seed;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.oms.bean.Media;
import com.oms.bean.Order;

public class Seed {
	private ArrayList<Media> medias;
	private ArrayList<Order> orders;
	
	private static Seed singleton = new Seed();
	
	private Seed() {
		start();
	}
	
	public static Seed singleton() {
		return singleton;
	}
	
	private void start() {
		medias = new ArrayList<Media>();
		medias.addAll(generateDataFromFile( new File(getClass().getResource("./books.json").getPath()).toString()));
		medias.addAll(generateDataFromFile( new File(getClass().getResource("./cds.json").getPath()).toString()));
		medias.addAll(generateDataFromFile( new File(getClass().getResource("./dvds.json").getPath()).toString()));
		
		orders = new ArrayList<Order>();
	}
	
	private ArrayList<? extends Media> generateDataFromFile(String filePath){
		ArrayList<? extends Media> res = new ArrayList<Media>();
		ObjectMapper mapper = new ObjectMapper();
		
		String json = FileReader.read(filePath);
		try {
			mapper.setDateFormat(new SimpleDateFormat("dd/MM/yyyy"));
			res = mapper.readValue(json, new TypeReference<ArrayList<Media>>() { });
		} catch (IOException e) {
			e.printStackTrace();
			System.out.println("Invalid JSON input data from " + filePath);
		}
		
		return res;
	}

	public ArrayList<Media> getMedias() {
		return medias;
	}
	
	public ArrayList<Order> getOrders() {
		return orders;
	}

	public static void main(String[] args) {
		Seed seed = new Seed();
		seed.start();
	}
}
