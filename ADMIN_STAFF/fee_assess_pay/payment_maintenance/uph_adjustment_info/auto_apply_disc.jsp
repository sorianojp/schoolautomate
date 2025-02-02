<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
	function PageAction(strAction,strInfoIndex){
		if(strAction == "0"){
			if(!confirm("Do you want to unexclude this subject?"))
				return;
		}	
		
		
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
			
		document.form_.page_action.value = strAction;			
		document.form_.show_detail.value = "1";
		document.form_.submit();
	
	}
	
	function ReloadPage(){
		location = "./auto_apply_disc.jsp";
	}
	
	function ResetPage() {		
		document.form_.info_index.value= "";
		document.form_.page_action.value = "";
		document.form_.show_detail.value = "1";
		document.form_.submit();
	}
	
	function ShowDetail(){
		document.form_.show_detail.value = "1";
		document.form_.submit();
	}
	
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPmtMaintenance,java.util.Vector" %>
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-PAYMENT MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}		
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}


//add security here.
	try
	{
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


FAPmtMaintenance FAPmt = new FAPmtMaintenance();
Vector vRetResult = null;
Vector vDiscountList = new Vector();


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(FAPmt.operateOnAutoApplyDiscount(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = FAPmt.getErrMsg();
	else{
		if(strTemp.equals("0"))	
			strErrMsg = "Auto Apply Discount removed ";
		if(strTemp.equals("1"))	
			strErrMsg = "Auto Apply Discount added.";
	}
}


if(WI.fillTextValue("show_detail").length() > 0){
	vDiscountList = FAPmt.operateOnAutoApplyDiscount(dbOP, request, 5);
	if(vDiscountList == null)
		strErrMsg = FAPmt.getErrMsg();
	vRetResult    = FAPmt.operateOnAutoApplyDiscount(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = FAPmt.getErrMsg();
}
String strSYFrom = (String)request.getParameter("sy_from"); 
String strSem    = (String)request.getParameter("semester");

%>

<form action="./auto_apply_disc.jsp" method="post" name="form_">

<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr bgcolor="#A49A6A">
	<td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: EXCLUDE SUBJECT PAGE ::::</strong></font></div></td>
</tr>
</table>
  
  <jsp:include page="./tabs.jsp?pgIndex=3"></jsp:include>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="25" style="padding-left: 25px;"><font color="#FF0000" size="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>


<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
      <td width="3%">&nbsp;</td>
      <td  width="15%"> SY-Term : </td>
	  <td height="25">
<%
strSYFrom = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
%> 
	<input name="sy_from" type="text" class="textbox" id="sy_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' value="<%=strSYFrom%>" size="4" maxlength="4">
        to 
<%
strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
%>
	<input name="sy_to" type="text" class="textbox" id="sy_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  readonly="yes"> &nbsp;&nbsp;
     
        <select name="semester" onChange="ResetPage();">
          <option value="1">1st</option>
          <%
strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));
strSem = strTemp;
if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0)
{%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> &nbsp; &nbsp;
		<a href="javascript:ShowDetail();"><img src="../../../../images/form_proceed.gif" border="0"></a>	</td>
    </tr>
<tr>
  <td height="25">&nbsp;</td>
  <td>Course Offered </td>
  <td><select name="course_index" style="width:400px;">
    <%=dbOP.loadCombo("course_index","course_code, course_name"," from course_offered where is_valid = 1 and is_offered = 1 order by course_code ",WI.fillTextValue("course_index"), false)%>
  </select></td>
</tr>
<tr height="25">
  <td>&nbsp;</td>
  <td>Year Level </td>
  <td>
  	<select name="year_level">
		<Option value=""></Option>
<%strTemp = WI.fillTextValue("year_level");
	for(int i = 1; i < 7; ++i) {
		if(strTemp.equals(String.valueOf(i)))
			strErrMsg = "selected";
		else	
			strErrMsg = "";
		%>
		<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
<%}%>	
	</select>
  
  </td>
</tr>
<tr>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
</tr>
    <tr> 
      <td colspan="5"><hr size="1"></td>
    </tr>
    
<%if(WI.fillTextValue("show_detail").length() > 0 && vDiscountList != null && vDiscountList.size() > 0){%>
	<tr> 
      <td>&nbsp;</td>
      <td colspan="4" valign="bottom">Discount List :</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="4" valign="bottom">
	  <select name="fa_fa_index" style="width:700px">
<%
strTemp = WI.fillTextValue("fa_fa_index");
for(int i =0; i < vDiscountList.size(); i += 3) {
	if(strTemp.equals(vDiscountList.elementAt(i)))
		strErrMsg = " selected";
	else	
		strErrMsg = "";%>
			<option value="<%=vDiscountList.elementAt(i)%>" <%=strErrMsg%>><%=vDiscountList.elementAt(i + 1)%></option>

<%}%>
	  </select></td>
    </tr>
	<tr><td colspan="5" height="10"></td></tr>
	<tr>
		<td>&nbsp;</td>
		<td colspan="3">
			<a href="javascript:PageAction('1','');"><img src="../../../../images/save.gif" border="0"></a>
			<font size="1">click to exclude subject</font>		
			
				
			<a href="javascript:ReloadPage();"><img src="../../../../images/cancel.gif" border="0"></a>
			<font size="1">click to reset page</font>		</td>
	</tr>
	<%}%>
</table>


<%if(vRetResult != null && vRetResult.size() > 0){%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="5" height="15"></td></tr>
	<tr><td height="25" align="center"><strong>LIST OF EXCLUDED SUBJECT</strong></td></tr>
</table>


<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td class="thinborder" height="25" width="54%" align="center"><strong>Discount Name </strong></td>
		<td width="31%" align="center" class="thinborder"><strong>Course-Year</strong></td>
		<td class="thinborder" width="15%" align="center"><strong>OPTION</strong></td>
	</tr>
	
	<%
		for(int i = 0; i < vRetResult.size(); i+=6){
		
	%>
	
	<tr>
		<td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+1)%><!--<br><%=(String)vRetResult.elementAt(i+2)%>--></td>
		<td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+3)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 4), ""," - ", "")%></td>
		<td class="thinborder" height="25" align="center">
			<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../../images/delete.gif" border="0"></a>
		</td>
	</tr>
	
	<%}%>
	
</table>

<%}%>


<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25" bgcolor="#FFFFFF">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td></tr>
</table>

<input type="hidden" name="page_action" >
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" >
<input type="hidden" name="show_detail" >

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
