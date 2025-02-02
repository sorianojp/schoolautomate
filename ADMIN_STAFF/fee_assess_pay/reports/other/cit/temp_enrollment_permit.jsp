<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
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
<script language="JavaScript" src="../../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
	//document.form_.note.focus();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

//print admission slip.
function PrintPg() {
	var pgURL = "./temp_enrollment_permit_print.jsp?stud_id="+document.form_.stud_id.value+
	"&sy_from="+document.form_.sy_from.value+"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value;
	var win=window.open(pgURL,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-OTHER EXCEPTION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
		//may be called from registrar.
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
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

String strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	
String strSYTo = WI.fillTextValue("sy_to");
if(strSYTo.length() ==0)
	strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");

String strSemester = WI.fillTextValue("semester");
if(strSemester.length() ==0)
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");
if(strSemester == null)
	strSemester = "";
if (WI.fillTextValue("is_basic").equals("1") && !strSemester.equals("0"))  
	strSemester = "1";

boolean bolPrint = false;
String strStudID = WI.fillTextValue("stud_id");
String strStudName = null;
String strNote = null;
if(strStudID.length() > 0) {
	String strSQLQuery = "select fname, mname, lname, user_index from user_table where id_number = '"+strStudID+"' and is_valid =1 and auth_type_index = 4";
	String strStudIndex = null;
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strStudName = WebInterface.formatName(rs.getString(1), rs.getString(2), rs.getString(3), 4);
		strStudIndex = rs.getString(4);
	}
	rs.close();
	if(WI.fillTextValue("show_result").length() > 0 && WI.fillTextValue("note").length() > 0) {
		strSQLQuery = "select temp_permit_index from cit_temp_enrollment_permit where stud_index = "+strStudIndex+" and sy_from = "+strSYFrom+" and semester = "+strSemester+
						" and is_valid = 1";
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery == null) {
			//i have to get last cur hist index.
			strSQLQuery = "select cur_hist_index from stud_curriculum_hist join semester_sequence on (semester_sequence.semester_val = semester) "+
							" where user_index = "+strStudIndex+" order by sy_from desc, sem_order desc";
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			
			strSQLQuery = "insert into 	cit_temp_enrollment_permit (stud_index, sy_from, semester, note, create_date, create_time, created_by, cur_hist_index) values ("+
						strStudIndex+","+strSYFrom+","+strSemester+","+WI.getInsertValueForDB(WI.fillTextValue("note"), true, null)+", '"+WI.getTodaysDate(1)+"', "+
						new java.util.Date().getTime()+", "+(String)request.getSession(false).getAttribute("userIndex")+", "+strSQLQuery+")";
		}
		else	
			strSQLQuery = "update 	cit_temp_enrollment_permit set note = "+WI.getInsertValueForDB(WI.fillTextValue("note"), true, null)+" where temp_permit_index = "+strSQLQuery;
		if(dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false) > -1)
			bolPrint = true;
	}
	//get Information here.
	if(strStudIndex != null) {
		strSQLQuery = "select note from cit_temp_enrollment_permit where stud_index = "+strStudIndex+" and sy_from = "+strSYFrom+" and semester = "+strSemester+" and is_valid = 1";
		strNote = dbOP.getResultOfAQuery(strSQLQuery, 0); 
	}
}

%>
<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus();<%if(bolPrint){%>PrintPg();<%}%>">
<form name="form_" action="./temp_enrollment_permit.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PRINT TEMPORARY ENROLLMENT PERMIT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font style="font-size:16px; font-weight:bold; color:#FF0000"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr valign="top">
      <td height="25">&nbsp;</td>
      <td height="25">Student ID </td>
      <td height="25">
	  <input name="stud_id" type="text" size="24" maxlength="24" value="<%=WI.fillTextValue("stud_id")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="13%" height="25">SY/TERM</td>
      <td height="25"> 
 <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
 <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strSYTo%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="0">Summer</option>
<%if(strSemester.equals("1")){%>
          <option value="1" selected>1st Sem</option>
<%}else{%>
          <option value="1">1st Sem</option>
<%}if(strSemester.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strSemester.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
<%}else{%>
          <option value="3">3rd Sem</option>
<%}%>
        </select></td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td height="25">NOTE: </td>
      <td height="25"><input name="note" type="text" size="65" value="<%=WI.getStrValue(strNote, WI.fillTextValue("note"))%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td style="font-size:9px;"> 
	  <input type="submit" name="1" value="&nbsp;&nbsp;Allow Student and Print &nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value='1'">
		<%if(strNote != null) {%>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="javascript:PrintPg();"><img src="../../../../../images/print.gif" border="0"></a> Print Permit
		<%}%>
	  </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="show_result">

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>