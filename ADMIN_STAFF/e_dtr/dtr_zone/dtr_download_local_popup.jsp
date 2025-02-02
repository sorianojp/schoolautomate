<%@ page language="java" import="utility.*,eDTR.StandAloneDTR,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP  = null;	
	String strTemp = null;
	String strErrMsg  = null;
	
	//add security here.
	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	
	//I have to get information now.. 
	Vector vRetResult = null;
	StandAloneDTR standaloneDTR = new StandAloneDTR();
	
	vRetResult = standaloneDTR.downloadLocalDTR(dbOP, request);
	if(vRetResult == null)
		strErrMsg = standaloneDTR.getErrMsg();
	else{
		strErrMsg = vRetResult.toString();
		strErrMsg = strErrMsg.substring(1,strErrMsg.length() - 1);
	}
	%>
	<%=WI.getStrValue(strErrMsg)%>		
<%
dbOP.cleanUP();
%>	