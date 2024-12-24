package com.oms.db;

import java.util.ArrayList;

import com.oms.bean.Media;
import com.oms.bean.Order;

public interface IMediaDatabase {
	public ArrayList<Media> searchMedia(Media media);
	public Media updateMedia(Media media);
	public Media addMedia(Media media);
	public ArrayList<Order> searchOrder(Order order);
	public boolean checkOutOrder(Order order);
}
