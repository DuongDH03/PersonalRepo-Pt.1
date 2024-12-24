
package testJDBC;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Scanner;


public class testJDBC {

	public static void main(String[] args) {
		// TODO Auto-generated method stub

		System.out.println("-------- PostgreSQL JDBC Connection Testing ------------");

		try {
			Class.forName("org.postgresql.Driver");

		} catch (ClassNotFoundException e) {
			System.out.println("Where is your PostgreSQL JDBC Driver? Include in your library path!");
			e.printStackTrace();
			return;
		}

		System.out.println("PostgreSQL JDBC Driver Registered!");

		Connection connection = null;
		
		// Open connection
		try {
			//connection = DriverManager.getConnection("jdbc:postgresql://PC-de-oanh:5432/QLKH", "postgres","admin");
			connection = DriverManager.getConnection("jdbc:postgresql://localhost:5432/qlkh", "postgres","admin");
		} catch (SQLException e) {
			System.out.println("Connection Failed! Check output console");
			e.printStackTrace();
			return;
		}

		if (connection != null) {
			System.out.println("You made it, take control your database now!");
			try {
				//selectExample(connection);
				insertExample(connection);
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {
						connection.close();
					} catch (Exception e) { e.printStackTrace();}
			}
		} 
	}
	

	
	
	 public static void selectExample(Connection conn) throws SQLException {
		 Statement statement = null;
		 	try {
					statement = conn.createStatement();
					
					String sqlstatement = "select \"GV#\", \"HoTen\" from \"GiangVien\";";
					
					ResultSet result = statement.executeQuery(sqlstatement);
					
					System.out.println("Got results:");
					try{
						while (result.next()) { // process results one row at a time
							String key = result.getString(1);
							String val = result.getString(2);
							System.out.println("key = " + key + "    |    " + "hoten = " + val );					
						}
						
					} finally {
						try{result.close();}catch(Exception e) {e.printStackTrace(); }
					}
				} catch (Exception e) {
					e.printStackTrace();
				} finally {
					 try{if (statement != null) statement.close();}catch(Exception e) {e.printStackTrace(); }
				} 
	 }
	 
	 public static int insertExample(Connection conn) throws SQLException {
			int ret_insert = 0;
			try {		
				Statement statement = conn.createStatement();
				
				// Nhap DL tu ban phim	
				System.out.println("Nhap vao thong tin can insert vao bang:");
				Scanner input = new Scanner(System.in);
				System.out.print("GV#:");
				String maGV = input.nextLine();
				System.out.print("Ho ten:");
				String tenGV = input.nextLine();
				System.out.print("Dia chi:");
				String diachi = input.nextLine();
				System.out.print("Ngay sinh:");
				String ngaysinh = input.nextLine();  //int age = input.nextInt();
			    input.close();			
				System.out.println("Ma GV = " + maGV + " Ten:" + tenGV);
				
				// String insert_sql = "INSERT INTO \"GiangVien\" (\"GV#\", \"HoTen\", \"DiaChi\", \"NgaySinh\") VALUES ('" 
				//				+ maGV + "', '" + tenGV + "', '"+ diachi + "', '" + ngaysinh +  "') ";
	
				String insert_sql = "INSERT INTO \"GiangVien\" (\"GV#\", \"HoTen\", \"DiaChi\", \"NgaySinh\") VALUES ('" 
						+ maGV + "', '" + tenGV + "', '"+ diachi + "', '" +  "') ";
		
				
				System.out.println(insert_sql);
				
				try {
					ret_insert = statement.executeUpdate(insert_sql);
					if (ret_insert > 0) 
							System.out.println("Insert Thanh coong!");
				} catch (Exception e) {
					e.printStackTrace();
				} finally {
					try{statement.close();}catch(Exception e) {e.printStackTrace(); }
				} 
			} catch (Exception e) {
				e.printStackTrace();
			}
			return ret_insert;
		 }

}
