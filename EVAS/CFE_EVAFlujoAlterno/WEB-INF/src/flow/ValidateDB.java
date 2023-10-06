package flow;
import com.microsoft.sqlserver.jdbc.SQLServerDriver;

import java.io.FileReader;
import java.nio.file.FileSystems;
import java.nio.file.Path;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Properties;

public class ValidateDB{
	

	  public static void main(String[] args) throws Exception {
		  getMensajesDB();
		 // getDate("");
		  }
	  public static String[] getMensajesDB() throws Exception {
		  String connectionUrl ="";
		  ResultSet resultSet = null;
		  String[]  Result= {"","",""};
		  try {
			  
			  Path currentpath = FileSystems.getDefault().getPath("").toAbsolutePath();
			  String path="/opt/AppServer/tomcat/webapps/CFE_EVAFlujoAlterno/data/FlujosConnectDB.properties";
			  //Comentar linea de arriba y descomentar la de abajo para poder obtener ejecuciones de prueba.
			  //String path="./data/FlujosConnectDB.properties";
			  FileReader reader=new FileReader(path);  
			  System.out.println("Path:"+path);
			  Properties DatosConexion=new Properties();  
			  DatosConexion.load(reader);  
			  connectionUrl =
					  "jdbc:sqlserver://"+DatosConexion.getProperty("IP")+";"
					  //	"jdbc:sqlserver://10.226.0.187:1433;"
					  + "database="+DatosConexion.getProperty("database")+";"
					  + "user="+DatosConexion.getProperty("user")+";"
					  + "password="+DatosConexion.getProperty("password")+";"
					  + "encrypt=true;"
					  + "trustServerCertificate=true;"
					  + "loginTimeout="+DatosConexion.getProperty("loginTimeout")+";";
			  System.out.println("Connect:"+connectionUrl);
		  }catch (Exception e) {
			  e.printStackTrace();
		}
	        
		  try {
	        	Connection connection = DriverManager.getConnection(connectionUrl);
	        	
	        	CallableStatement prepsInsertProduct = connection.prepareCall("EXEC [SP_GETMENSAJESFlujos]"); {
		            prepsInsertProduct.execute();
		            ResultSet count = prepsInsertProduct.getResultSet();
		            
		            //System.out.println("---------------------------------------------");
		            //System.out.println(count);
		           // System.out.println("---------------------------------------------");
		            while (count.next()) {
		            	Result[0]=count.getString("MENSAJE");
		            	Result[1]=count.getString("ESTATUS");
		            	Result[2]=count.getString("ID");
		            	//System.out.println("ID"+count.getString("ID"));
		              }
		            if(Result[0]=="" ||Result[1]=="" ||Result[2]=="" ) {
		            	Result[0]="No Results";
		            	Result[1]="0";
		            	Result[2]="2";
		            }
		            System.out.println(Arrays.toString(Result));
		            count.close();
		            return Result;
		        }
	        } catch (Exception e) {
	            e.printStackTrace();
	            Result[0]="Error:" + e.getMessage();
	            Result[1]="0";
	          	Result[2]="2";//Se setea el flujo normal
	            System.out.println(Arrays.toString(Result));
	            return Result;
	        }
	}
	public static LocalDateTime getDate(String Fecha) {
		LocalDateTime Fechas=java.time.LocalDateTime.now();
		System.out.println(java.time.LocalDateTime.now());
		return Fechas;
	}

}
