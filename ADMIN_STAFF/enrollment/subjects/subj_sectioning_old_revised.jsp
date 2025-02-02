<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function SelALL() {
	var bolIsChecked = document.form_.sel_all.checked;
	var iMaxDisp = document.form_.max_disp.value;
	var obj;
	for(var i = 0; i < iMaxDisp; ++i) {
		eval('obj = document.form_.section_'+i);
		if(!obj)
			continue;
		obj.checked = bolIsChecked;
	}
}
function CopyALL() {
	if(!confirm('Are you sure you want to copy all offering?'))
		return;
		
	document.form_.copy_all.value='1';
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-subject sectioning old","subj_sectioning_old_revised.jsp");
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
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														"subj_sectioning_old_revised.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

SubjectSection SS = new SubjectSection();

//copy section detail if offerSubject =1
if(WI.fillTextValue("copy_all").length() > 0) {
	SS.copySubSecScheduleNew(dbOP, request);
	strErrMsg = SS.getErrMsg();
}
Vector vSecToCopy = new Vector();
Vector vSubList   = new Vector();
if(WI.fillTextValue("school_year_fr_old").length() > 0 && WI.fillTextValue("school_year_fr_new").length() > 0) {
    String strBasicCon  = WI.fillTextValue("basic_con");
    if(strBasicCon.length() > 0) {
      if(strBasicCon.equals("1")) //basic only
        strBasicCon = " and exists (select * from subject where subject.is_del = 2 and sub_index = ess1.sub_index) ";
      else if(strBasicCon.equals("2"))//copy college only.
        strBasicCon = " and exists (select * from subject where subject.is_del = 0 and sub_index = ess1.sub_index)  ";
	  else
	  	strBasicCon = "";
    }
	
	strTemp = 
		" select distinct ess1.SUB_INDEX, sub_code   from e_sub_section as ess1 "+
		" join subject on (subject.SUB_INDEX = ess1.SUB_INDEX) "+
		" where ess1.offering_sy_from = "+WI.fillTextValue("school_year_fr_old")+
        " and ess1.offering_sem = "+WI.fillTextValue("offering_sem_old")+
		" and ess1.is_valid = 1 and not exists "+
        " ( select * from e_sub_section as ess2 where ess2.is_valid = 1 and ess2.offering_sy_from = "+WI.fillTextValue("school_year_fr_new")+
		" and ess2.offering_sem = "+WI.fillTextValue("offering_sem_new")+
		" and ess1.sub_index = ess2.sub_index and ess1.section = ess2.section) "+strBasicCon+
		" order by sub_code";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()){ 
		vSubList.addElement(rs.getString(1));
		vSubList.addElement(rs.getString(2));		
	}rs.close();
	
	
	if(WI.fillTextValue("sub_index").length() > 0)
		strBasicCon += " and ess1.sub_index  ="+WI.fillTextValue("sub_index");

	strTemp = 
		" select distinct section from e_sub_section as ess1 "+		
		" where ess1.offering_sy_from = "+WI.fillTextValue("school_year_fr_old")+
        " and ess1.offering_sem = "+WI.fillTextValue("offering_sem_old")+
		" and ess1.is_valid = 1 and not exists "+
        " ( select * from e_sub_section as ess2 where ess2.is_valid = 1 and ess2.offering_sy_from = "+WI.fillTextValue("school_year_fr_new")+
		" and ess2.offering_sem = "+WI.fillTextValue("offering_sem_new")+
		" and ess1.sub_index = ess2.sub_index and ess1.section = ess2.section) "+strBasicCon+
		" order by section";
	rs = dbOP.executeQuery(strTemp);
	while(rs.next()){ 		
		vSecToCopy.addElement(rs.getString(1));
	}rs.close();	
	if(vSecToCopy.size() == 0 && strErrMsg == null) 
		strErrMsg = "No Section found to copy.";
}
	
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>

<form name="form_" action="./subj_sectioning_old_revised.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6" align="center"><font color="#FFFFFF"><strong>:::: CLASS PROGRAMS PAGE - USE PREVIOUS CLASS PROGRAMS PAGE ::::</strong></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font>      </td>
    </tr>
  </table>
	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%">&nbsp;</td>
      <td height="25">From SY/Term  </td>
      <td height="25"> <input name="school_year_fr_old" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("school_year_fr_old")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","school_year_fr_old","school_year_to_old")'>
        to
        <input name="school_year_to_old" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("school_year_to_old")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp;&nbsp;&nbsp; <select name="offering_sem_old">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("offering_sem_old");
