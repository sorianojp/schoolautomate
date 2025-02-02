<%@ page language="java" import="utility.*, enrollment.AttendanceMonitoringCDD, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<style type="text/css">

 /*this is what we want the div to look like*/
  div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:0;
	top:0;
    width:350px;
	height:200;/** it expands on its own.. **/
    
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }


</style>

<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="javascript" src ="../../../jscript/common.js" ></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>

</head>
<body bgcolor="#D2AE72">
<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS-STUDENT TRACKER"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"STUDENT AFFAIRS-STUDENT TRACKER","student_absent_list.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}

Vector vRetResult = null;
Vector vStudDtls  = null;

AttendanceMonitoringCDD attendanceCDD = new AttendanceMonitoringCDD();	
if(WI.fillTextValue("stud_id").length()>0){
	vStudDtls = attendanceCDD.operateOnAttendanceMonitoringCDD(dbOP, request, 5);
	if(vStudDtls == null)
		strErrMsg = attendanceCDD.getErrMsg();
	else{
		vRetResult = attendanceCDD.operateOnAttendanceMonitoringCDD(dbOP, request, 4);			
		if(vRetResult == null)
			strErrMsg = attendanceCDD.getErrMsg();
	}
}
%>
<form action="./student_absent_list.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>::::
          STUDENT ABSENT LIST ::::</strong></font></div></td>
    </tr>
    <tr >
	<td height="25" colspan="3">&nbsp; &nbsp; &nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>	
	</tr>
  </table>
  
<%if (vStudDtls!= null && vStudDtls.size()>0){
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	<tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%" height="25">Student Name </td>
      <td width="" height="25"><strong><%=(String)vStudDtls.elementAt(1)%></strong></td>
    </tr>		
	<tr><td colspan="4">&nbsp;</td></tr>
  </table>
<%

if (vRetResult!= null && vRetResult.size()>0){%>
	

	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td class="thinborder" height="25" align="" width="15%"><strong>Subect Code</strong></td>
			<td class="thinborder" align="" width="30%"><strong>Subect Name</strong></td>
			<td class="thinborder" align="center" width="15%"><strong>Date Absent</strong></td>
			<td class="thinborder" align=""><strong>Reason</strong></td>
			
		</tr>
		
		<%
		
		String strColor = null;
		String strCurCode = null;
		String strPrevCode = "";
		for(int i = 0; i < vRetResult.size(); i+=7){
			strCurCode = (String)vRetResult.elementAt(i+3);
			
			if(strColor == null)
				strColor = "#999999";
			else{
				if(strColor.equals("#999999") && !strPrevCode.equals(strCurCode))
					strColor = "#FFFFFF";
				else{
					if(strColor.equals("#FFFFFF") && strPrevCode.equals(strCurCode))
						strColor = "#FFFFFF";
					else
						strColor = "#999999";				
				}
					
			}
		%>
		
		<tr>
			<td bgcolor="<%=strColor%>" class="thinborder" height="25"><%=WI.getStrValue((String)vRetResult.elementAt(i+3))%></td>
			<td bgcolor="<%=strColor%>" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4))%></td>
			<td bgcolor="<%=strColor%>" class="thinborder" align="center"><%=vRetResult.elementAt(i+5)%></td>
			<td bgcolor="<%=strColor%>" class="thinborder" align=""><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%></td>			
		</tr>
		
		<%
			strPrevCode = strCurCode;
		}%>
	</table>

<%}//end vRetResult not null%>






<%}//end vStudDtls not null%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="status_" value="<%=WI.fillTextValue("status_")%>" />
<input type="hidden" name="page_action" />
<input type="hidden" name="drop_reason" value="<%=WI.fillTextValue("drop_reason")%>" />
<input type="hidden" name="update_from_list" />
<input type="hidden" name="attendance_index_" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
