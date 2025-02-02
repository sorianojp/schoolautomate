<%
enrollment.GradeSystem gs = new enrollment.GradeSystem();
utility.DBOperation dbOP  = new utility.DBOperation();

//call consolidation of grade.

String strErrMsg = null;

if(gs.computeFinalGradeCSAOneTime(dbOP))
	strErrMsg = "Successful.";
else	
	strErrMsg = gs.getErrMsg();

%>

<%=strErrMsg%>	