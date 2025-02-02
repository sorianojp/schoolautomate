<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>

<script language="JavaScript">
//called for add or edit.
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
</script>

<%@ page language="java" import="utility.*,lms.MgmtCirculation,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Administration-CIRCULATION".toUpperCase()),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Administration".toUpperCase()),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//end of authenticaion code.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"lms-Administration-CIRCULATION","wh.jsp");
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
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

	MgmtCirculation mgmtBP = new MgmtCirculation();
	Vector vRetResult = mgmtBP.operateOnWH(dbOP, request);
	strErrMsg = mgmtBP.getErrMsg();


	String[] astrTime     = {"4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19",
								"20","21","22","23"};
	String[] astrTimeDisp = {"4AM","5AM","6AM","7AM","8AM","9AM","10AM","11AM","12PM","1PM","2PM","3PM",
								"4PM","5PM","6PM","7PM","8PM","9PM","10PM","11PM"};
	String[] astrMin      = {"0","15","30","45"};
	String[] astrMinDisp  = {"00 Min","15 Min","30 Min","45 Min"};

%>

<body bgcolor="#DEC9CC">
<form action="./wh.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CIRCULATION MANAGEMENT - WORKING HOUR MGMT PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4"><font size="3" color="#FF0000"><strong> <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font> 
      </td>
    </tr>
