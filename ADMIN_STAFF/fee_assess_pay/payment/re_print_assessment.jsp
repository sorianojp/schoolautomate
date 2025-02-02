<%@ page language="java" import="utility.*,enrollment.FAAssessment"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg   = null;
	String strTemp     = null;
	String strORNumber = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null) 
		strSchCode = "";
		
	String strCourseIndex = WI.fillTextValue("course_index");
	if (strSchCode.startsWith("CPU")){
		strTemp = "_cpu";
	}else{
		strTemp = "";	
	}
	
	if(strSchCode.startsWith("PHILCST")){
		if(Integer.parseInt(WI.getStrValue(strCourseIndex,"0")) > 0)
			strTemp = "_3Copies_PHILCST";
		else
			strTemp = "_2Copies_PHILCST";
	}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>STUDENT LEDGER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function FocusID() {
	if(document.form_.stud_id)
		document.form_.stud_id.focus();
}
function ReloadPage() {
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintAssessment(strORNumber) {
	var pgLoc = "./enrollment_receipt_print<%=strTemp%>.jsp?or_number="+escape(strORNumber)+
				"&prevent_forward=<%=WI.fillTextValue("prevent_forward")%>&temp_sl=<%=WI.fillTextValue("temp_sl")%>";
	if(document.form_.print_3copies && document.form_.print_3copies.checked)
		pgLoc = "./enrollment_receipt_print_3Copies.jsp?or_number="+strORNumber;
	//var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	//win.focus();
	location = pgLoc;
}
function PageForwarding() {
	document.bgColor = "#DDDDDD";
}

function ValidateStudent() {
	location = "../../registrar/student_ids/validate_and_print_reg_form.jsp?sy_from=<%=WI.fillTextValue("sy_from")%>&sy_to=<%=WI.fillTextValue("sy_to")%>&semester=<%=WI.fillTextValue("semester")%>&prevent_forward=<%=WI.fillTextValue("prevent_forward")%>&temp_sl=<%=WI.fillTextValue("temp_sl")%>&stud_id=<%=WI.fillTextValue("stud_id")%>&addRecord=1&forward_=1";
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-Student ledger","re_print_assessment.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Fee Assessment & Payments","STUDENT LEDGER",request.getRemoteAddr(),
							//							"re_print_assessment.jsp");
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

String strStudID = WI.fillTextValue("stud_id");

//end of authenticaion code.
if(WI.fillTextValue("stud_id").length() > 0) {	
	String strStudIndex = dbOP.mapUIDToUIndex(strStudID);
	if(dbOP.strBarcodeID != null)
		strStudID = dbOP.strBarcodeID;
	
	FAAssessment faAssessment = new FAAssessment();
	strORNumber = faAssessment.getORToReprintAssessment(dbOP, strStudID, WI.fillTextValue("sy_from"),WI.fillTextValue("semester"));
	
	if(strORNumber == null)
		strErrMsg = faAssessment.getErrMsg();
	else if(strSchCode.startsWith("SWU")) {
		//check if called by EDP.. 
		String strModuleIndex = "0";
		String strSQLQuery = "select module_index from module where module_name in ('Registrar Management','Fee Assessment & Payments')";
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next())
			strModuleIndex += ","+rs.getString(1);
		rs.close();
		
		int iPrintedQty = 0;
		
		strSQLQuery = "select auth_list_index from user_auth_list where is_valid= 1 and main_mod_index in ("+strModuleIndex+") and user_index = "+(String)request.getSession(false).getAttribute("userIndex");
		if(WI.fillTextValue("from_admission").length () > 0 || dbOP.getResultOfAQuery(strSQLQuery, 0) == null) {//printed from admission.
			strSQLQuery = "select form_printed_by from stud_curriculum_hist where is_valid = 1 and user_index = "+strStudIndex+" and sy_from = "+ WI.fillTextValue("sy_from")+
						" and semester = "+ WI.fillTextValue("semester");
			rs = dbOP.executeQuery(strSQLQuery);
			if(rs.next())
				iPrintedQty = rs.getInt(1);
			rs.close();
			//System.out.println(iPrintedQty);	
			if(iPrintedQty >= 2) {
				strORNumber = null;
				strErrMsg = "Already printed premitted number of re-prints.";
			}
			else {
				++iPrintedQty;
				strSQLQuery = "update stud_curriculum_hist set form_printed_by = "+String.valueOf(iPrintedQty)+" where is_valid = 1 and user_index = "+strStudIndex+" and sy_from = "+ WI.fillTextValue("sy_from")+
						" and semester = "+ WI.fillTextValue("semester");
				dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
			}
		}
	}	
}

dbOP.cleanUP();
%>
<form name="form_" action="./re_print_assessment.jsp" method="post">
<%if(strORNumber != null) {%>
<script language="javascript">
	this.PageForwarding();
</script>
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page <label id="page_progress"></label></font></p>

			<!--<img src="../../../Ajax/ajax-loader2.gif">--></td>
      </tr>
</table>
</div>
<%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF"><strong>:::: 
          PRINT RE-ASSESSMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp; <font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2">School Year/Term</td>
      <td height="25" colspan="3" style="font-size:9px;"> 
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        -
        <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> 
		&nbsp;&nbsp;&nbsp;&nbsp;
		<%if(strSchCode.startsWith("CLDH")){%>
		<input type="checkbox" name="print_3copies" value="checked" <%=WI.fillTextValue("print_3copies")%>> 
		<font style="font-size:9px; font-weight:bold; color:#0000FF">Print 3 Copies</font>
		<%}%>
		
		<%if(strSchCode.startsWith("PHILCST")){%>
		Font size to print class card and reg form : 
		<select name="font_size">
<%
int iDef = 11;
for(int i = 10; i < 15; ++i){
if(i == iDef)
	strTemp = " selected";
else	
	strTemp = "";
%>
			<option value="<%=i%>"<%=strTemp%> style="font-size:<%=i%>px"><%=i%> px</option>
<%}%>
	  </select>
		<%}%>
		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Student ID &nbsp;</td>
      <td width="17%" height="25">
	  <input name="stud_id" type="text" size="16" value="<%=strStudID%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      
	  </td>
      <td width="7%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="57%"><input type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8" align="right">
	  <a href="javascript:ValidateStudent();">Validate Student ID</a>
	  </td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<%}%>

<input type="hidden" name="prevent_forward" value="<%=WI.fillTextValue("prevent_forward")%>">
</form>
<%if(strORNumber != null){%>
			<script language="JavaScript">
			this.PrintAssessment("<%=strORNumber%>");
			</script>
			
	<%}%>

</body>
</html>
