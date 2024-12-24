package com.oms.bean;

import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;

public class CompactDisc extends PhysicalMedia {

	private String artist;

	private int length;
	
	private Date dateOfIssue;

	private ArrayList<Track> tracks = new ArrayList<Track>();

	public CompactDisc() {
		super();
	}
	
	public CompactDisc(String id, String title, String category, float cost) {
		super(id, title, category, cost);
	}

	public CompactDisc(String id, String title, String category, float cost, String barcode, String description, int quantity, float weight, Dimension dimension, String artist, int length, Date dateOfIssue, ArrayList<Track> tracks) {
		super(id, title, category, cost, barcode, description, quantity, weight, dimension);
		this.artist = artist;
		this.length = length;
		this.dateOfIssue = dateOfIssue;
		this.tracks = tracks;
	}

	public int getLength() {
		int total = 0;
		Iterator<Track> iter = tracks.iterator();
		Track nextTrack;
		while (iter.hasNext()) {
			nextTrack = (Track) iter.next();
			total += nextTrack.getLength();
		}
		return total;
	}


	public String getArtist() {
		return artist;
	}


	public void setArtist(String artist) {
		this.artist = artist;
	}


	public Date getDateOfIssue() {
		return dateOfIssue;
	}


	public void setDateOfIssue(Date dateOfIssue) {
		this.dateOfIssue = dateOfIssue;
	}


	public ArrayList<Track> getTracks() {
		return tracks;
	}


	public void setTracks(ArrayList<Track> tracks) {
		this.tracks = tracks;
	}


	public void setLength(int length) {
		this.length = length;
	}
	
	@Override
	public boolean match(Media media) {
		if (media == null)
			return true;
		
		
		boolean res = super.match(media);
		if (!res) {
			return false;
		}
		
		
		if (!(media instanceof CompactDisc))
			return false;
		CompactDisc cd = (CompactDisc) media;
		
		if (cd.artist != null && !cd.artist.equals("") && !this.artist.contains(cd.artist)) {
			return false;
		}
		if (cd.length != 0 && this.length != cd.length) {
			return false;
		}
		if (cd.dateOfIssue != null && !this.dateOfIssue.equals(cd.dateOfIssue)) {
			return false;
		}
		return true;
	}
}