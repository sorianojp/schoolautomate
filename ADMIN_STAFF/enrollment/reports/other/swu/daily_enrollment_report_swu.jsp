<%@ page language="java" import="utility.*,java.util.Vector,enrollment.ReportEnrollment,java.text.*"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
function RefreshPage(){
   document.form_.refresh_page.value="1";
   document.form_.page_action.value ="";
   document.form_.info_index.value="";
   document.form_.prepareToEdit.value=""
   document.form_.submit();
}
function PageAction(strAction, strinfo){
	

    if(strAction == '0'){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}	
	document.form_.page_action.value = strAction;
	if(strAction=='3'){
	  document.form_.prepareToEdit.value = '1';
	  document.form_.page_action.value = "";
	}
	
	if(strinfo.length > 0)
	  document.form_.info_index.value = strinfo;
	  
	
	document.form_.refresh_page.value="1";
	document.form_.submit();
}
</script>
<style type="text/css">
    TD.thinborderTOPLEFTBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
</style>
<body bgcolor="#D2AE72">
<%
	String strTemp = null;	
	String strErrMsg = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT","daily_enrollment_report.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Enrollment","REPORTS",request.getRemoteAddr(),
															"daily_enrollment_report_swu.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}

   //end of authenticaion code.
   Vector vRetResult =null;	
   Vector vEditInfo =null;
	
   ReportEnrollment reportEnrl = new ReportEnrollment();
   
   String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");	   
   strTemp = WI.fillTextValue("page_action");

	if(strTemp.length() > 0){
		if(reportEnrl.operateDailyReportEncoding(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = reportEnrl.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Entry successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Entry successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Entry successfully updated.";
			
			strPrepareToEdit = "0";
		}
	}	
	
	if(WI.fillTextValue("refresh_page").equals("1")){
		vRetResult = reportEnrl.operateDailyReportEncoding(dbOP, request,4);
		if(vRetResult == null)
		   strErrMsg = reportEnrl.getErrMsg();	
	}
	
    if(strPrepareToEdit.equals("1")){
		 vEditInfo = reportEnrl.operateDailyReportEncoding(dbOP, request,3);
		 if(vEditInfo == null)
			strErrMsg = reportEnrl.getErrMsg();
	}	
%>
<form action="./daily_enrollment_report_swu.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A">
	   <div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>
	   :::: DAILY ENROLLMENT REPORT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">	
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%" height="25">School Year </td>
      <td width="31%" height="25"> 
	  <%   if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(1);
		   else			
				strTemp = WI.fillTextValue("sy_from");		
	            if(strTemp.length() ==0)
			            strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
      %> 
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>to 
       <%   if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(2);
		   	else			
		  		strTemp = WI.fillTextValue("sy_to");
				if(strTemp.length() ==0)
					strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	   %> 
	  <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">&nbsp; &nbsp;
	      <select name="semester">
		  <% if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(3);
		   	 else			
		      	strTemp =WI.fillTextValue("semester");
				if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		  %>
          <option value="1">1st Sem</option>
          <%if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select></td>
	  <td width="53%"><a href="javascript:RefreshPage();">
	   <img src="../../../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
	<tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
	<%if(WI.fillTextValue("refresh_page").equals("1")){%>
	<tr>
		<td height="25">&nbsp;</td>
		<td>College</td>
      	<td colspan="2"> 
		<select name="college">
		<%     if(vEditInfo != null && vEditInfo.size() > 0)
				    strTemp = (String)vEditInfo.elementAt(4);
		       else			
				    strTemp = WI.fillTextValue("college");		
	    %>
         <option value="-1">Select a college</option>
       <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 and is_college=1 order by c_name asc", strTemp, false)%>
        </select> </td>
	</tr> 
    <tr>
      <td>&nbsp;</td>
	  <td height="25">Old</td>
	  <td colspan="2">
	  <%    
	  	strTemp = WI.fillTextValue("old_count");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);
	  %>	  
	  <input type="text" name="old_count" value="<%=strTemp%>" class="textbox" size="7"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','old_count');style.backgroundColor='white'" 
	  onKeyUp="AllowOnlyFloat('form_','old_count')"/></td>
  
  </tr>
   <tr>
      <td>&nbsp;</td>
	  <td height="25">New</td>
	  <td colspan="2">
	  <%    
	  	strTemp = WI.fillTextValue("new_count");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);
	  %>	  
	  <input type="text" name="new_count" value="<%=strTemp%>" class="textbox" size="7"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','new_count');style.backgroundColor='white'" 
	  onKeyUp="AllowOnlyFloat('form_','new_count')"/></td>
  
  </tr>
  <tr> 
      <td height="25" colspan="4">&nbsp;</td>
  </tr> 
  <tr>
    <td>&nbsp;</td>
	<td colspan="3"><div align="left">
<%		  if(strPrepareToEdit.equals("0")){%> 
		  <a href="javascript:PageAction('1','');">
		  <img src="../../../../../images/save.gif" border="0"></a> <font size="1">click to save entries </font>
<%        }else{%>
          <a href="javascript:PageAction('2','');">
		  <img src="../../../../../images/edit.gif" border="0"></a> <font size="1">click to edit entries </font>
<%        }%>
          <a href="javascript:RefreshPage();">
		  <img src="../../../../../images/cancel.gif" border="0" /></a><font size="1">click to cancel operation </font></div>	
	</td>
  </tr>
   <tr> 
      <td height="25" colspan="4">&nbsp;</td>
  </tr> 
  <%}//if refresh_page equals 1%>
</table>   
<%if(vRetResult!=null && vRetResult.size()>0){%>  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr>
  <td width="48%" height="23" class="thinborder" align="center"><strong>College</strong> </td>
  <td width="12%" class="thinborder" align="center"><strong>Old</strong></td>
  <td width="12%" class="thinborder" align="center"><strong>New</strong></td>
  <td width="28%" align="center" class="thinborder"><strong>Option</strong></td>
  </tr>
  <% for (int i=0; i<vRetResult.size(); i+=10){%>
   <tr>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
	<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td> 
	<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%></td> 
	<td class="thinborder">
	    <a href="javascript:PageAction('3','<%=(String)vRetResult.elementAt(i)%>');"> 
	    <img src="../../../../../images/edit.gif" border="0" /></a>&nbsp;&nbsp; 
	    <a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');"> 
	    <img src="../../../../../images/delete.gif" border="0" /></a>	</td>
  </tr>
  <%}//edn of vRetResult loop%>
</table>  
  <%}//end of vRetResult !=null && vRetResult.size()>0%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25">&nbsp;</td>
	</tr>
	<tr bgcolor="#B8CDD1">
		<td height="25" bgcolor="#A49A6A">&nbsp;</td>
	</tr>
</table>
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%= WI.fillTextValue("info_index")%>">
<input type="hidden" name="refresh_page"/>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>