</table> 
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="94%" align="center">&nbsp;
	  
	    <table width="70%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td width="25%" height="25" class="thinborderTOPLEFT">SUNDAY</td>
				<td width="75%" class="thinborderTOPRIGHT">
		<select name="sunday_fr_hr" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("sunday_fr_hr");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("0"))
					strTemp = (String)vRetResult.elementAt(1);
			}
			if(strTemp == null) strTemp = "";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
               		<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
				  : 
		<select name="sunday_fr_min" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("sunday_fr_min");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("0"))
					strTemp = (String)vRetResult.elementAt(2);
			}
			if(strTemp == null) strTemp = "";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               		<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
				  
				 &nbsp;&nbsp;&nbsp; 
				  to 

		          <select name="sunday_to_hr" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("sunday_to_hr");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("0"))
					strTemp = (String)vRetResult.elementAt(4);
			}
			if(strTemp == null) strTemp = "";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
               		<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
		          :  
				  
		<select name="sunday_to_min" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("sunday_to_min");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("0")) {
					strTemp = (String)vRetResult.elementAt(4);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);
				}
			}
			if(strTemp == null) strTemp = "";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               		<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select>		</td>
			</tr>
			<tr>
			  <td height="25" class="thinborderTOPLEFT">MONDAY</td>
			  <td class="thinborderTOPRIGHT">
		<select name="monday_fr_hr" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("monday_fr_hr");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("1")) {
					strTemp = (String)vRetResult.elementAt(1);
				}
			}

			if(strTemp == null) 
				strTemp = "7";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
               		<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
				  : 
		<select name="monday_fr_min" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("monday_fr_min");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("1")) {
					strTemp = (String)vRetResult.elementAt(2);
				}
			}
			if(strTemp == null) 
				strTemp = "0";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               		<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
				  
				 &nbsp;&nbsp;&nbsp; 
				  to 

		          <select name="monday_to_hr" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("monday_to_hr");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("1")) {
					strTemp = (String)vRetResult.elementAt(3);
				}
			}
			if(strTemp == null) 
				strTemp = "17";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
               		<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
		          :  
				  
		<select name="monday_to_min" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("monday_to_min");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("1")) {
					strTemp = (String)vRetResult.elementAt(4);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);
				}
			}
			if(strTemp == null) 
				strTemp = "0";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               		<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select>			  </td>
		  </tr>
			<tr>
			  <td height="25" class="thinborderTOPLEFT">TUESDAY</td>
			  <td class="thinborderTOPRIGHT">
		<select name="tuesday_fr_hr" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("tuesday_fr_hr");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("2")) {
					strTemp = (String)vRetResult.elementAt(1);
				}
			}
			if(strTemp == null) 
				strTemp = "7";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
               		<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
				  : 
		<select name="tuesday_fr_min" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("tuesday_fr_min");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("2")) {
					strTemp = (String)vRetResult.elementAt(2);
				}
			}
			if(strTemp == null) 
				strTemp = "0";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               		<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
				  
				 &nbsp;&nbsp;&nbsp; 
				  to 

		          <select name="tuesday_to_hr" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("tuesday_to_hr");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("2")) {
					strTemp = (String)vRetResult.elementAt(3);
				}
			}
			if(strTemp == null) 
				strTemp = "17";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
               		<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
		          :  
				  
		<select name="tuesday_to_min" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("tuesday_to_min");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("2")) {
					strTemp = (String)vRetResult.elementAt(4);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);
				}
			}
			if(strTemp == null) 
				strTemp = "0";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               		<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select>			  </td>
		  </tr>
			<tr>
			  <td height="25" class="thinborderTOPLEFT">WEDNESDAY</td>
			  <td class="thinborderTOPRIGHT">
		<select name="wednes_fr_hr" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("wednes_fr_hr");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("3")) {
					strTemp = (String)vRetResult.elementAt(1);
				}
			}
			if(strTemp == null) 
				strTemp = "7";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
               		<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
				  : 
		<select name="wednes_fr_min" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("wednes_fr_min");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("3")) {
					strTemp = (String)vRetResult.elementAt(2);
				}
			}
			if(strTemp == null) 
				strTemp = "0";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               		<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
				  
				 &nbsp;&nbsp;&nbsp; 
				  to 

		          <select name="wednes_to_hr" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
                    <option value=""></option>
                    <%
			strTemp = request.getParameter("wednes_to_hr");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("3")) {
					strTemp = (String)vRetResult.elementAt(3);
				}
			}
			if(strTemp == null) 
				strTemp = "17";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
                    <option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
                    <%}else{%>
                    <option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
                    <%}//end of else.
			}//end of for%>
                  </select> 
	            :  
				  
		<select name="wednes_to_min" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("wednes_to_min");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("3")) {
					strTemp = (String)vRetResult.elementAt(4);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);
				}
			}
			if(strTemp == null) 
				strTemp = "0";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               		<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select>			  </td>
		  </tr>
			<tr>
			  <td height="25" class="thinborderTOPLEFT">THURSDAY</td>
			  <td class="thinborderTOPRIGHT">
		<select name="thurs_fr_hr" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("thurs_fr_hr");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("4")) {
					strTemp = (String)vRetResult.elementAt(1);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);
				}
			}
			if(strTemp == null) 
				strTemp = "7";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
               		<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
				  : 
		<select name="thurs_fr_min" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("thurs_fr_min");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("4")) {
					strTemp = (String)vRetResult.elementAt(2);
				}
			}
			if(strTemp == null) 
				strTemp = "0";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               		<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
				  
				 &nbsp;&nbsp;&nbsp; 
				  to 

		          <select name="thurs_to_hr" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("thurs_to_hr");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("4")) {
					strTemp = (String)vRetResult.elementAt(3);
				}
			}
			if(strTemp == null) 
				strTemp = "17";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
               		<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
		          :  
				  
		<select name="thurs_to_min" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("thurs_to_min");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("4")) {
					strTemp = (String)vRetResult.elementAt(4);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);
				}
			}
			if(strTemp == null) 
				strTemp = "0";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               		<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select>			  </td>
		  </tr>
			<tr>
			  <td height="25" class="thinborderTOPLEFT">FRIDAY</td>
			  <td class="thinborderTOPRIGHT">
		<select name="friday_fr_hr" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("friday_fr_hr");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("5")) {
					strTemp = (String)vRetResult.elementAt(1);
				}
			}
			if(strTemp == null) 
				strTemp = "7";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
               		<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
				  : 
		<select name="friday_fr_min" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("friday_fr_min");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("5")) {
					strTemp = (String)vRetResult.elementAt(2);
				}
			}
			if(strTemp == null) 
				strTemp = "0";
			if(strTemp == null) strTemp = "";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               		<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
				  
				 &nbsp;&nbsp;&nbsp; 
				  to 

		          <select name="friday_to_hr" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("friday_to_hr");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("5")) {
					strTemp = (String)vRetResult.elementAt(3);
				}
			}
			if(strTemp == null) 
				strTemp = "17";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
               		<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
		          :  
				  
		<select name="friday_to_min" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("friday_to_min");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("5")) {
					strTemp = (String)vRetResult.elementAt(4);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);
				}
			}
			if(strTemp == null) 
				strTemp = "0";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               		<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select>			  </td>
		  </tr>
			<tr>
			  <td height="25" class="thinborderTOPLEFTBOTTOM">SATURDAY</td>
			  <td class="thinborderTOPRIGHTBOTTOM">
		<select name="sat_fr_hr" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("sat_fr_hr");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("6")) {
					strTemp = (String)vRetResult.elementAt(1);
				}
			}
			if(strTemp == null) 
				strTemp = "";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
               		<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
				  : 
		<select name="sat_fr_min" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("sat_fr_min");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("6")) {
					strTemp = (String)vRetResult.elementAt(2);
				}
			}
			if(strTemp == null) 
				strTemp = "";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               		<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
				  
				 &nbsp;&nbsp;&nbsp; 
				  to 

		          <select name="sat_to_hr" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("sat_to_hr");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("6")) {
					strTemp = (String)vRetResult.elementAt(3);
				}
			}
			if(strTemp == null) 
				strTemp = "";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
               		<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select> 
		          :  
				  
		<select name="sat_to_min" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11px;">
          <option value=""></option>
          <%
			strTemp = request.getParameter("sat_to_min");
			if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("6")) {
					strTemp = (String)vRetResult.elementAt(4);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
					vRetResult.removeElementAt(0);
				}
			}
			if(strTemp == null) 
				strTemp = "";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               		<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
               	<%}else{%>
               		<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
               	<%}//end of else.
			}//end of for%>
        </select>			  </td>
		  </tr>
	  	</table>
	  
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%
if(iAccessLevel > 1) {%>
    <tr> 
      <td height="50">&nbsp;</td>
      <td align="center"><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./wh.jsp"><img src="../../images/cancel.gif" border="0"></a> 
        Click to clear entries </font></td>
    </tr>
<%}%>	
  </table>

<input type="hidden" name="page_action">
</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>