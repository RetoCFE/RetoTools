/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package utilies;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
//import javax.swing.JOptionPane;
import constant.*; 

public class InsertDBPSQL {

    

	public static void main(String[] args) throws SQLException {
		
		System.out.println ("Entra");

	}
	
	public static String InsertaBackUp(String SessionId, String SP)
	{
		
		String Query = "insert into public.banderas ( sessionid, sp) values ('"+ SessionId  +"','"+SP.replace("'","''")+"')";

		try
        {
          Class.forName(constant.driver);
          Connection con = DriverManager.getConnection(
        		  constant.connectString,
        		  constant.user, 
        		  constant.password);
          Statement stmt = con.createStatement();
          stmt.executeUpdate(Query);
          stmt.close();
          con.close();
        
         return "OK";
          
        }
        catch (Exception e)
        {
          e.printStackTrace();
          return "ERROR=" + e.getMessage();
        }
		
	}
	
	
	}