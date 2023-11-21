/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package utilies;
 
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager; 
import java.sql.ResultSet;
import java.sql.SQLException;

import constant.*; 
 
/**
 *
 * @author DSI_BENJA
 */
public class InsertDB {
 
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
           System.out.println("Entra a la clase");
         }
   
    public static String insertaInicio(String ANI, String DNIS, String UCID, String SESSIONID, String PASO, String AUTOATENDIDA, String TRANSFERENCIA, String RPU) {
         

        ResultSet resultSet = null;
  
        
        try(Connection connection = DriverManager.getConnection(constant.connectionUrl);
        		CallableStatement prepsInsertProduct = connection.prepareCall("{call SP_REGISTRAPASO(?,?,?,?,?,?,?,?)}");) {
        	prepsInsertProduct.setString(1, DNIS);
        	prepsInsertProduct.setString(2, ANI);
        	prepsInsertProduct.setString(3, UCID);
        	prepsInsertProduct.setString(4, SESSIONID);
        	prepsInsertProduct.setString(5, PASO);
        	prepsInsertProduct.setString(6, AUTOATENDIDA);
        	prepsInsertProduct.setString(7, TRANSFERENCIA); 
        	prepsInsertProduct.setString(8, RPU); 
            prepsInsertProduct.execute();
            int count = prepsInsertProduct.getUpdateCount();
            System.out.println("ROWS AFFECTED: " + count);
            return "ROWS AFFECTED:" + count;
        }

        catch (SQLException e) {
        	System.out.println("ROWS AFFECTED: " + e.getMessage());
            e.printStackTrace();
            return "Error:" + e.getMessage();
        }
        
        
		
    }
     
    
    
}