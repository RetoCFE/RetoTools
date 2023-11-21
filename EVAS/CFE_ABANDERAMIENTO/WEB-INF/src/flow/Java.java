package flow;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.avaya.sce.runtimecommon.ITraceInfo;

/**
 * A basic servlet which allows a user to define their code, generate
 * any output, and to select where to transition to next.
 * Last generated by Orchestration Designer at: 14 DE NOVIEMBRE DE 2023 03:47:50 PM CST
 */
public class Java extends com.avaya.sce.runtime.BasicServlet {

	//{{START:CLASS:FIELDS
	//}}END:CLASS:FIELDS

	/**
	 * Default constructor
	 * Last generated by Orchestration Designer at: 14 DE NOVIEMBRE DE 2023 03:47:50 PM CST
	 */
	public Java() {
		//{{START:CLASS:CONSTRUCTOR
		super();
		//}}END:CLASS:CONSTRUCTOR
	}

	/**
	 * This method allows for custom integration with other Java components.
	 * You may use Java for sophisticated logic or to integrate with custom
	 * connectors (i.e. JMS, custom web services, sockets, XML, JAXB, etc.)
	 *
	 * Any custom code added here should work as efficiently as possible to prevent delays.
	 * It's important to design your callflow so that the voice browser (Experienve Portal/IR)
	 * is not waiting too long for a response as this can lead to a poor caller experience.
	 * Additionally, if the response to the client voice browser exceeds the configured
	 * timeout, the platform may throw an "error.badfetch". 
	 *
	 * Using this method, you have access to all session variables through the 
	 * SCESession object.
	 *
	 * The code generator will *** NOT *** overwrite this method in the future.
	 * Last generated by Orchestration Designer at: 14 DE NOVIEMBRE DE 2023 03:47:50 PM CST
	 */
	public void servletImplementation(com.avaya.sce.runtimecommon.SCESession mySession) {

		// TODO: Add your code here!
		
		DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		Date date = new Date();
		String strfechaF = dateFormat.format(date);
		
	 
   		if (mySession.isAppTraceEnabled() == true){
   			mySession.getTraceOutput().writeln(ITraceInfo.TRACE_LEVEL_INFO,"--------------------------------------------------");
   			mySession.getTraceOutput().writeln(ITraceInfo.TRACE_LEVEL_INFO,"--------------------HORA--------------------");
   		 	}
   		
          
   		if (mySession.isAppTraceEnabled() == true){
   			mySession.getTraceOutput().writeln(ITraceInfo.TRACE_LEVEL_INFO,"--------------------------------------------------");
   			mySession.getTraceOutput().writeln(ITraceInfo.TRACE_LEVEL_INFO,"--------------------SETEA VARIABLES-------------------");
   			 		}
   		String ANI = mySession.getVariableField(IProjectVariables.EVA__TELEFONO).getStringValue();
        String DNIS = mySession.getVariableField(IProjectVariables.EVA__DNIS).getStringValue();
        String UCID = mySession.getVariableField(IProjectVariables.EVA__UCID).getStringValue();
        String SESSIONID = mySession.getVariableField(IProjectVariables.EVA__SESSIONID).getStringValue();
        String PASO = mySession.getVariableField(IProjectVariables.EVA__PASO).getStringValue();
        String AUTOATENDIDA = mySession.getVariableField(IProjectVariables.EVA__AUTOATENDIDA).getStringValue();
        String TRANSFERENCIA = mySession.getVariableField(IProjectVariables.EVA__TRANSFERENCIA).getStringValue();
        String RPU = mySession.getVariableField(IProjectVariables.EVA__RPU).getStringValue();
        
        String SPBACK = "EXEC SP_REGISTRAPASOV2 " + "'"+strfechaF+"'," + "'"+ANI+"'," + "'"+DNIS+"'," + "'"+UCID+"'," + "'"+SESSIONID+"'," + "'"+PASO+"'," + "'"+AUTOATENDIDA+"'," + "'"+TRANSFERENCIA+"'," + "'"+RPU+"';" ;
        System.out.println("EXEC SP_REGISTRAPASOV2 " + "'"+strfechaF+"'," + "'"+ANI+"'," + "'"+DNIS+"'," + "'"+UCID+"'," + "'"+SESSIONID+"'," + "'"+PASO+"'," + "'"+AUTOATENDIDA+"'," + "'"+TRANSFERENCIA+"'," + "'"+RPU+"';" );
        mySession.getTraceOutput().writeln(ITraceInfo.TRACE_LEVEL_INFO,"ANI :" + ANI);
        mySession.getTraceOutput().writeln(ITraceInfo.TRACE_LEVEL_INFO,"DNIS :" + DNIS); 
        mySession.getTraceOutput().writeln(ITraceInfo.TRACE_LEVEL_INFO,"UCID :" +UCID ); 
        mySession.getTraceOutput().writeln(ITraceInfo.TRACE_LEVEL_INFO,"SESSIONID :" + SESSIONID ); 
        mySession.getTraceOutput().writeln(ITraceInfo.TRACE_LEVEL_INFO,"PASO :" + PASO); 
        mySession.getTraceOutput().writeln(ITraceInfo.TRACE_LEVEL_INFO,"AUTOATENDIDA :" +AUTOATENDIDA ); 
        mySession.getTraceOutput().writeln(ITraceInfo.TRACE_LEVEL_INFO,"TRANSFERENCIA :" + TRANSFERENCIA ); 
        mySession.getTraceOutput().writeln(ITraceInfo.TRACE_LEVEL_INFO,"RPU :" + RPU); 
        
        
        
         String IDSESSION = mySession.getVariableField(IProjectVariables.SESSION,IProjectVariables.SESSION_FIELD_SESSIONID).getStringValue();
        
        
        try{
        	mySession.getTraceOutput().writeln(ITraceInfo.TRACE_LEVEL_INFO,"StatusSP_POSTGRES:" + utilies.InsertDBPSQL.InsertaBackUp(SESSIONID,SPBACK));
        	
        	mySession.getTraceOutput().writeln(ITraceInfo.TRACE_LEVEL_INFO,"StatusSP_SQL:" + utilies.InsertDB.insertaInicio(ANI, DNIS, UCID, SESSIONID,PASO,AUTOATENDIDA,TRANSFERENCIA,RPU));
            
        	
        }catch(Exception e){
        	
   			mySession.getTraceOutput().writeln(ITraceInfo.TRACE_LEVEL_INFO,"StatusSP:	error }::::" + e.getMessage());
        }
		

	}
	/**
	 * Builds the list of branches that are defined for this servlet object.
	 * This list is built automatically by defining Goto nodes in the call flow editor.
	 * It is the programmer's responsibilty to provide at least one enabled Goto.<BR>
	 *
	 * The user should override updateBranches() to determine which Goto that the
	 * framework will activate.  If there is not at least one enabled Goto item, 
	 * the framework will throw a runtime exception.<BR>
	 *
	 * This method is generated automatically and changes to it may
	 * be overwritten next time code is generated.  To modify the list
	 * of branches for the flow item, override:
	 *     <code>updateBranches(Collection branches, SCESession mySession)</code>
	 *
	 * @return a Collection of <code>com.avaya.sce.runtime.Goto</code>
	 * objects that will be evaluated at runtime.  If there are no gotos
	 * defined in the Servlet node, then this returns null.
	 * Last generated by Orchestration Designer at: 16 DE NOVIEMBRE DE 2023 02:55:21 PM CST
	 */
	public java.util.Collection getBranches(com.avaya.sce.runtimecommon.SCESession mySession) {
		java.util.List list = null;
		com.avaya.sce.runtime.Goto aGoto = null;
		list = new java.util.ArrayList(1);

		aGoto = new com.avaya.sce.runtime.Goto("Salida", 0, true, "Default");
		list.add(aGoto);

		return list;
	}
}