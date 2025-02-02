<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector,java.util.Calendar,java.text.*,java.util.Date " %>
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
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>

<script language="JavaScript">


function PrintPg(strSearchType){

var strTemp = "";
if(strSearchType == '0')
	strTemp = "./mailing_list_per_college_with_parent_print.jsp";
if(strSearchType == '1')
	strTemp = "./mailing_list_per_college_new_stud_print.jsp";
if(strSearchType == '2')
	strTemp = "./mailing_list_per_college_print.jsp";	

if(strTemp.length == 0){
	alert("Please select an option to print.");
	return;
}
	
		
	var printLoc = strTemp+"?search_type="+strSearchType+
	"&sy_from="+document.form_.sy_from.value+
	"&semester="+document.form_.semester.value+
	"&c_index="+document.form_.c_index.value;
	
	var win=window.open(printLoc,"PrintWindow",'width=900,height=400,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>


<body bgcolor="#D2AE72">
<%
	String strTemp = null;	
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORTS","student_mailing_list_swu.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"student_mailing_list_swu.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";




String strSearchType = WI.fillTextValue("search_type");

%>
<form action="./student_mailing_list_swu.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          STUDENT MAILING LIST ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="31%">
			<%
			strTemp = WI.fillTextValue("search_type");
			if(strTemp.equals("0") || strTemp.length() == 0){
				strErrMsg = "checked";
				strSearchType = "0";
			}else
				strErrMsg = "";
			%>
			<input type="radio" name="search_type" value="0" <%=strErrMsg%> onClick="document.form_.submit();">Show by College with Parents Name
	  </td>
		<td width="29%">
			<%			
			if(strTemp.equals("1")){
				strErrMsg = "checked";
				strSearchType = "1";
			}else
				strErrMsg = "";
			%>
			<input type="radio" name="search_type" value="1" <%=strErrMsg%> onClick="document.form_.submit();">Show New Students per College
	  </td>
		<td width="37%">
			<%			
			if(strTemp.equals("2")){
				strErrMsg = "checked";
				strSearchType = "2";
			}else
				strErrMsg = "";
			%>
			<input type="radio" name="search_type" value="2" <%=strErrMsg%> onClick="document.form_.submit();">Show by College
	  </td>
	</tr>
	
</table>	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td colspan="4" height="15"></td></tr>

	
	
	<tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%" height="25">School year </td>
      <td width="46%" height="25"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp; &nbsp;
	  
	  
        <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
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
      <td width="38%">&nbsp;
	  </td>
    </tr>
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="13%">College</td>
		<td colspan="4"><select name="c_index">         
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select></td>
	</tr>
	
	

    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID3">
	<tr><td align="center">
	Rows Per Page: 
	  <select name="rows_per_pg">
<%
int iDefVal = 45;
if(WI.fillTextValue("rows_per_pg").length() > 0)
	iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
for(int i = 45; i < 70; ++i) {
	if(iDefVal == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
	<option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>
	&nbsp; &nbsp;
	<a href="javascript:PrintPg('<%=strSearchType%>');"><img src="../../../../../images/print.gif" border="0"></a> 
		<font size="1">Click to print report</font>		
	</td></tr>
	<td height="15">&nbsp;</td>
</table>


	
	
	
  
  
  

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID4">
<tr><td height="25">&nbsp;</td></tr>
<tr bgcolor="#B8CDD1"><td height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>

</form>


<!--- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>

</body>
</html>
<%
dbOP.cleanUP();
%>