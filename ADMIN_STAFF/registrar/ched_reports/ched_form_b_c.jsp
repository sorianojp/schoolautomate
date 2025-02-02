<%@ page language="java" import="utility.*,java.util.Vector,chedReport.CHEDFormBC,chedReport.CHEDInstProfile"%>
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
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
	location = "./ched_form_b_c.jsp?sy_from=" + document.form_.sy_from.value + 
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
Vector vInstProfile = null;
CHEDFormBC cr = new CHEDFormBC();
CHEDInstProfile cip = new CHEDInstProfile();


String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if (WI.fillTextValue("page_action").equals("0")){
	if (cr.operateOnChedFormBC(dbOP,request,0) != null)
		strErrMsg = " Form B/C Data remove successfully";
	else
		strErrMsg =cr.getErrMsg();	
}else if (WI.fillTextValue("page_action").equals("1")){
	if (cr.operateOnChedFormBC(dbOP,request,1) != null)
		strErrMsg = " Form B/C Data saved successfully";
	else
		strErrMsg =cr.getErrMsg();	
}else if (WI.fillTextValue("page_action").equals("2")){
	if (cr.operateOnChedFormBC(dbOP,request,2) != null){
		strErrMsg = " Form B/C Data updated successfully";
		strPrepareToEdit = "0";
	}else
		strErrMsg =cr.getErrMsg();	
}

if (strPrepareToEdit.equals("1")){
	vEditResult = cr.operateOnChedFormBC(dbOP,request,3);
	
	if (vEditResult == null) {
		strErrMsg = cr.getErrMsg();
	}
}

