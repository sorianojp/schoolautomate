<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 9px}
-->
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

	function CopyStudentList(){
		document.form_.copy_stud_list.value = "1";
		document.form_.search_.value = "1";
		document.form_.submit();
	}
	
	function Search(){
		document.form_.search_.value = "1";
		document.form_.submit();
	}
	
	function checkAllSaveItems() {
		var maxDisp = document.form_.item_count.value;
		var bolIsSelAll = document.form_.selAllSaveItems.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.Sponsor,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	Vector vFacultyInfo    = null;
	String strFacultyName  = null;

	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Fee Assessment & Payments-SPONSOR".toUpperCase()),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Fee Assessment & Payments".toUpperCase()),"0"));
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Sponsor","copy_sponsored_student.jsp");
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

Sponsor sponsor = new Sponsor();

Vector vRetResult = null;

if(WI.fillTextValue("copy_stud_list").length() > 0){
	if(!sponsor.copySponsoredStudList(dbOP, request))
		strErrMsg = sponsor.getErrMsg();	
}



if(WI.fillTextValue("search_").length() > 0){
	vRetResult = sponsor.getSponsoredStudList(dbOP, request);
	if(vRetResult == null)
		strErrMsg = sponsor.getErrMsg();	
	
}



%>

<form action="./copy_sponsored_student.jsp" method="post" name="form_">

<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr bgcolor="#A49A6A">
	<td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: COPY SPONSORED STUDENT PAGE ::::</strong></font></div></td>
</tr>
</table>
  
  <jsp:include page="./tabs.jsp?pgIndex=2"></jsp:include>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="25" style="padding-left: 25px;"><font color="#FF0000" size="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>



<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Sponsor</td>
		<td>
		<select name="sponsor_index" style="width:400px;" onChange="document.form_.submit();">
          			<option value="">Select Sponsor</option>
          			<%=dbOP.loadCombo("sponsor_index","sponsor_name", " from sponsor_main where is_valid = 1 order by sponsor_name ", WI.fillTextValue("sponsor_index"), false)%>
        		</select>
		</td>
	</tr>
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Previous SY-Term</td>
		
		<td width="80%">
			
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_from"));
			%>
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_to"));
			%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("semester"));
			%>	
				
			<select name="semester">
			<%if(strTemp.equals("1")){%>
				<option value="1" selected>1st Sem</option>
			<%}else{%>
				<option value="1">1st Sem</option>
			
			<%}if(strTemp.equals("2")){%>
				<option value="2" selected>2nd Sem</option>
			<%}else{%>
				<option value="2">2nd Sem</option>
				
			<%}if(strTemp.equals("3")){%>
				<option value="3" selected>3rd Sem</option>
			<%}else{%>
				<option value="3">3rd Sem</option>
			
			<%}if(strTemp.equals("0")){%>
				<option value="0" selected>Summer</option>
			<%}else{%>
				<option value="0">Summer</option>
			<%}%>
			</select>			
		</td>
	</tr>
	<tr><td colspan="3" height="10"></td></tr>
	<tr>
		<td colspan="2" height="25">&nbsp;</td>
		<td>
			<a href="javascript:Search();"><img src="../../../images/form_proceed.gif" border="0"></a>	
		</td>
		
	</tr>
	
</table>


<%if(vRetResult != null && vRetResult.size() > 0){

double dTotalAmt = 0d;
String[] astrConvertSem = {"Summer", "First Semester", "Second Semester", "Third Semester", "Fourth Semester"};
%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="5" height="15"></td></tr>
	<tr>
		<td width="3%">&nbsp;</td>
		<td width="17%">Copy to SY-Term</td>
		<td>
			
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_from_current"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
			%>
			<input name="sy_from_current" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from_current","sy_to_current")'>
			-
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_to_current"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
			%>
			<input name="sy_to_current" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("semester_current"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>	
				
			<select name="semester_current">
			<%if(strTemp.equals("1")){%>
				<option value="1" selected>1st Sem</option>
			<%}else{%>
				<option value="1">1st Sem</option>
			
			<%}if(strTemp.equals("2")){%>
				<option value="2" selected>2nd Sem</option>
			<%}else{%>
				<option value="2">2nd Sem</option>
				
			<%}if(strTemp.equals("3")){%>
				<option value="3" selected>3rd Sem</option>
			<%}else{%>
				<option value="3">3rd Sem</option>
			
			<%}if(strTemp.equals("0")){%>
				<option value="0" selected>Summer</option>
			<%}else{%>
				<option value="0">Summer</option>
			<%}%>
			</select>
	
		</td>
		<td align="right" height="25">
		<a href="javascript:CopyStudentList();"><img src="../../../images/copy.gif" border="0"></a>
		<font size="1">Click to copy list of student</font>
		</td>
	</tr>
	<tr><td height="25" align="center" colspan="5"><strong>LIST OF SPONSORED STUDENT
		<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%>, 
		<%=astrConvertSem[Integer.parseInt(WI.getStrValue(WI.fillTextValue("semester")))]%>
	</strong></td></tr>
</table>	
	
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td class="thinborder" height="25" width="5%"><strong>Count</strong></td>
		<td class="thinborder" height="25" width="15%"><strong>ID Number</strong></td>
		<td class="thinborder" width=""><strong>Student Name</strong></td>
		<td class="thinborder" width="15%" align="center"><strong>Course - Year</strong></td>
		<td class="thinborder" width="15%" align="center"><strong>Amount</strong></td>
		<td class="thinborder" width="15%" align="center"><strong>Select All<br>
			<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();">
		</strong></td>
	</tr>
	
	<%
	int iCount = 1;
	for(int i = 0; i < vRetResult.size(); i+=7, iCount++){
	%>
	<tr>
		<td class="thinborder" height="25"><%=iCount%></td>
		<td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+2)%></td>
		<td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+3)%></td>
		<td class="thinborder" height="25" align=""><%=(String)vRetResult.elementAt(i+4)%> <%=WI.getStrValue((String)vRetResult.elementAt(i+5), "- ", "", "")%></td>
		
		<%
		dTotalAmt += Double.parseDouble((String)vRetResult.elementAt(i+6));
		%>
		<td class="thinborder" height="25" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+6), true)%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i)+".."+(String)vRetResult.elementAt(i+2);
		%>
		<td class="thinborder" height="25" align="center">
			<input type="checkbox" name="save_<%=iCount%>" value="<%=strTemp%>">
		</td>
	</tr>
	
	<%}
	
	
	if(dTotalAmt > 0d){
	%>
	<tr>
		<td height="25" colspan="4" class="thinborder" align="right"><strong>TOTAL AMOUNT</strong></td>
		<td class="thinborder" align="right"><strong><%=CommonUtil.formatFloat(dTotalAmt, true)%></strong></td>
		<td class="thinborder">&nbsp;</td>
	</tr>
	<%}%>
</table>


	<input type="hidden" name="item_count" value="<%=iCount%>" >
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="3" height="15"></td></tr>
	<tr>
		<td align="right" height="25">
		<a href="javascript:CopyStudentList();"><img src="../../../images/copy.gif" border="0"></a>
		<font size="1">Click to copy list of student</font>
		</td>
	</tr>
</table>

<%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25" bgcolor="#FFFFFF">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td></tr>
</table>

<input type="hidden" name="search_" >
<input type="hidden" name="copy_stud_list" >

</form>


</body>
</html>
<%
dbOP.cleanUP();
%>