if(strTemp == null) strTemp = "";

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
        </select> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">To new SY/Term </td>
      <td height="25"> <input name="school_year_fr_new" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("school_year_fr_new")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","school_year_fr_new","school_year_to_new")'>
        to
        <input name="school_year_to_new" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("school_year_to_new")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp;&nbsp;&nbsp; <select name="offering_sem_new">
          <option value="1">1st</option>
<%
strTemp = request.getParameter("offering_sem_new");
if(strTemp == null) strTemp = "";

if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
<%}else{%>
          <option value="2">2nd</option>
<%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
<%}else{%>
          <option value="3">3rd</option>
<%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select> </td>
    </tr>
<%if(strSchCode.startsWith("CIT") || true){%>
    <tr>
      <td>&nbsp;</td>
      <td height="25" colspan="2" style="font-weight:bold; color:blue; font-size:14px;">
<%
strTemp = WI.fillTextValue("basic_con");
if(strTemp.length() == 0) 
	strTemp = "3";
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  
	  <input type="radio" name="basic_con" value="1" <%=strErrMsg%>> Copy Grade school only 
<%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="basic_con" value="2" <%=strErrMsg%>> Copy College Only 
<%
if(strTemp.equals("3"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="basic_con" value="3" <%=strErrMsg%>> Copy ALL </td>
    </tr>
<%}%>
    <tr>
      <td width="2%">&nbsp;</td>
      <td width="21%">&nbsp;</td>
      <td width="77%"><input type="submit" name="_s1" value="Refresh Page"> 
        or Click Copy ALL to copy all offering
          <input type="button" name="_s2" value="Copy All Offering" onClick="CopyALL()"></td>
    </tr>
    <tr>
      <td colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>    
<%
if(vSecToCopy.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
      <td width="2%" height="4">&nbsp;</td>
      <td height="25" colspan="2" valign="top">NOTE: Copying of class program per section will copy everything to new sy/term offering including room assignment. Faculty Assignments will not be copied. </td>
    </tr>
  <tr>
    <td height="4">&nbsp;</td>
    <td width="74%" height="25" valign="top">
	<%if(vSubList != null && vSubList.size() > 0){%>
	Subject List &nbsp;	
		<select name="sub_index" style="width:400px;" onChange="document.form_.submit();">
			<option value="">Select All</option>
			<%
			strTemp = WI.fillTextValue("sub_index");
			for(int i = 0; i < vSubList.size(); i+=2){
				if(strTemp.equals((String)vSubList.elementAt(i)))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>	
			<option value="<%=vSubList.elementAt(i)%>" <%=strErrMsg%>><%=vSubList.elementAt(i+1)%></option>
			<%}%>
		</select>
		<input type="image" src="../../../images/refresh.gif" border="0">
	<%}%>
	</td>
    <td width="24%" valign="top">
            <input type="submit" name="_s3" value="Copy Selected Offering" onClick="document.form_.copy_all.value='2'">
	</td>
  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" bgcolor="#DDDDDD">
      <td width="76%" height="25" class="thinborder"><font size="1"><strong>SECTION NAME </strong></font></td>
      <td width="24%" class="thinborder"><strong><font size="1">SELECT ALL </font></strong><br>
	  		<input type="checkbox" name="sel_all" value="1" onClick="SelALL()">
	  </td>
    </tr>
<%
int iCount = 0; 
while(vSecToCopy.size() > 0){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=vSecToCopy.elementAt(0)%></td>
      <td class="thinborder" align="center"><input type="checkbox" name="section_<%=iCount++%>" value="<%=vSecToCopy.remove(0)%>"></td>
    </tr>
<%}%>
<input type="hidden" name="max_disp" value="<%=iCount%>">
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" align="center">
            <input type="submit" name="_s3" value="Copy Selected Offering" onClick="document.form_.copy_all.value='2'">
	  </td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="copy_all">
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>