if (WI.fillTextValue("sy_from").length() == 4){  
	vRetResult = cr.operateOnChedFormBC(dbOP,request,4);
	vInstProfile = cip.operateOnChedInstProfile(dbOP,request,3);
		
	if (vRetResult == null && cr.getErrMsg() != null) {
		strErrMsg = cr.getErrMsg();
	}
}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./ched_form_b_c.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Arial, Helvetica, sans-serif"><strong>CHED 
          E-FORM B/C </strong> </font></div></td>
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
		strTemp = (String)vEditResult.elementAt(2);
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
    <% 
	if (strTemp.length() == 4)  {
		if ( vEditResult != null) 
			strTemp = (String) vEditResult.elementAt(4);
		else
			strTemp = WI.fillTextValue("cc_index");
%>
    <tr> 
      <td height="25" class="body_font">&nbsp;Program</td>
      <td> <select name="cc_index" onChange="ChangeProgram();">
          <option value=" ">Select a Program</option>
          <%=dbOP.loadCombo("cc_index","cc_name"," from CCLASSIFICATION where IS_DEL=0 order by cc_name asc", strTemp, false)%> </select></td>
    </tr>
    <% if(strTemp.length()>0){
	
		if ( vEditResult != null) 
			strTemp2 = (String) vEditResult.elementAt(5);
		else
			strTemp2 = WI.fillTextValue("course_index");
	
	%>
    <tr> 
      <td height="25" class="body_font">&nbsp;Course</td>
      <td> <select name="course_index" onChange="ReloadPage();">
          <option value="">Select a course</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where cc_index="+ strTemp +
		  " and IS_DEL=0 and is_valid=1 order by course_name asc", strTemp2, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Major</td>
      <td> <% if (strTemp2.length() > 0 ) {

		if ( vEditResult != null) 
			strTemp = (String) vEditResult.elementAt(7);
		else
			strTemp = WI.fillTextValue("major_index");
	
	  %> <select name="major_index">
          <%=dbOP.loadCombo("major_index","major_name"," from major  where course_index = " + strTemp2 + 
						" and IS_DEL=0 order by major_name asc", strTemp, false)%> </select> <%} // show only major if c_index is selected%> &nbsp;</td>
    </tr>
    <% if (strTemp2.length()  > 0) {%>
    <tr bgcolor="#FFEAEE"> 
      <td height="25" colspan="2"> <strong>&nbsp;&nbsp;<font color="#0000FF">PROGRAM 
        DETAIL</font></strong></td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;With Thesis</td>
      <td><select name="with_thesis">
          <option value="0">No</option>
          <% 
		if (vEditResult != null) 
			strTemp = (String) vEditResult.elementAt(9);
		else		   
		  	strTemp = WI.fillTextValue("with_thesis");
			
			if (strTemp.equals("1")) {%>
          <option value="1" selected>Yes</option>
          <%}else{%>
          <option value="1">Yes</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Program Status</td>
      <% if (vEditResult != null) 
	 		strTemp = WI.getStrValue((String) vEditResult.elementAt(20));
		else
	 		strTemp = WI.fillTextValue("course_mode_index");
	 %>
      <td><select name="course_mode_index">
          <option value="">&nbsp;</option>
          <%=dbOP.loadCombo("COURSE_MODE_INDEX","COURSE_MODE", " from CHED_COURSE_MODE where is_del = 0 ", strTemp,false)%> 
        </select>
      </td>
    </tr>
    <tr> 
      <td class="body_font">&nbsp;Remarks</td>
      <%
	if (vEditResult != null) 
		strTemp = WI.getStrValue((String)vEditResult.elementAt(22));
	else
		strTemp = WI.fillTextValue("remarks");
%>
      <td><textarea name="remarks" cols="48" rows="2"  class="textbox" onFocus="CharTicker('form_','256','remarks','count_');style.backgroundColor='#D3EBFF'" onBlur="CharTicker('form_','256','remarks','count_');style.backgroundColor='white'" onKeyUp="CharTicker('form_','256','remarks','count_');"><%=strTemp%></textarea> 
        <font size="1">Allowed Characters</font> <input name="count_" type="text" class="textbox_noborder" size="4" maxlength="4" readonly="yes"> 
      </td>
    </tr>
    <tr bgcolor="#FFEAEE"> 
      <td height="25" colspan="2"><strong><font color="#0000FF">&nbsp;&nbsp;GOVERNMENT 
        AUTHORITY</font></strong></td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;GP No.</td>
      <% if (vEditResult != null) 
	 		strTemp = WI.getStrValue((String) vEditResult.elementAt(12));
		else
	 		strTemp = WI.fillTextValue("gp_no");
	 %>
      <td><input name="gp_no" type="text" size="16" maxlength="16" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Year Granted</td>
      <% if (vEditResult != null) 
	 		strTemp = WI.getStrValue((String) vEditResult.elementAt(13));
		else
	 		strTemp = WI.fillTextValue("gp_no_year");
	 %>
      <td><input name="gp_no_year" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','gp_no_year')" onKeyUp="AllowOnlyInteger('form_','gp_no_year')"></td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Issued by</td>
      <% if (vEditResult != null) 
	 		strTemp = WI.getStrValue((String) vEditResult.elementAt(14));
		else
	 		strTemp = WI.fillTextValue("gp_issuer_index");
	 %>
      <td><select name="gp_issuer_index">
          <option value="">&nbsp;</option>
          <%=dbOP.loadCombo("GP_GR_ISSUE_INDEX","GP_GR_ISSUE", " from CHED_GP_GR_ISSUE where is_del = 0 " +
		  " order by GP_GR_ISSUE ", strTemp,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;GR No.</td>
      <% if (vEditResult != null) 
	 		strTemp = WI.getStrValue((String) vEditResult.elementAt(16));
		else
	 		strTemp = WI.fillTextValue("gr_no");
	 %>
      <td><input name="gr_no" type="text" size="16" maxlength="16" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Year Granted</td>
      <% if (vEditResult != null) 
	 		strTemp = WI.getStrValue((String) vEditResult.elementAt(17));
		else
	 		strTemp = WI.fillTextValue("gr_no_year");
	 %>
      <td><input name="gr_no_year" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','gr_no_year')" onKeyUp="AllowOnlyInteger('form_','gr_no_year')"></td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Issued by</td>
      <% if (vEditResult != null) 
	 		strTemp = WI.getStrValue((String) vEditResult.elementAt(18));
		else
	 		strTemp = WI.fillTextValue("gr_issuer_index");
	 %>
      <td><select name="gr_issuer_index">
          <option value="">&nbsp;</option>
          <%=dbOP.loadCombo("GP_GR_ISSUE_INDEX","GP_GR_ISSUE", " from CHED_GP_GR_ISSUE where is_del = 0 " +
		  " order by GP_GR_ISSUE ", strTemp,false)%> </select> </td>
    </tr>
    <tr> 
      <td colspan="2"><!--DWLayoutEmptyCell-->&nbsp;</td>
    </tr>
    <tr> 
      <% if (vEditResult != null) 
	 		strTemp = (String) vEditResult.elementAt(10);
		else
	 		strTemp = WI.fillTextValue("course_status_index");
	 %>
      <td height="25" class="body_font">&nbsp;Program Mode</td>
      <td><select name="course_status_index">
          <option value="">&nbsp;</option>
          <%=dbOP.loadCombo("course_status_index","COURSE_STATUS"," from CHED_COURSE_STATUS where is_del = 0 order by COURSE_STATUS_CODE",strTemp,false)%> </select> <a href='javascript:viewList("COURSE_STATUS","PROGRAM STATUS","course_status_index")'> 
        </a></td>
    </tr>
    <tr> 
      <td colspan="2"><font color="#FF0000" size="1">&nbsp;</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><font color="#FF0000" size="1">Note: Anything without entry will be 
        considered as <strong>NOT APPLICABLE</strong></font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
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
	} // if course classification is selected
	}// end if school year is set %>
  </table>

<% if (vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DBE8DC"> 
      <td height="25" colspan="13" class="thinborder"><div align="center"><strong>FORM 
          B / C REPORT LISTING</strong></div></td>
    </tr>
    <tr> 
      <td colspan="2" align="center" valign="middle" class="thinborder"> <p><font size="1"><strong>PROGRAM/COURSE</strong></font></p></td>
      <td width="7%" rowspan="2" class="thinborder"><strong><font size="1">&nbsp;With 
        Thesis / Disser -tation</font></strong></td>
      <td width="7%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">&nbsp;Program 
          Status</font></strong></div></td>
      <td colspan="6" class="thinborder"><div align="center"><strong><font size="1">GOVERNMENT 
          AUTHORITY </font></strong></div></td>
      <td width="8%" rowspan="2" class="thinborder"><font size="1"><strong>&nbsp;Program 
        Mode</strong> </font></td>
      <td colspan="2" rowspan="2" class="thinborder"> <p align="center"><strong><font size="1">OPTIONS</font></strong></p></td>
    </tr>
    <tr> 
      <td width="12%" height="37" class="thinborder"><strong><font size="1">&nbsp;Main 
        Program/Course</font></strong></td>
      <td width="13%" class="thinborder"><div align="center"><strong><font size="1">Major</font></strong></div></td>
      <td width="6%" class="thinborder"><strong><font size="1">&nbsp;GP No.</font></strong></td>
      <td width="6%" class="thinborder"><strong><font size="1">&nbsp;Year Granted</font></strong></td>
      <td width="6%" class="thinborder"><strong><font size="1">&nbsp;Issued by 
        </font></strong></td>
      <td width="5%" class="thinborder"><strong><font size="1">&nbsp;GR No.</font></strong></td>
      <td width="6%" class="thinborder"><strong><font size="1">&nbsp;Year Granted</font></strong></td>
      <td width="7%" class="thinborder"><strong><font size="1">&nbsp;Issued by</font></strong></td>
    </tr>
    <% 
	String strCCIndex = null;
	for (int i =0; i < vRetResult.size() ; i+=23) {
	
	if ((String)vRetResult.elementAt(i+3) != null) {
%>
    <tr bgcolor="#E5E5E5"> 
      <td height="25" colspan="13" class="thinborder">&nbsp;<strong><%=(String)vRetResult.elementAt(i+3)%></strong></td>
    </tr>
    <%} // end if classification index not null %>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+21))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+12))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+13))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+15))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+16))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+17))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+19))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+11))%></td>
      <td width="6%" class="thinborder"> <% if (iAccessLevel > 1) {%> <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0"> 
        </a> <%}else{// end edit %>
        NA 
        <%}%>
</td>
      <td width="7%" class="thinborder"><%if (iAccessLevel ==2) {%> <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a><%}else{// end edit%>     NA 
        <%}%></td>
    </tr>
    <%  } // end for loop %>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td class="body_font"> Institution Identifier </td>
            <td height="25"> <%
		if (vInstProfile != null)
			strTemp = WI.getStrValue((String)vInstProfile.elementAt(1));
		else
			strTemp =  WI.fillTextValue("unique_id");
%> <input name="unique_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="16" maxlength="16"> 
            </td>
            <td class="body_font">Region</td>
            <%
		if (vInstProfile != null)
			strTemp = WI.getStrValue((String)vInstProfile.elementAt(8));
		else
			strTemp =  WI.fillTextValue("region");
%>
            <td><input name="region" type="text" size="8" maxlength="8"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
          </tr>
          <tr> 
            <td class="body_font">Address</td>
            <td height="25">
              <%
		if (vInstProfile != null)
			strTemp = WI.getStrValue((String)vInstProfile.elementAt(5)) + 
					  WI.getStrValue((String)vInstProfile.elementAt(6),",","","") +
					  WI.getStrValue((String)vInstProfile.elementAt(7),",","","");
		else
			strTemp =  WI.fillTextValue("address");
%>
              <input name="address" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="32"></td>
            <td>Type of Institution </td>
            <td><select name="type_institution">
                <option value="1"> Private</option>
                <% 

		if (vInstProfile != null){
			strTemp = WI.getStrValue((String)vInstProfile.elementAt(2));
			if (strTemp != null && strTemp.length() > 0) {
				strTemp  = dbOP.mapOneToOther("CHED_OWNERSHIP_TYPE","OWNERSHIP_TYPE_INDEX", strTemp,
												"PRIV_PUBLIC"," and is_del = 0");
				if (strTemp == null)
					strTemp ="";
			}
		 } else
			strTemp =  WI.fillTextValue("type_institution");
	  if (strTemp.equals("0")) {%>
                <option value="0" selected> SUC</option>
                <%}else{%>
                <option value="0"> SUC</option>
                <%}%>
              </select></td>
          </tr>
          <tr> 
            <td width="16%" class="body_font">Accomplished by </td>
            <td width="34%" height="25"><input name="prepared_by" type="text" value="<%=WI.fillTextValue("prepared_by")%>"
	  						 size="30" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
            </td>
            <td width="16%" class="body_font">Certified Correct</td>
            <td width="34%"><input name="certified_correct" type="text" value="<%=WI.fillTextValue("certified_correct")%>" 
	  				size="30"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
          </tr>
          <tr> 
            <td class="body_font">Designation </td>
            <td height="25"><input name="acc_design" type="text" value="<%=WI.fillTextValue("acc_design")%>" size="16"  
	  					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
            <td height="25" class="body_font">Designation </td>
            <td height="25"><input name="certify_correct" type="text" value="<%=WI.fillTextValue("certify_correct")%>" size="16"  
	  				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
          </tr>
          <tr> 
            <td height="25" class="body_font">Date</td>
<% strTemp = WI.fillTextValue("acc_date");
	if (strTemp.length() == 0) 
		strTemp = WI.getTodaysDate(1);
%>				
            <td height="25">
<input name="acc_date" type="text" value="<%=strTemp%>" size="16"  
	  					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"></td>
            <td height="25" class="body_font">Date</td>
<% strTemp = WI.fillTextValue("certify_date");
	if (strTemp.length() == 0) 
		strTemp = WI.getTodaysDate(1);
%>			
            <td height="25">
<input name="certify_date" type="text" value="<%=strTemp%>" size="16"  
	  				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"></td>
          </tr>
        </table>	  
	  
	   </td>
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
