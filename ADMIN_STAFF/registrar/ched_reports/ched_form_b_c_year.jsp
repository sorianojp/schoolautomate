<%@ page language="java" import="utility.*,java.util.Vector,chedReport.CHEDFormBC"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	if (WI.fillTextValue("print_page").equals("1")){
%>
	<jsp:forward page="./ched_form_b_c_print.jsp?show_details=1" />
<%
	return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED E-FORM B/C</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.body_font{
	font-size:11px;
}
</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>

<script language="JavaScript">
function ReloadPage(){
	document.form_.print_page.value="0";
	this.SubmitOnce("form_");
}

function PrepareToEdit(index){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	document.form_.print_page.value="0";
	this.SubmitOnce("form_");
}

function ChangeProgram(){
	document.form_.prepareToEdit.value ="0";
	document.form_.print_page.value="0";	
	if (document.form_.course_index) 
		document.form_.course_index.selectedIndex = 0;
	 if(document.form_.major_index)
		document.form_.major_index.selectedIndex = 0;
	this.SubmitOnce("form_");
}
	


function AddNewRecord(){
	document.form_.page_action.value="1";
	document.form_.print_page.value="0";
	this.SubmitOnce("form_");
}

function EditRecord(){
	document.form_.page_action.value="2";
	document.form_.print_page.value="0";
	this.SubmitOnce("form_");
}

function DeleteRecord(index){
	document.form_.page_action.value="0";
	document.form_.info_index.value = index;
	document.form_.print_page.value="0";
	this.SubmitOnce("form_");
}

function CancelEdit()
{
	location = "./ched_form_b_c_year.jsp?sy_from=" + document.form_.sy_from.value + 
				"&sy_to=" + document.form_.sy_to.value;
}

function viewList(tablename,labelname,strFormField){
	var loadPg = "./ched_updatelist.jsp?tablename=" + tablename + "&labelname="+escape(labelname)+
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPage(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-CHED REPORTS-CHED FORM B C","ched_form_b_c.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}

Vector vRetResult = null;
Vector vEditResult = null;
CHEDFormBC cr = new CHEDFormBC();


String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if (WI.fillTextValue("page_action").equals("0")){
	if (cr.operateOnChedFormBCYears(dbOP,request,0) != null)
		strErrMsg = " Form B/C Data remove successfully";
	else
		strErrMsg =cr.getErrMsg();	
}else if (WI.fillTextValue("page_action").equals("1")){
	if (cr.operateOnChedFormBCYears(dbOP,request,1) != null)
		strErrMsg = " Form B/C Data saved successfully";
	else
		strErrMsg =cr.getErrMsg();	
}else if (WI.fillTextValue("page_action").equals("2")){
	if (cr.operateOnChedFormBCYears(dbOP,request,2) != null){
		strErrMsg = " Form B/C Data updated successfully";
		strPrepareToEdit = "0";
	}else
		strErrMsg =cr.getErrMsg();	
}

if (strPrepareToEdit.equals("1")){
	vEditResult = cr.operateOnChedFormBCYears(dbOP,request,3);
	
	if (vEditResult == null) {
		strErrMsg = cr.getErrMsg();
	}
}

if (WI.fillTextValue("sy_from").length() == 4){  
	vRetResult = cr.operateOnChedFormBCYears(dbOP,request,4);
	
	if (vRetResult == null && cr.getErrMsg() != null) {
		strErrMsg = cr.getErrMsg();
	}
}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./ched_form_b_c_year.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Arial, Helvetica, sans-serif"><strong>CHED 
          E-FORM B/C NORMAL LENGTH IN YEARS</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp; <%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>", "")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="2" bgcolor="#FFFFFF">
    <!--DWLayoutTable-->
    <tr> 
      <td width="123" height="25" class="body_font">&nbsp;Academic Year</td>
      <td width="848"> <% 
	if (vEditResult != null) 
		strTemp = (String)vEditResult.elementAt(1);
	else
		strTemp = WI.fillTextValue("sy_from");
	
	
	if (strTemp.length()  < 4){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	}
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUP="DisplaySYTo('form_','sy_from','sy_to')">
        to 
        <% 
	if (vEditResult != null) 
		strTemp = Integer.toString(Integer.parseInt(strTemp) + 1); 
	else
		strTemp = WI.fillTextValue("sy_to");
	
	if (strTemp.length() < 4 ){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	}
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"> 
        &nbsp;&nbsp; <input type="image" src="../../../images/form_proceed.gif" border="0"> 
      </td>
    </tr>
    <% if (strTemp.length() == 4) {	
		if ( vEditResult != null) 
			strTemp = (String) vEditResult.elementAt(2);
		else
			strTemp = WI.fillTextValue("course_index");
	%>
    <tr> 
      <td height="25" class="body_font">&nbsp;Course</td>
      <td> <select name="course_index" onChange="ReloadPage();">
          <option value="">Select a course</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where degree_type = 1 " +  
		  " and IS_DEL=0 and is_valid=1 order by course_name asc", strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Major</td>
      <td> <% if (strTemp.length() > 0 ) {

		if ( vEditResult != null) 
			strTemp2 = (String) vEditResult.elementAt(4);
		else
			strTemp2 = WI.fillTextValue("major_index");
	
	  %> <select name="major_index">
          <%=dbOP.loadCombo("major_index","major_name"," from major  where course_index = " + strTemp + 
						" and IS_DEL=0 order by major_name asc", strTemp2, false)%> </select> 
		<%} // show only major if c_index is selected%> &nbsp;</td>
    </tr>
    <% if (strTemp.length()  > 0) {

		if (vEditResult != null){
			strTemp = (String) vEditResult.elementAt(6);				
		}else{
			strTemp = WI.fillTextValue("max_year");
		}
	%>
    <tr> 
      <td class="body_font">Normal Length <br>
        (in Years)</td>
      <td><input name="max_year" type="text" size="3" maxlength="3" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','max_year')" onKeyUp="AllowOnlyInteger('form_','max_year')"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp; <% if (iAccessLevel > 1)  {
		if (!strPrepareToEdit.equals("1")) {
%> <a href="javascript:AddNewRecord()"> <img src="../../../images/save.gif" border="0"></a><font size="1">click 
        to save data </font> <%}else{%> <a href="javascript:EditRecord()"> <img src="../../../images/edit.gif" border="0"></a> 
        <font size="1">click to update data</font> <a href="javascript:CancelEdit()"> 
        <img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
        to cancel edit</font> <%} // end if else iAccessLevel > 1
 } // end iAccessLevel > 1
 %> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><!--DWLayoutEmptyCell-->&nbsp;</td>
    </tr>
    <%} // if course is selected
	}// end if school year is set %>
  </table>

<% if (vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DBE8DC"> 
      <td height="25" colspan="5" class="thinborder"><div align="center"><strong>COURSE 
          NORMAL LENGTH</strong></div></td>
    </tr>
    <tr> 
      <td width="33%" height="37" class="thinborder"><div align="center"><strong>COURSE</strong></div></td>
      <td width="30%" class="thinborder"><div align="center"><strong>MAJOR</strong></div></td>
      <td width="19%" class="thinborder"><div align="center"><strong>NORMAL LENGTH<br>
          ( IN YEARS)</strong></div></td>
      <td colspan="2" class="thinborder"> <p align="center"><strong>OPTIONS</strong></p></td>
    </tr>
    <% 
	for (int i =0; i < vRetResult.size() ; i+=7) {
%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5))%></td>
      <td class="thinborder"><div align="center">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></div></td>
      <td width="7%" class="thinborder"> <% if (iAccessLevel > 1) {%> <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0"> 
        </a> <%}else{// end edit %>
        NA 
        <%}%> </td>
      <td width="8%" class="thinborder"><%if (iAccessLevel ==2) {%> <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{// end edit%>
        NA 
        <%}%></td>
    </tr>
    <%  } // end for loop %>
  </table>
 <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
 <tr>
	  <td height="25">&nbsp; </td>
</tr>
<tr>
	  <td height="25"> <div align="center"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print </font></div></td>
</tr>
 </table>
  <% } // end if vRetResult %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2" bgcolor="#FFFFFF"><div align="center"><font color="#FFFFFF" size="2" face="Arial, Helvetica, sans-serif"> 
          </font></div></td>
    </tr>
    <tr> 
	<td height="25" colspan="2" bgcolor="#A49A6A"><font face="Arial, Helvetica, sans-serif">&nbsp;</font></td>
    </tr>
  </table>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action" value="">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="print_page" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
