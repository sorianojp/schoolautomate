<%@ page language="java" import="utility.*, docTracking.deped.DocumentTracking, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Average Duration Statistics</title></head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">	
	
	function SearchAve(){
		document.form_.search_ave.value = "1";
		document.form_.submit();
	}
	
	function loadSearchDept() {
		var objCOA=document.getElementById("load_search_dept");
 		var objCollegeInput = document.form_.search_college[document.form_.search_college.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=search_dept&all=1";
		this.processRequest(strURL);
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here..
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"DOCUMENT TRACKING","statistics_ave_duration.jsp");
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
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING-REPORTS"),"0"));
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING"),"0"));
		if(iAccessLevel == 0){
			response.sendRedirect("../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	
	Vector vRetResult = null;
	DocumentTracking dt = new DocumentTracking();
	
	if(WI.fillTextValue("search_ave").length() > 0){
		vRetResult = dt.getAverageDurationStatistics(dbOP, request);
		if(vRetResult == null)
			strErrMsg = dt.getErrMsg();
	}		
%>
<body bgcolor="#D2AE72">
<form name="form_" action="statistics_ave_duration.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: AVE. DURATION STATISTICS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<!--
			possible also to generate average duration statistics per office/dept over a specific period of time only and not base all receive-release records.
		-->
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Office:</td>
			<%
				String strCollegeCon = WI.fillTextValue("search_college");
			%>
			<td width="80%">
				<select name="search_college" onChange="loadSearchDept();">
          			<option value="0">ALL</option>
          			<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0 order by c_name", strCollegeCon, false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Department:</td>
			<td>
				<label id="load_search_dept">
				<select name="search_dept">
         			<option value="">ALL</option>
          		<%if ((strCollegeCon.length() == 0) || strCollegeCon.equals("0")){%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("search_dept"), false)%> 
          		<%}else{%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeCon,  WI.fillTextValue("search_dept"), false)%> 
         		 <%}%>
  	   			</select>
				</label></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
			<td><a href="javascript:SearchAve();"><img src="../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to search ave. duration for each office/dept</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0" class="thinborder">
		<tr>
			<td height="25" align="center" class="thinborder" width="50%"><strong>Office/Department</strong></td>
			<td align="center" class="thinborder" width="25%"><strong>Documents Released</strong></td>
			<td align="center" class="thinborder" width="25%"><strong>Ave. Receive-Release Duration</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 5){%>
		<tr>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i));
				strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i+1));
				
				if(strTemp.length() > 0 && strErrMsg.length() > 0)
					strTemp += "/ ";
				strTemp += strErrMsg;
			%>
			<td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
		</tr>
	<%}%>
	</table>
<%}%>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="search_ave" value="<%=WI.fillTextValue("search_ave")%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>