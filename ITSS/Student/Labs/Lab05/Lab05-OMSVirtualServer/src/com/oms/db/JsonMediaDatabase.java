package com.oms.db;

import java.util.ArrayList;

import com.oms.bean.Media;
import com.oms.bean.Order;
import com.oms.db.seed.Seed;

public class JsonMediaDatabase implements IMediaDatabase{
	private static IMediaDatabase singleton = new JsonMediaDatabase();
	
	private ArrayList<Media> medias = Seed.singleton().getMedias();
	private ArrayList<Order> orders = Seed.singleton().getOrders();
	
	private JsonMediaDatabase() {
	}
	
	public static IMediaDatabase singleton() {
		return singleton;
	}

	@Override
	public ArrayList<Media> searchMedia(Media media) {
		ArrayList<Media> res = new ArrayList<Media>();
		for (Media b: medias) {
			if (b.match(media)) {
				res.add(b);
			}
		}
		return res;
	}

	@Override
	public Media addMedia(Media media) {
		for (Media m: medias) {
			if (m.equals(media)) {
				return null;
			}
		}
		
		medias.add(media);
		return media;
	}
	
	@Override
	public Media updateMedia(Media media) {
		for (Media m: medias) {
			if (m.equals(media)) {
				medias.remove(m);
				medias.add(media);
				return media;
			}
		}
		return null;
	}

	@Override
	public ArrayList<Order> searchOrder(Order order) {
		ArrayList<Order> res = new ArrayList<Order>();
		for (Order o: orders) {
			if (o.search(order)) {
				res.add(o);
			}
		}
		return res;
	}

	@Override
	public boolean checkOutOrder(Order order) {
		return false;
	}

}
