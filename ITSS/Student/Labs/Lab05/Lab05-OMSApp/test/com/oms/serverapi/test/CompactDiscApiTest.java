package com.oms.serverapi.test;
import org.junit.Test;

import com.oms.bean.CompactDisc;
import com.oms.serverapi.MediaApi;

import static org.junit.Assert.assertEquals;

import java.util.ArrayList;

public class CompactDiscApiTest {
	private MediaApi api = new MediaApi();
	
	@Test
	public void testGetAllBooks() {
		ArrayList<CompactDisc> list= api.getCds(null);
		assertEquals("Error in getCds API!", list.size(), 3);
	}
	
	@Test(timeout = 1000)
	public void testResponse() {
		api.getCds(null);
	}
}